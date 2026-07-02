-- =====================================================
-- VIEW: vw_rfm
-- Descrição: Segmentação RFM de clientes baseada em
--            Recência, Frequência e Valor Monetário
--            usando NTILE(5) e CTEs encadeadas
-- Dataset: bigquery-public-data.thelook_ecommerce
-- Filtro: apenas pedidos completos sem devolução
-- Autor: [Bianca]
-- =====================================================

WITH

-- CTE 1: métricas brutas por cliente
-- calcula recência (dias desde última compra),
-- frequência (nº de pedidos) e valor total gasto
metricas_brutas AS (
    SELECT
        o.user_id,
        SUM(oi.sale_price)                                      AS valor_total,
        DATE_DIFF(CURRENT_DATE, DATE(MAX(o.created_at)), DAY)   AS dias_recencia,
        MAX(o.created_at)                                       AS ultima_compra,
        COUNT(DISTINCT o.order_id)                              AS frequencia

    FROM `bigquery-public-data.thelook_ecommerce.orders` o

    JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
        ON o.order_id = oi.order_id

    WHERE o.status = 'Complete'
      AND oi.returned_at IS NULL

    GROUP BY o.user_id
),

-- CTE 2: scores de 1 a 5 para cada dimensão via NTILE
-- R: menor recência (mais recente) = score 5
-- F: maior frequência = score 5
-- M: maior valor total = score 5
scores AS (
    SELECT
        user_id,
        valor_total,
        dias_recencia,
        ultima_compra,
        frequencia,

        NTILE(5) OVER (ORDER BY dias_recencia DESC)  AS score_r,
        NTILE(5) OVER (ORDER BY frequencia DESC)     AS score_f,
        NTILE(5) OVER (ORDER BY valor_total DESC)    AS score_m

    FROM metricas_brutas
),

-- CTE 3: classificação dos clientes em segmentos
-- com base na combinação dos 3 scores
segmentos AS (
    SELECT
        user_id,
        dias_recencia,
        frequencia,
        valor_total,
        score_r,
        score_f,
        score_m,
        ROUND((score_r + score_f + score_m) / 3.0, 2) AS score_rfm_medio,

        CASE
            WHEN score_r = 5  AND score_f >= 4 AND score_m >= 4 THEN 'Campeão'
            WHEN score_r >= 3 AND score_f >= 3 AND score_m >= 3 THEN 'Leal'
            WHEN score_r >= 4 AND score_f <= 2                  THEN 'Promissor'
            WHEN score_r <= 3 AND score_f >= 3 AND score_m >= 3 THEN 'Em risco'
            WHEN score_r <= 2 AND score_f <= 2                  THEN 'Perdido'
            ELSE 'Precisa atenção'
        END AS segmento

    FROM scores
)

-- Resultado final: enriquece com perfil do cliente
SELECT
    s.user_id,
    CONCAT(u.first_name, ' ', u.last_name)  AS cliente,
    u.country                                AS pais,
    u.gender                                 AS genero,

    CASE
        WHEN u.age < 25               THEN '18-24'
        WHEN u.age BETWEEN 25 AND 34  THEN '25-34'
        WHEN u.age BETWEEN 35 AND 44  THEN '35-44'
        ELSE '+45'
    END                                      AS faixa_etaria,

    CAST(s.dias_recencia    AS NUMERIC)      AS dias_recencia,
    CAST(s.frequencia       AS NUMERIC)      AS frequencia,
    CAST(s.valor_total      AS NUMERIC)      AS valor_total,
    CAST(s.score_r          AS NUMERIC)      AS score_r,
    CAST(s.score_f          AS NUMERIC)      AS score_f,
    CAST(s.score_m          AS NUMERIC)      AS score_m,
    CAST(s.score_rfm_medio  AS NUMERIC)      AS score_rfm_medio,
    s.segmento

FROM segmentos s

JOIN `bigquery-public-data.thelook_ecommerce.users` u
    ON s.user_id = u.id

ORDER BY s.valor_total DESC
