-- =====================================================
-- VIEW: vw_receita
-- Descrição: Receita agregada por cliente, mês, país,
--            canal de aquisição e status do pedido
-- Dataset: bigquery-public-data.thelook_ecommerce
-- Autor: [seu nome]
-- =====================================================

SELECT
    o.user_id,
    CONCAT(u.first_name, ' ', u.last_name)  AS cliente,
    u.country                                AS pais,

    CASE u.traffic_source
        WHEN 'Organic' THEN 'Orgânico'
        WHEN 'Search'  THEN 'Pesquisa'
        ELSE u.traffic_source
    END                                      AS fontes,

    CASE o.status
        WHEN 'Cancelled'  THEN 'Cancelado'
        WHEN 'Complete'   THEN 'Completo'
        WHEN 'Processing' THEN 'Processando'
        WHEN 'Returned'   THEN 'Retornado'
        WHEN 'Shipped'    THEN 'Enviado'
    END                                      AS status,

    CAST(DATE_TRUNC(o.created_at, MONTH) AS DATE)  AS data,

    CAST(SUM(oi.sale_price) AS NUMERIC)             AS total_vendido,
    CAST(COUNT(DISTINCT o.order_id) AS NUMERIC)     AS qtd_pedidos,
    CAST(
        SAFE_DIVIDE(
            SUM(oi.sale_price),
            COUNT(DISTINCT o.order_id)
        )
    AS NUMERIC)                                     AS ticket_medio

FROM `bigquery-public-data.thelook_ecommerce.orders` o

JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id

JOIN `bigquery-public-data.thelook_ecommerce.users` u
    ON o.user_id = u.id

GROUP BY
    o.user_id,
    u.country,
    u.traffic_source,
    o.status,
    CAST(DATE_TRUNC(o.created_at, MONTH) AS DATE),
    CONCAT(u.first_name, ' ', u.last_name)
