# Vietnam Housing Market Analysis 🏘️📊

## 📌 Project Overview
This project analyzes the **Vietnam housing market** with a focus on **price per square meter**, **property types**, and **district-level comparisons**.  
The goal is to build an **end-to-end data analysis pipeline**, from raw data profiling and cleaning in SQL to interactive insights and benchmarking in Power BI.

The project answers key questions such as:
- How do housing prices vary across districts?
- How does price relate to property size (area)?
- Which districts are over- or under-valued compared to the overall market?
- How do different property types compare in terms of price per m²?

---

## 🧱 Project Structure

---

## 🛢️ SQL Data Pipeline

### 1️⃣ Data Profiling
**File:** `01_data_profiling_vietnam_housing.sql`

Purpose:
- Understand raw data structure and quality
- Check missing values, duplicates, and data ranges
- Explore distributions of price, area, property type, and legal status

Key checks include:
- NULL value counts
- Outlier detection (extreme price and area values)
- Category completeness (districts, property types)

---

### 2️⃣ Data Cleaning
**File:** `02_data_cleaning_vietnam_housing.sql`

Purpose:
- Remove or handle invalid records
- Standardize units and formats
- Filter extreme outliers using statistical rules (IQR)

Main actions:
- Removed listings with invalid or zero area
- Filtered extreme price-per-m² outliers
- Standardized district and property type naming

---

### 3️⃣ Data Enrichment
**File:** `03_data_enrichment_vietnam_housing.sql`

Purpose:
- Create analytical metrics for BI analysis
- Prepare clean, analysis-ready tables

Key derived fields:
- `price_per_m2`
- Price segment classification (Low / Medium / High)
- Market median price per m² (benchmark)
- District-level median price per m²

These enriched fields are used directly in Power BI.

---

## 📊 Power BI Dashboard

**File:** `04_powerbi_vietnam_housing_analysis.pbix`

### Sheet 1 – Market Overview
- Total listings
- Average listing price
- Median price per m²
- Average area
- Distribution of listings by price segment
- Top districts by average price

**Purpose:** Provide a high-level snapshot of the housing market.

---

### Sheet 2 – Price vs Area Analysis
- Scatter plot: Price vs Area by property type
- Median price per m² by property type
- Interactive filters (district, legal status)

**Key insight:**  
Prices increase with area, but the relationship is **non-linear**, and property type plays a significant role.

---

### Sheet 3 – Market Benchmark
- Top 10 districts by median price per m²
- Price difference vs overall market median (DAX-based)
- District × Property Type matrix
- KPI cards comparing selected area vs market median

**Key insight:**  
Some districts are significantly **over-valued or under-valued** relative to the market benchmark, even if they are not the most expensive in absolute terms.

---

## 🧠 Key Insights
- Housing prices vary significantly across districts
- Townhouses and villas consistently command higher prices per m²
- High absolute price does not always imply strong deviation from market median
- Benchmarking against the market median helps identify over- and under-valued areas

---

## 🛠️ Tools & Technologies
- **SQL** (PostgreSQL / compatible syntax)
- **Power BI**
- **DAX** (Median, Benchmark, Price Difference calculations)
- **Git & GitHub**

---

## 📎 Notes
- Extreme outliers were removed using the IQR method to improve analysis reliability
- All visuals are fully interactive via slicers and cross-filtering

