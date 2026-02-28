-- SQL to identify entities with revenue growth for three consecutive months
-- Assumes a table `sales` with columns: entity_id, sale_date (or year_month), revenue
-- Modify table/column names as needed.

WITH monthly_revenue AS (
    SELECT
        entity_id,
        DATE_TRUNC('month', sale_date) AS month,
        SUM(revenue) AS total_revenue
    FROM sales
    GROUP BY entity_id, DATE_TRUNC('month', sale_date)
),
revenue_with_lag AS (
    SELECT
        entity_id,
        month,
        total_revenue,
        LAG(total_revenue, 1) OVER (PARTITION BY entity_id ORDER BY month) AS rev_prev1,
        LAG(total_revenue, 2) OVER (PARTITION BY entity_id ORDER BY month) AS rev_prev2
    FROM monthly_revenue
)
SELECT
    entity_id,
    month AS current_month,
    rev_prev2 AS two_months_ago,
    rev_prev1 AS last_month,
    total_revenue AS this_month
FROM revenue_with_lag
WHERE
    total_revenue > rev_prev1
    AND rev_prev1 > rev_prev2
ORDER BY entity_id, month;

-- This returns rows where revenue has increased for three straight months ending with the current month.
