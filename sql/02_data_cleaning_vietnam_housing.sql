/*
=====================================================
DATA CLEANING – Vietnam Housing Dataset (Hanoi)
Mục tiêu:
- Chuẩn hóa tên cột
- Làm sạch dữ liệu text, NULL, 'NaN'
- Chuẩn hóa đơn vị đo và kiểu dữ liệu
- Loại bỏ dữ liệu sai / không hợp lệ
=====================================================
*/
CREATE VIEW vw_housing_clean AS
-----------------------------------------------------
-- 1. ĐỔI TÊN CỘT
-- Mục đích: đặt tên cột rõ nghĩa, nhất quán,
-- thuận tiện cho phân tích và visualization
-----------------------------------------------------
WITH rename_column AS (
    SELECT
        Column1            AS ID,
        [Ngày],
        [Địa chỉ],
        [Quận]             AS [Quận,huyện],
        [Huyện]            AS [Phường,xã],
        [Loại hình nhà ở],
        [Giấy tờ pháp lý],
        [Số tầng],
        [Số phòng ngủ],
        [Diện tích],
        [Dài],
        [Rộng],
        [Giá/m2]
    FROM VN_housing_dataset
),

-----------------------------------------------------
-- 2. LÀM SẠCH GIÁ TRỊ DẠNG TEXT
-- Mục đích:
-- - Chuẩn hóa dấu thập phân
-- - Loại bỏ đơn vị đo
-- - Chuẩn bị dữ liệu cho bước ép kiểu
-----------------------------------------------------
clean_to_cast_type AS (
    SELECT
        *,
        REPLACE(REPLACE([Giá/m2], '.', ''), ',', '.') AS gia_m2_cleaned,
        NULLIF(REPLACE([Diện tích], ' m²', ''), 'NaN') AS dien_tich_cleaned,
        NULLIF(REPLACE([Dài], ' m', ''), 'NaN') AS dai_cleaned,
        NULLIF(REPLACE([Rộng], ' m', ''), 'NaN') AS rong_cleaned
    FROM rename_column
),

-----------------------------------------------------
-- 3. ÉP KIỂU DỮ LIỆU & CHUẨN HÓA ĐƠN VỊ
-- Mục đích:
-- - Chuyển dữ liệu sang kiểu số phù hợp
-- - Chuẩn hóa giá/m2 về đơn vị VND
-----------------------------------------------------
cast_type AS (
    SELECT
        TRY_CAST(ID AS INT)                 AS ID,
        TRY_CAST([Ngày] AS DATE)            AS [Ngày],
        [Địa chỉ],
        [Quận,huyện],
        [Phường,xã],
        [Loại hình nhà ở],
        [Giấy tờ pháp lý],
        [Số tầng],
        TRY_CAST(
            NULLIF(NULLIF([Số tầng], N'Nhiều hơn 10'), 'NaN') 
            AS INT
        ) AS so_tang_clean,
        [Số phòng ngủ],
        TRY_CAST(dien_tich_cleaned AS NUMERIC) AS [Diện tích],
        TRY_CAST(dai_cleaned       AS NUMERIC) AS [Dài],
        TRY_CAST(rong_cleaned      AS NUMERIC) AS [Rộng],
        CASE
            WHEN gia_m2_cleaned LIKE N'% triệu/m²'
                THEN TRY_CAST(REPLACE(gia_m2_cleaned, N' triệu/m²', '') AS NUMERIC) * 1000000
            WHEN gia_m2_cleaned LIKE N'% tỷ/m²'
                THEN TRY_CAST(REPLACE(gia_m2_cleaned, N' tỷ/m²', '') AS NUMERIC) * 1000000000
            WHEN gia_m2_cleaned LIKE N'% đ/m²'
                THEN TRY_CAST(REPLACE(gia_m2_cleaned, N' đ/m²', '') AS NUMERIC)
        END AS gia_vnd_m2
    FROM clean_to_cast_type
),

-----------------------------------------------------
-- 4. LOẠI BỎ DỮ LIỆU SAI / KHÔNG HỢP LỆ
-- Mục đích:
-- - Loại bỏ bản ghi không có ID
-- - Loại bỏ ngày sai (01/01/1900)
-----------------------------------------------------
remove_wrong_data AS (
    SELECT *
    FROM cast_type
    WHERE ID IS NOT NULL
      AND [Ngày] <> '1900-01-01'
),

-----------------------------------------------------
-- 5. XỬ LÝ GIÁ TRỊ NULL / 'NaN'
-- Mục đích:
-- - Chuẩn hóa missing value
-- - Dùng 'Undefined' cho các giá trị không xác định
-----------------------------------------------------
handle_null AS (
    SELECT
        ID,
        [Ngày],
        [Địa chỉ],
        COALESCE(NULLIF([Quận,huyện], 'NaN'), 'Undefined')        AS [Quận,huyện],
        COALESCE(NULLIF([Phường,xã], 'NaN'), 'Undefined')         AS [Phường,xã],
        COALESCE(NULLIF([Loại hình nhà ở], 'NaN'), 'Undefined')   AS [Loại hình nhà ở],
        COALESCE(NULLIF([Giấy tờ pháp lý], 'NaN'), 'Undefined')   AS [Giấy tờ pháp lý],
        COALESCE(NULLIF([Số tầng], 'NaN'), 'Undefined')           AS [Số tầng],
        so_tang_clean,
        COALESCE(NULLIF([Số phòng ngủ], 'NaN'), 'Undefined')      AS [Số phòng ngủ],
        [Diện tích],
        [Dài],
        [Rộng],
        gia_vnd_m2
    FROM remove_wrong_data
)

-----------------------------------------------------
-- 6. OUTPUT DATA CLEAN
-----------------------------------------------------
SELECT *
FROM handle_null;

SELECT *
FROM vw_housing_clean
