-- =====================================================
-- VIEW: vw_vendas
-- Descrição: Tabela fato central — 1 linha por item vendido
-- Dataset: bigquery-public-data.thelook_ecommerce
-- Autor: [Bianca]
-- =====================================================

SELECT
    oi.order_id,
    oi.user_id                          AS id_cliente,
    p.id                                AS id_produto,

    DATE(o.created_at)                  AS data_pedido,
    DATE(oi.delivered_at)               AS data_entrega,
    DATE(oi.returned_at)                AS data_de_devolucao,

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

    COALESCE(
        CASE o.status
            WHEN 'Cancelled'  THEN 'Cancelado'
            WHEN 'Complete'   THEN 'Completo'
            WHEN 'Processing' THEN 'Processando'
            WHEN 'Returned'   THEN 'Retornado'
            WHEN 'Shipped'    THEN 'Enviado'
        END,
        'Desconhecido'
    )                                   AS status,

    CAST(p.cost         AS NUMERIC)     AS custo_unitario,
    CAST(oi.sale_price  AS NUMERIC)     AS valor_venda

FROM `bigquery-public-data.thelook_ecommerce.order_items` oi

LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON oi.product_id = p.id

LEFT JOIN `bigquery-public-data.thelook_ecommerce.orders` o
    ON oi.order_id = o.order_id
