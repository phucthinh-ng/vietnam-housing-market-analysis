/*
=====================================================
DATA PROFILING – Vietnam Housing Dataset (Hanoi)
=====================================================
*/

-----------------------------------------------------
-- 1. KIỂM TRA PK / UNIQUE KEY
-----------------------------------------------------
-- Column1 được giả định là khóa chính hoặc unique key

SELECT 
    Column1,
    COUNT(*) AS so_lan_xuat_hien
FROM VN_housing_dataset
GROUP BY Column1
HAVING COUNT(*) > 1;
-- Kết luận:
-- Không có giá trị trùng lặp → Column1 có thể dùng làm khóa chính


-----------------------------------------------------
-- 2. PROFILING CÁC CỘT DẠNG PHÂN LOẠI (CATEGORICAL)
-----------------------------------------------------

-- 2.1 Quận
SELECT 
    [Quận],
    COUNT(*) AS so_luong
FROM VN_housing_dataset
GROUP BY [Quận]
ORDER BY so_luong DESC;
-- Nhận xét:
-- Có giá trị trống / thiếu dữ liệu, dữ liệu gốc có thể sai tên cột

-- 2.2 Huyện
SELECT 
    [Huyện],
    COUNT(*) AS so_luong
FROM VN_housing_dataset
GROUP BY [Huyện]
ORDER BY so_luong DESC;
-- Nhận xét:
-- Có giá trị 'NaN' (dạng text) và giá trị thiếu

-- 2.3 Giấy tờ pháp lý
SELECT 
    [Giấy tờ pháp lý],
    COUNT(*) AS so_luong
FROM VN_housing_dataset
GROUP BY [Giấy tờ pháp lý]
ORDER BY so_luong DESC;
-- Nhận xét:
-- Có 1 giá trị NULL

-- 2.4 Loại hình nhà ở
SELECT 
    [Loại hình nhà ở],
    COUNT(*) AS so_luong
FROM VN_housing_dataset
GROUP BY [Loại hình nhà ở]
ORDER BY so_luong DESC;
-- Nhận xét:
-- Có giá trị NULL và 'NaN'


-----------------------------------------------------
-- 3. PROFILING CÁC CỘT SỐ DẠNG TEXT (CÓ ĐƠN VỊ)
-----------------------------------------------------

-- 3.1 Số tầng
SELECT 
    [Số tầng],
    COUNT(*) AS so_luong
FROM VN_housing_dataset
GROUP BY [Số tầng]
ORDER BY so_luong DESC;
-- Nhận xét:
-- Có giá trị dạng chữ như 'Nhiều hơn 10'
-- Có giá trị trống
-- Không thể chuyển trực tiếp sang kiểu số

-- 3.2 Diện tích
SELECT 
    [Diện tích],
    COUNT(*) AS so_luong
FROM VN_housing_dataset
WHERE [Diện tích] NOT LIKE '% m²'
GROUP BY [Diện tích]
ORDER BY so_luong DESC;
-- Kết luận:
-- Tất cả giá trị đều dùng đơn vị m²

-- 3.3 Chiều dài
SELECT 
    [Dài],
    COUNT(*) AS so_luong
FROM VN_housing_dataset
WHERE [Dài] NOT LIKE '% m'
GROUP BY [Dài]
ORDER BY so_luong DESC;
-- Kết luận:
-- Tất cả giá trị đều dùng đơn vị mét (m)

-- 3.4 Chiều rộng
SELECT 
    [Rộng],
    COUNT(*) AS so_luong
FROM VN_housing_dataset
WHERE [Rộng] NOT LIKE '% m'
GROUP BY [Rộng]
ORDER BY so_luong DESC;
-- Kết luận:
-- Tất cả giá trị đều dùng đơn vị mét (m)


-----------------------------------------------------
-- 4. GIÁ TRÊN MỖI M2 (Giá/m2)
-----------------------------------------------------
SELECT 
    [Giá/m2],
    COUNT(*) AS so_luong
FROM VN_housing_dataset
WHERE [Giá/m2] NOT LIKE N'% triệu/m²'
  AND [Giá/m2] NOT LIKE N'% đ/m²'
  AND [Giá/m2] NOT LIKE N'% tỷ/m²'
GROUP BY [Giá/m2]
ORDER BY so_luong DESC;
-- Nhận xét:
-- Có 3 đơn vị khác nhau: triệu/m², đ/m², tỷ/m²
-- Cần chuẩn hóa đơn vị trước khi chuyển sang kiểu số


-----------------------------------------------------
-- 5. SỐ PHÒNG NGỦ
-----------------------------------------------------
SELECT 
    [Số phòng ngủ],
    COUNT(*) AS so_luong
FROM VN_housing_dataset
GROUP BY [Số phòng ngủ]
ORDER BY so_luong DESC;
-- Nhận xét:
-- Có giá trị trống, 'NaN'
-- Có giá trị dạng chữ như 'nhiều hơn 10 phòng'
-- Nên phân nhóm thay vì ép chuyển sang số


-----------------------------------------------------
-- 6. ĐỊA CHỈ
-----------------------------------------------------
-- Cột Địa chỉ
-- Nhận xét:
-- Không phát hiện vấn đề bất thường trong quá trình profiling


-----------------------------------------------------
-- 7. PROFILING CỘT THỜI GIAN
-----------------------------------------------------

-- 7.1 Kiểm tra khả năng chuyển đổi sang kiểu DATE
WITH cte AS (
    SELECT 
        [Ngày],
        TRY_CAST([Ngày] AS DATE) AS ngay_sach
    FROM VN_housing_dataset
)
SELECT 
    MIN(ngay_sach) AS ngay_nho_nhat,
    MAX(ngay_sach) AS ngay_lon_nhat
FROM cte;
-- Kết luận:
-- Dữ liệu nằm trong khoảng từ 01/01/2019 đến 05/08/2020
-- Có dữ liệu bất thường '01/01/1900'
-- 7.2 Kiểm tra phân bố theo năm
WITH cte AS (
    SELECT 
        TRY_CAST([Ngày] AS DATE) AS ngay_sach
    FROM VN_housing_dataset
)
SELECT 
    YEAR(ngay_sach) AS nam,
    COUNT(*) AS so_luong
FROM cte
GROUP BY YEAR(ngay_sach)
ORDER BY nam;
-- Nhận xét:
-- Phần lớn dữ liệu thuộc năm 2019 và 2020
-- Có 1 giá trị bất thường năm 1900, khả năng do lỗi parse ngày
-- Khả năng dữ liệu này của năm 2020, các dòng ở 2019 khả năng là tin cũ

/*
=====================================================
TỔNG KẾT DATA PROFILING
=====================================================

1. Khóa chính
- Column1 không có giá trị trùng → có thể dùng làm PK

2. Chất lượng dữ liệu
- Nhiều cột categorical có NULL, 'NaN', giá trị trống
- Một số cột số ở dạng text, có đơn vị đi kèm

3. Vấn đề cần xử lý ở bước cleaning
- Chuẩn hóa NULL / 'NaN' / blank
- Chuẩn hóa đơn vị giá (triệu, tỷ, đồng)
- Xử lý giá trị dạng chữ ('Nhiều hơn 10', 'nhiều hơn 10 phòng')
- Xử lý ngày bất thường (01/01/1900)

4. Định hướng enrichment
- Tạo giá/m2 dạng số
- Phân nhóm số tầng, số phòng ngủ
- Chuẩn bị dữ liệu cho visualization Power BI
=====================================================
*/
