-- =====================================================
-- VIEW: vw_produtos
-- Descrição: Receita, custo, margem e taxa de devolução
--            agregados por produto e categoria
-- Dataset: bigquery-public-data.thelook_ecommerce
-- Nota: margem calculada sobre todos os pedidos (sem
--       filtro de status) — representa o valor bruto
--       por produto
-- Autor: [Bianca]
-- =====================================================

SELECT
    oi.product_id,
    INITCAP(p.name)                     AS nome_produto,
    INITCAP(p.brand)                    AS marca,

    CASE p.category
        WHEN 'Accessories'                   THEN 'Acessórios'
        WHEN 'Plus'                          THEN 'Plus Size'
        WHEN 'Swim'                          THEN 'Moda Praia'
        WHEN 'Active'                        THEN 'Roupas Esportivas'
        WHEN 'Socks & Hosiery'               THEN 'Meias e Collants'
        WHEN 'Socks'                         THEN 'Meias'
        WHEN 'Dresses'                       THEN 'Vestidos'
        WHEN 'Pants & Capris'                THEN 'Calças e Capris'
        WHEN 'Fashion Hoodies & Sweatshirts' THEN 'Moletons'
        WHEN 'Skirts'                        THEN 'Saias'
        WHEN 'Blazers & Jackets'             THEN 'Blazers e Jaquetas'
        WHEN 'Suits'                         THEN 'Ternos'
        WHEN 'Tops & Tees'                   THEN 'Camisetas'
        WHEN 'Sweaters'                      THEN 'Suéteres'
        WHEN 'Shorts'                        THEN 'Shorts'
        WHEN 'Jeans'                         THEN 'Jeans'
        WHEN 'Maternity'                     THEN 'Maternidade'
        WHEN 'Sleep & Lounge'                THEN 'Pijamas e Loungewear'
        WHEN 'Suits & Sport Coats'           THEN 'Ternos e Paletós'
        WHEN 'Pants'                         THEN 'Calças'
        WHEN 'Intimates'                     THEN 'Lingerie'
        WHEN 'Outerwear & Coats'             THEN 'Casacos'
        WHEN 'Underwear'                     THEN 'Cuecas e Calcinhas'
        WHEN 'Leggings'                      THEN 'Leggings'
        WHEN 'Jumpsuits & Rompers'           THEN 'Macacões'
        WHEN 'Clothing Sets'                 THEN 'Conjuntos'
        ELSE p.category
    END                                 AS categoria,

    CAST(SUM(oi.sale_price) AS NUMERIC) AS total,
    CAST(SUM(p.cost)        AS NUMERIC) AS custo,
    CAST(SUM(oi.sale_price) - SUM(p.cost) AS NUMERIC) AS margem,
    CAST(COUNT(oi.order_id) AS NUMERIC) AS qtd_vendida,

    -- Taxa de devolução calculada via média de flag binária
    -- evita distorção quando o GROUP BY tem granularidade de 1 item
    CAST(
        ROUND(
            AVG(CASE WHEN oi.returned_at IS NOT NULL THEN 1.0 ELSE 0.0 END) * 100,
            2
        )
    AS NUMERIC)                         AS taxa_devolucao

FROM `bigquery-public-data.thelook_ecommerce.order_items` oi

JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON oi.product_id = p.id

GROUP BY
    oi.product_id,
    p.name,
    p.category,
    p.brand
