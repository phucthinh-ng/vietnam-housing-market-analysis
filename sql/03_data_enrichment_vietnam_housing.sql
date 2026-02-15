/*
=====================================================
DATA ENRICHMENT – Vietnam Housing Dataset (Hanoi)
Mục tiêu:
- Bổ sung các biến phân tích (price, bucket, time)
- Xác định outlier bằng phương pháp IQR
- Chuẩn bị dữ liệu cho Power BI
=====================================================
*/
CREATE VIEW vw_housing_enriched AS
-----------------------------------------------------
-- 1. TÍNH GIÁ TỔNG & BIẾN THỜI GIAN
-----------------------------------------------------
WITH base_enrich AS (
    SELECT
        *,
        [Diện tích] * gia_vnd_m2 AS gia_vnd,
        ([Diện tích] * gia_vnd_m2) / 1000000 AS gia_trieu,
        YEAR([Ngày])  AS nam,
        MONTH([Ngày]) AS thang
    FROM vw_housing_clean
),

-----------------------------------------------------
-- 2. PHÂN NHÓM (BUCKETING)
-----------------------------------------------------
bucket_enrich AS (
    SELECT
        *,
        -- Phân nhóm diện tích
        CASE
            WHEN [Diện tích] <= 50  THEN N'1. Nhỏ (≤50m²)'
            WHEN [Diện tích] <= 100 THEN N'2. Vừa (51–100m²)'
            WHEN [Diện tích] > 100  THEN N'3. Lớn (>100m²)'
            ELSE N'Không xác định'
        END AS area_bucket,

        -- Phân nhóm giá/m2
        CASE
            WHEN gia_vnd_m2 < 30000000   THEN N'1. Thấp'
            WHEN gia_vnd_m2 < 70000000   THEN N'2. Trung bình'
            WHEN gia_vnd_m2 >= 70000000  THEN N'3. Cao'
            ELSE N'Không xác định'
        END AS price_m2_bucket
    FROM base_enrich
),

-----------------------------------------------------
-- 3. TÍNH IQR CHO GIÁ / M2
-----------------------------------------------------
price_iqr AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY gia_vnd_m2) OVER() AS Q1_price,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY gia_vnd_m2) OVER() AS Q3_price
    FROM vw_housing_clean
),

price_iqr_bound AS (
    SELECT
        Q1_price,
        Q3_price,
        Q3_price - Q1_price AS iqr_price,
        Q1_price - 1.5 * (Q3_price - Q1_price) AS lower_price,
        Q3_price + 1.5 * (Q3_price - Q1_price) AS upper_price
    FROM price_iqr
),

-----------------------------------------------------
-- 4. FLAG OUTLIER
-----------------------------------------------------
final_enrich AS (
    SELECT
        b.*,
        CASE
            WHEN b.gia_vnd_m2 NOT BETWEEN i.lower_price AND i.upper_price
            THEN 1 ELSE 0
        END AS is_outlier_price_m2,

        CASE
            WHEN b.gia_vnd NOT BETWEEN 
                 (i.lower_price * b.[Diện tích]) AND 
                 (i.upper_price * b.[Diện tích])
            THEN 1 ELSE 0
        END AS is_outlier_total_price
    FROM bucket_enrich b
    CROSS JOIN price_iqr_bound i
)

-----------------------------------------------------
-- 5. OUTPUT
-----------------------------------------------------
SELECT *
FROM final_enrich;

SELECT *
FROM vw_housing_enriched
