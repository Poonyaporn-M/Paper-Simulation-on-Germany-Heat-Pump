# Data Sources: Human Navigation Guide

How to manually find, verify, and download each dataset used in this project.

---

## 1. Heat Pump Sales — `heat_pump_sales.csv`

**Source:** BWP (Bundesverband Wärmepumpe) Absatzstatistik  
**URL:** https://www.waermepumpe.de/presse/zahlen-daten/

### Steps to find the data:
1. Open the URL above
2. Scroll down to the section **"Absatzzahlen"** or **"Wärmepumpen-Absatzstatistik"**
3. Annual total sales by product type (Heizungswärmepumpen, Warmwasserwärmepumpen) are listed in a table or chart on the page
4. For detailed breakdowns (air-source vs ground-source split), look for a linked **PDF report** — there is usually a "Jahresstatistik" PDF download button
5. Click the PDF link to download the annual statistics report

### What to look for:
- Column: total heating heat pumps sold per year
- Column: hot water heat pumps sold per year
- Air-source (Luft-Wasser) vs ground-source (Sole-Wasser/Wasser-Wasser) split available in PDF

---

## 2. Minimum Wage — `minimum_wage.csv`

**Source:** BMAS (Bundesministerium für Arbeit und Soziales) — Mindestlohnkommission  
**URL:** https://www.bmas.de/DE/Arbeit/Arbeitsrecht/Mindestlohn/mindestlohn.html

### Steps to find the data:
1. Open the URL above — this is the main minimum wage page
2. Look for section **"Mindestlohnentwicklung"** or **"Höhe des Mindestlohns"** — shows a table of all historical rates with effective dates
3. For full official history, scroll to find the **"Mindestlohnkommission"** subsection or click the link to the Mindestlohnkommission page
4. The commission page lists all past recommendations and enacted rates as a table: year, effective date, rate (€/hour)
5. Direct link to historical table: https://www.bmas.de/DE/Arbeit/Arbeitsrecht/Mindestlohn/Mindestlohnkommission/mindestlohnkommission.html

### What to look for:
- Table titled "Entwicklung des gesetzlichen Mindestlohns"
- Columns: Gültig ab (effective date), Mindestlohn (€/Stunde)
- Data goes back to January 2015 (first introduction)

### Download:
No direct CSV download — copy the table manually or use browser developer tools to scrape the HTML table.

---

## 3. Wages by Sector — `wages_construction.csv`

**Source:** Destatis — Earnings by Branch and Occupation, April 2024 snapshot  
**URL (quarterly data):** https://www.destatis.de/EN/Themes/Labour/Earnings/Branch-Occupation/Tables/quaterly-earnings.html  
**URL (annual data):** https://www.destatis.de/EN/Themes/Labour/Earnings/Branch-Occupation/Tables/yearly-gross-earnings.html

### Steps to find the data:
1. Open the quarterly earnings URL above
2. The page displays a table: **"Gross earnings of full-time employees by economic sector"** — April reference month
3. Rows = sectors (Construction, Manufacturing, All sectors, etc.)
4. Columns = average paid hours/week, hourly earnings (excl. bonuses), monthly earnings (excl. bonuses)
5. For Agriculture/Forestry/Fishing annual data: open the yearly-gross-earnings URL instead — same layout but annual figures

### Download:
- Look for **"Download"** button or icon (Excel symbol) at the top-right of the table
- Click to download as `.xlsx` file
- The table is also downloadable via **GENESIS database** — table code `62321-0001`
  - Go to https://genesis.destatis.de/datenbank/online/
  - Search for code `62321` → select table → configure years → download CSV

---

## 4. Construction Price Index — `construction_price_index.csv`

**Source:** Destatis — Short-Term Indicators, Construction Prices (bpr110)  
**URL:** https://www.destatis.de/EN/Themes/Economy/Short-Term-Indicators/Prices/bpr110.html

### Steps to find the data:
1. Open the URL above
2. Page shows three tables automatically:
   - Table 1: Index values (base 2021=100), quarterly, residential and non-residential buildings
   - Table 2: Year-over-year % change
   - Table 3: Quarter-over-quarter % change
3. Data runs from ~2021 Q1 to latest available quarter (currently 2026 Q1)

### Download:
- Click the **Excel/Download icon** above each table (top-right corner of table box)
- Downloads as `.xlsx`
- Alternative: navigate to GENESIS → table code `61111-0002` for full historical series back to 2000

---

## 5. Remaining Datasets (manual portal access required)

These datasets require navigating German statistical portals. Steps below.

### 5a. SHK Skilled Worker Vacancies — BA Statistik
**Portal:** https://statistik.arbeitsagentur.de/DE/Navigation/Statistiken/Fachstatistiken/Gemeldete-Arbeitsstellen/Gemeldete-Arbeitsstellen-Nav.html  
**Steps:**
1. Open portal URL
2. Select **"Berufe"** (occupations) filter
3. Search for occupation code **KldB 2010: 2514X** (Klempner, Installateur, Heizungsbauer) or use text search "Sanitär Heizung Klima"
4. Select time range 2015–2024
5. Click **"Tabelle erstellen"** → download as CSV/Excel

### 5b. Unemployment Rate — Destatis
**Portal:** https://genesis.destatis.de/datenbank/online/  
**Table code:** `13211-0001` (unemployment rate by month)  
**Steps:**
1. Go to GENESIS portal
2. In search box, enter `13211-0001`
3. Select time range 2015–2024, annual frequency
4. Click **"Werteabruf"** → **"CSV herunterladen"**

### 5c. Energy Prices (Gas/Electricity) — Destatis
**Portal:** https://genesis.destatis.de/datenbank/online/  
**Table code:** `61243-0001` (energy price index, consumer prices)  
**Steps:** same as 5b but search `61243`

### 5d. Government Employment Program Data — BMAS
**URL:** https://www.bmas.de/DE/Arbeit/Arbeitsfoerderung/arbeitsfoerderung.html  
**Steps:**
1. Navigate to "Statistiken" section
2. Look for annual reports on "Beschäftigungsförderung" or "Öffentlich geförderte Beschäftigung"
3. Download annual PDF or Excel report

### 5e. Bank Lending Rate to Firms — Deutsche Bundesbank
**URL:** https://www.bundesbank.de/de/statistiken/geld-und-kapitalmaerkte/zinssaetze-und-renditen/einlagen-und-kreditzinssaetze  
**Steps:**
1. Open the URL above
2. Scroll to section **"Kreditzinssätze"** — new business lending rates
3. Select series: **"Kredite an nichtfinanzielle Kapitalgesellschaften"** (loans to non-financial corporations)
4. Set time range and click **"Zeitreihe herunterladen"** → CSV

---

## Summary Table

| File | Source Website | Direct Download? | Portal Code |
|------|---------------|-----------------|-------------|
| heat_pump_sales.csv | waermepumpe.de | PDF on page | — |
| minimum_wage.csv | bmas.de | Manual copy | — |
| wages_construction.csv | destatis.de | Excel button on page | 62321-0001 |
| construction_price_index.csv | destatis.de | Excel button on page | 61111-0002 |
| shk_vacancies.csv (needed) | arbeitsagentur.de | Portal query | KldB 2514X |
| unemployment.csv (needed) | genesis.destatis.de | Portal CSV | 13211-0001 |
| energy_prices.csv (needed) | genesis.destatis.de | Portal CSV | 61243-0001 |
| public_employment.csv (needed) | bmas.de | PDF report | — |
| lending_rate.csv (needed) | bundesbank.de | Time series CSV | — |
