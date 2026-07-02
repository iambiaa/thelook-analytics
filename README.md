# 📊 TheLook E-commerce Analytics

> **Case:** O crescimento do TheLook é saudável?  
> Análise de receita, lucro, margem, devoluções e segmentação de clientes de um e-commerce de moda usando BigQuery e Power BI.

---

## 🎯 Objetivo

Investigar se o crescimento de receita do TheLook entre 2024 e 2026 é sustentável, respondendo perguntas como:

- A receita líquida e o lucro crescem na mesma proporção?
- A margem bruta se mantém estável ao longo dos anos?
- As taxas de devolução e cancelamento acompanham o crescimento?
- Quais segmentos de clientes estão em risco de churn?
- Quais categorias de produto sustentam o crescimento?

---

## 🗂️ Estrutura do repositório

```
thelook-analytics/
│
├── README.md
│
└── sql/
    ├── vw_clientes.sql    # Dimensão de clientes — perfil demográfico e canal
    ├── vw_vendas.sql      # Tabela fato — itens de pedido com produto e status
    └── vw_rfm.sql         # Segmentação RFM de clientes
```

---

## 🗃️ Dataset

**Fonte:** [BigQuery Public Data — TheLook Ecommerce](https://console.cloud.google.com/marketplace/product/bigquery-public-data/thelook-ecommerce)  
**Período analisado:** 2024, 2025 e 2026 (2024 = ano base)  
**Tabelas utilizadas:** `order_items`, `orders`, `products`, `users`

---

## 📐 Modelo de dados

```
vw_clientes (1)
      │
      ├── id ──────────── vw_vendas.id_cliente (N)
      │
      └── id ──────────── vw_rfm.user_id (N)

Tabela Calendário (1)
      │
      └── Date ─────────── vw_vendas.data_pedido (N)
```

---

## 📏 Regras de negócio

| Métrica | Fórmula | Base |
|---|---|---|
| Receita Bruta | `SUM(valor_venda)` | Todos os pedidos |
| Receita Líquida | `SUM(valor_venda)` | Apenas completos sem devolução |
| Lucro | `Receita Líquida - Custo do produto` | Apenas completos sem devolução |
| Margem % | `Lucro / Receita Líquida` | Apenas completos sem devolução |
| Ticket Médio | `Receita Líquida / Qtd Pedidos completos` | Apenas completos sem devolução |
| Taxa Devolução | `Devolvidos / Total de pedidos` | Base bruta |
| Taxa Cancelamento | `Cancelados / Total de pedidos` | Base bruta |

> ⚠️ O custo considera apenas o custo do produto — não inclui frete ou impostos. O lucro calculado equivale à **margem bruta do produto**.

---

## 🧠 Queries SQL

### vw_clientes
Dimensão de clientes com 1 linha por usuário. Inclui perfil demográfico (país, cidade, faixa etária, gênero) e canal de aquisição traduzidos para português.

**Skills demonstradas:** `CASE WHEN` · `INITCAP` · `CONCAT` · tradução de categorias

---

### vw_vendas
Tabela fato central com 1 linha por item vendido. Inclui dados de produto (categoria traduzida, marca, custo), pedido (status traduzido, datas) e valor de venda. Conecta com `vw_clientes` pelo `id_cliente` e com `vw_rfm` via `vw_clientes`.

**Skills demonstradas:** `LEFT JOIN` múltiplo · `CASE WHEN` · `COALESCE` · `CAST` · `INITCAP` · tradução de 26 categorias

---

### vw_rfm
Segmentação RFM completa usando 3 CTEs encadeadas e window functions. Classifica cada cliente em Campeão, Leal, Promissor, Em risco, Perdido ou Precisa atenção com base em Recência, Frequência e Valor Monetário.

**Skills demonstradas:** `CTEs encadeadas` · `NTILE(5) OVER()` · `DATE_DIFF` · `COUNT DISTINCT` · `CASE WHEN` · `ROUND` · `CAST`

---

## 📊 Dashboard Power BI

### Página 1 — Receita & Crescimento
- KPIs: Receita Bruta, Receita Líquida, Lucro, Margem %, Ticket Médio, Taxa Devolução, Taxa Cancelamento
- Receita mensal comparativa 2024 vs 2025 vs 2026
- Top países por receita
- Receita por canal de aquisição
- Distribuição de pedidos por status

### Página 2 — Clientes & Produtos
- Distribuição de clientes por segmento RFM
- Perfil dos clientes por segmento (país, gênero, faixa etária)
- Receita por categoria ao longo dos anos
- Margem % por categoria
- Taxa de devolução por categoria

---

## 🛠️ Tecnologias

![BigQuery](https://img.shields.io/badge/BigQuery-4285F4?style=flat&logo=google-cloud&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=flat&logo=power-bi&logoColor=black)
![SQL](https://img.shields.io/badge/SQL-336791?style=flat&logo=postgresql&logoColor=white)

---

## 🚀 Como reproduzir

1. Acesse o [BigQuery Console](https://console.cloud.google.com/bigquery)
2. Crie um projeto e um dataset chamado `portfolio`
3. Execute cada arquivo `.sql` da pasta `/sql` e salve como View no seu dataset
4. Exporte as views como CSV
5. Importe os CSVs no Power BI Desktop
6. Configure os relacionamentos conforme o modelo de dados acima
7. Crie as medidas DAX conforme as regras de negócio definidas

---

Projeto desenvolvido como parte do portfólio de entrada na área de dados.  
Desenvolvido com análise exploratória no BigQuery e visualização no Power BI.
