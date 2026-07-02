-- =====================================================
-- VIEW: vw_clientes
-- Descrição: Dimensão de clientes — 1 linha por cliente
--            com perfil demográfico e canal de aquisição
-- Dataset: bigquery-public-data.thelook_ecommerce
-- Autor: [Bianca]
-- =====================================================

SELECT
    u.id,
    CONCAT(u.first_name, ' ', u.last_name)  AS cliente,
    u.country                                AS pais,
    INITCAP(u.city)                          AS cidade,

    CASE
        WHEN u.age < 25               THEN '18-24'
        WHEN u.age BETWEEN 25 AND 34  THEN '25-34'
        WHEN u.age BETWEEN 35 AND 44  THEN '35-44'
        ELSE '+45'
    END                                      AS faixa_etaria,

    CASE
        WHEN u.gender = 'F' THEN 'Feminino'
        WHEN u.gender = 'M' THEN 'Masculino'
    END                                      AS genero,

    CASE u.traffic_source
        WHEN 'Organic' THEN 'Orgânico'
        WHEN 'Search'  THEN 'Pesquisa'
        ELSE u.traffic_source
    END                                      AS fonte

FROM `bigquery-public-data.thelook_ecommerce.users` u
