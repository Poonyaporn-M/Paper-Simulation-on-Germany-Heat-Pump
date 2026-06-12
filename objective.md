# Project Objective

## Topic
Green Job Guarantee and Sectoral Inflation in Germany's Heat Pump Market — 10-Year Forecast (2025–2035)

**Authors:** Poonyaporn Muengsuwan (77206173316), Zahrah Rawosi (77201597962)

---

## Research Question
Can a Green Job Guarantee (GJG) generate inflationary instability through sectoral labor mismatches during the residential green transition in Germany's heat pump market?

---

## Hypotheses

- **H0 (Null):** GJG does not significantly increase inflationary pressure in Germany's residential heat pump installation sector. Labor shortages and installation prices remain stable despite GJG implementation.
- **H1 (Alternative):** GJG significantly increases inflationary pressure via labor mismatches, wage competition, and higher installation costs.

---

## Background & Problem

Germany targets climate neutrality by 2045, requiring ~500,000 heat pump installations/year to decarbonize residential heating (15% of national emissions). Heat pump installation requires certified SHK technicians (Sanitär-Heizung-Klima), currently in severe systemic shortage. A GJG can trigger inflation in two ways:
1. GJG takes labor from private sector when the exogenous wage floor approaches the private market-clearing wage for semi-skilled installation assistants → private sector bids up wages to retain staff
2. Wage-push cost spiral → markup pricing → higher installation costs for consumers

---

## Model: EIRIN (Primary)

**Source:** Monasterolo & Raberto (2018), *Ecological Economics* 144, 228–243

EIRIN is a **Stock-Flow Consistent (SFC) flow-of-funds behavioural model** in the post-Keynesian tradition. Key properties:
- Balance sheet approach (Godley & Lavoie 2007) — all sector accounts sum to zero
- **Leontief production function** — no substitution between Labour, Capital, Raw Materials
- **Endogenous money creation** via commercial bank credit
- Agent-level adaptive behaviour and expectations
- Sectors modelled as representative agents with own behavioural rules

### EIRIN Sectors (adapted for this project)

| Sector | Role in our model |
|--------|------------------|
| Households (Worker) | Low/semi-skilled labour pool (GJG-eligible workers) |
| Households (Capitalist) | Owns firms and bonds |
| Consumption Goods Producer (CGP) | Heat pump installation firms |
| Capital Goods Producer — Green (KGP-green) | Certified SHK technicians / specialist firms |
| Capital Goods Producer — Brown (KGP-brown) | GJG workers / low-skill installation assistants |
| Commercial Bank | Credit provision to installation sector |
| Central Bank | Sets nominal interest rate (Taylor rule) |
| Government | Runs GJG program, issues green sovereign bonds |
| Foreign Sector | Imports heat pump units (hardware) |

### Key EIRIN Mechanisms

1. **Wage setting:** Phillips curve-like rule — nominal wage changes based on unemployment rate (Eq. 5 in Monasterolo & Raberto 2018). Green sector pays `w_green > w_brown`. GJG sets exogenous wage floor `w_GJG`.
2. **Investment decisions:** CGP decides green vs. brown capital via NPV comparison (Eq. 18–19). In our context: hire certified SHK vs. GJG assistants based on expected future installation revenues minus labour costs.
3. **Credit market:** Commercial bank imposes capital adequacy ratio (CAR = 10%, Basel II). Credit rationing limits installation firm expansion.
4. **Labour market:** Green sector (SHK) hires highest-skilled workers first; brown sector (GJG) gets remainder. Labour supply inelastic in short run — total `N_tot` fixed.
5. **Government fiscal:** GJG wage bill financed via tax or green sovereign bonds. Budget balance adjusts tax rate `τ` to hit zero deficit target (or issues bonds).
6. **Prices:** Markup pricing on unit costs — `p = (1 + μ) × u_c` where `u_c = wages + raw materials costs`.

### EIRIN vs DEFINE distinction

| | EIRIN | DEFINE |
|---|---|---|
| **Level** | Sectoral / meso | Global macro |
| **Focus** | Financial flows, credit, labour allocation within sectors | Ecosystem–economy–finance interactions |
| **Money** | Endogenous | Endogenous |
| **Agents** | Representative with adaptive behaviour | Aggregate sectors |
| **Why EIRIN** | Captures labour mismatch + credit + wage dynamics within heat pump sector | Too macro; misses sectoral SHK shortage mechanism |

**DEFINE** (Dafermos et al. 2017; Dafermos & Nikolaidi 2021) is referenced for ecological macro foundations and stock-flow-fund structure but is NOT the simulation model here.

---

## Scenarios

All scenarios run 2025–2035 (10 years, annual time steps).

### Baseline
No GJG. Current German minimum wage (€12.41/hr). Heat pump sector operates under persistent SHK shortage and market-determined wages. ~300k installations/year.

### Scenario A — Low GJG Wage Floor, Low Skill Complementarity
- GJG wage = national minimum wage (€12.41/hr)
- GJG projects focus on low-skill environmental tasks (not SHK-adjacent)
- Elasticity of substitution between GJG workers and SHK technicians is positive but small
- Expected result: minimal crowding-out, moderate inflation

### Scenario B — High GJG Wage, Crowding Out of Technical Labor
- GJG wage set aggressively above market (e.g., €18–20/hr)
- Public sector initiates heavy infrastructure projects competing for basic construction/civil engineering labor
- Direct competition with semi-skilled installation assistants
- Expected result: significant wage-push inflation, private sector bids up wages

### Scenario C — Accelerated GJG + Scarcity-Induced Sectoral Stagflation
- Government mandates 500k heat pump installs/year via regulatory shock alongside GJG
- Elasticity of substitution between GJG workers and certified SHK technicians ≈ 0 (near-zero)
- Demand shock meets inelastic certified labour supply
- Expected result: stagflationary spiral — high prices, stalled installation volumes

---

## Key Variables to Track

| Variable | Symbol | Description |
|----------|--------|-------------|
| SHK wage | `w_SHK` | Market wage for certified technicians |
| GJG wage floor | `w_GJG` | Exogenous policy variable |
| Installation cost | `p_install` | Markup price per installation |
| Inflation index | `π_sector` | YoY change in `p_install` |
| Labor demand (SHK) | `N_SHK` | Certified technicians employed |
| Labor demand (GJG) | `N_GJG` | GJG workers in sector |
| Labor shortage gap | `L_gap` | `N_demanded - N_supplied` for SHK |
| Installation volume | `Q` | Units installed per year |
| Credit rationing | `CR` | Proportion of desired loans not provided |
| Government deficit | `def_G` | GJG program fiscal cost |
| Wage share | `s_w` | Wage bill / total installation cost |

---

## Deliverables

1. **`simulation.R`** — Main EIRIN-based simulation in R (adapted from Monasterolo & Raberto 2018 Matlab code)
2. **`scenarios.R`** — Scenario parameter configurations
3. **`plots.R`** — ggplot2 graphs for all key variables (baseline vs. A vs. B vs. C)
4. **`data/mock_params.R`** — Calibrated mock data (see below)
5. Supporting analysis tables

### Required Graphs
- Wage trajectories: `w_SHK`, `w_GJG` vs. time per scenario
- Installation price index `π_sector` per scenario
- Labour supply/demand gap `L_gap` per scenario
- Installation volume `Q` per scenario
- Credit rationing `CR` per scenario
- Government deficit `def_G` per scenario
- Phase diagram: inflation vs. installation volume (stagflation check)

---

## Data Requirements

This section lists every data series needed, its columns, where to get it, and the citation.

---

### 1. Heat Pump Installation Volume

**What we need:** Annual number of heat pump units sold/installed in Germany, 2015–2024.

| Column | Description |
|--------|-------------|
| `year` | 2015–2024 |
| `hp_units_total` | Total heating heat pumps sold |
| `hp_air_source` | Air-source units |
| `hp_ground_source` | Geothermal units |
| `hp_hot_water` | Hot water heat pumps |

**Source:** Bundesverband Wärmepumpe (BWP) — Absatzstatistik  
**URL:** https://www.waermepumpe.de/presse/zahlen-daten/ ✅ verified working  
**Citation:** BWP (2025). *Absatzentwicklung von Wärmepumpen in Deutschland 2006–2025*. Bundesverband Wärmepumpe e.V., Berlin. Retrieved from https://www.waermepumpe.de/presse/zahlen-daten/

**Key values confirmed from BWP website:**
- 2025: 299,000 heating heat pumps (+55% vs 2024)
- 2022: peak hot water heat pump year (82,500 units)
- 2019: 16,500 hot water heat pumps

---

### 2. Wages — Construction & SHK Trades

**What we need:** Average gross hourly/monthly wages in construction sector and skilled trades (Baugewerbe, Sanitär-Heizung-Klima), 2015–2024.

| Column | Description |
|--------|-------------|
| `year` | 2015–2024 |
| `sector_code` | WZ2008 code (e.g., F43 = specialty construction) |
| `sector_name` | German sector name |
| `avg_gross_hourly_eur` | Average gross hourly wage (€) |
| `avg_gross_monthly_eur` | Average gross monthly wage (€) |
| `worker_type` | "skilled" / "unskilled" / "all" |

**Source:** Destatis — Verdienststrukturerhebung (Structure of Earnings Survey) & Vierteljährliche Verdiensterhebung  
**URL (main site):** https://www.destatis.de ✅ verified (earnings sub-page URL changed — navigate via main site → Labour → Earnings)  
**GENESIS database:** http://genesis.destatis.de/datenbank/online/ ✅ verified working (was www-genesis, now genesis)  
**GENESIS table codes to use:**
- Table `62321-0001`: Gross hourly earnings by economic branch (WZ2008)
- Table `62111-0006`: Gross monthly earnings full-time employees by sector

**Citation:** Statistisches Bundesamt (Destatis) (2024). *Verdienste und Arbeitskosten — Vierteljährliche Verdiensterhebung*. Fachserie 16, Reihe 2.1. Destatis, Wiesbaden. Retrieved from http://genesis.destatis.de/datenbank/online/

**Fallback/supplement for SHK-specific wages:** ZVSHK (Zentralverband Sanitär Heizung Klima) collective wage agreement data. URL: https://www.zvshk.de

---

### 3. Minimum Wage (Germany)

**What we need:** Statutory minimum wage level per year, 2015–2025.

| Column | Description |
|--------|-------------|
| `year` | 2015–2025 |
| `min_wage_eur_hr` | Statutory minimum wage (€/hour) |
| `effective_date` | Date change took effect |

**Source:** Bundesministerium für Arbeit und Soziales (BMAS) / Mindestlohnkommission  
**URL:** https://www.bmas.de/DE/Arbeit/Arbeitsrecht/Mindestlohn/mindestlohn.html ✅ verified working (old URL was missing "Arbeitsrecht" in path)  
**Citation:** Mindestlohnkommission (2024). *Beschluss der Mindestlohnkommission 2024*. Bundesministerium für Arbeit und Soziales, Berlin. Retrieved from https://www.bmas.de/DE/Arbeit/Arbeitsrecht/Mindestlohn/mindestlohn.html

**Known values:**
- 2015: €8.50/hr (introduced)
- 2022: €9.82 → €10.45 → €12.00
- Oct 2022: €12.00/hr
- Jan 2024: €12.41/hr
- Jan 2025: €12.82/hr

---

### 4. SHK Labour Market — Vacancies & Shortage

**What we need:** Open vacancies and employment in SHK/Anlagenmechaniker occupation (KldB 2010 code 2421), 2015–2024.

| Column | Description |
|--------|-------------|
| `year` | 2015–2024 |
| `occupation_code` | KldB 2010 code (2421 = Anlagenmechaniker SHK) |
| `open_vacancies` | Reported unfilled positions |
| `employed_total` | Total employed in occupation |
| `unemployment_in_occupation` | Unemployed with this occupation |
| `vacancy_ratio` | Vacancies per 100 unemployed (labour shortage indicator) |

**Source:** Bundesagentur für Arbeit (BA) — Berichte: Blickpunkt Arbeitsmarkt  
**URL (vacancies):** https://statistik.arbeitsagentur.de/DE/Navigation/Statistiken/Fachstatistiken/Gemeldete-Arbeitsstellen/Gemeldete-Arbeitsstellen-Nav.html ✅ verified working  
**URL (portal):** https://statistik.arbeitsagentur.de ✅ verified working — navigate to "Fachkräfteengpassanalyse" report  
**Direct report:** "Fachkräfteengpassanalyse" (Skilled Labour Shortage Analysis) — published annually  
**Citation:** Bundesagentur für Arbeit (2024). *Fachkräfteengpassanalyse 2024*. Bundesagentur für Arbeit, Nürnberg. Retrieved from https://statistik.arbeitsagentur.de

---

### 5. Construction Cost Index / Price Index for Heating Installation

**What we need:** Price index for heating system installation or general specialty construction, 2015–2024 (used to calibrate `p_install` and `π_sector`).

| Column | Description |
|--------|-------------|
| `year` | 2015–2024 |
| `quarter` | Q1–Q4 (if quarterly available) |
| `cost_index` | Construction cost index (2015=100 base) |
| `category` | "Heizungsanlage" / "Sanitär" / "Klima" / "Specialty construction" |
| `yoy_change_pct` | Year-on-year % change |

**Source:** Destatis — Erzeugerpreisindex Bauwerke (Producer Price Index for Construction)  
**URL:** https://www.destatis.de ✅ verified working — navigate to Economy → Prices → Construction  
**GENESIS table:** `61261-0001` — Index der Erzeugerpreise für Bauwerke (search at http://genesis.destatis.de/datenbank/online/)  
**Citation:** Statistisches Bundesamt (Destatis) (2024). *Preise — Erzeugerpreisindizes für Bauwerke*. Fachserie 17, Reihe 4. Destatis, Wiesbaden. Retrieved from http://genesis.destatis.de/datenbank/online/

---

### 6. Unemployment Rate — Germany (Aggregate + Construction Sector)

**What we need:** Annual unemployment rate overall and in construction sector, 2015–2024. Used as input to Phillips wage equation.

| Column | Description |
|--------|-------------|
| `year` | 2015–2024 |
| `unemployment_rate_total` | Overall German unemployment rate (%) |
| `unemployment_rate_construction` | Construction sector unemployment rate (%) |
| `labour_force_total` | Total labour force (millions) |

**Source:** Destatis — Mikrozensus / ILO Labour Force Concept  
**URL:** https://www.destatis.de ✅ verified working  
**GENESIS table:** `13321-0001` — Erwerbslose, Erwerbstätige, Erwerbsquoten (search at http://genesis.destatis.de/datenbank/online/)  
**Citation:** Statistisches Bundesamt (Destatis) (2024). *Erwerbstätigkeit — Mikrozensus*. Destatis, Wiesbaden. Retrieved from http://genesis.destatis.de/datenbank/online/

---

### 7. Energy Prices (Electricity & Gas for Households)

**What we need:** Household electricity and gas prices per year, 2015–2024. Used to calibrate heat pump operating cost vs. gas boiler cost (affects demand for installations).

| Column | Description |
|--------|-------------|
| `year` | 2015–2024 |
| `electricity_price_eur_kwh` | Avg. household electricity price (€/kWh) |
| `gas_price_eur_kwh` | Avg. household gas price (€/kWh) |
| `heating_oil_price_eur_l` | Heating oil price (€/litre) |

**Source:** Destatis — Verbraucherpreisindex Energie  
**URL:** https://www.destatis.de ✅ verified  
**GENESIS table:** `61111-0006` — Energiepreise private Haushalte (search at http://genesis.destatis.de/datenbank/online/)  
**Supplement:** BDEW Energiemarktdaten — https://www.bdew.de/service/daten-und-grafiken/ ✅ verified working — contains Strom/Gas price charts and data  
**Citation:** Statistisches Bundesamt (Destatis) (2024). *Preise — Verbraucherpreisindizes für Deutschland*. Destatis, Wiesbaden. Retrieved from http://genesis.destatis.de/datenbank/online/. Also: BDEW (2024). *Energiemarktdaten: Strom- und Gaspreise*. Bundesverband der Energie- und Wasserwirtschaft, Berlin. Retrieved from https://www.bdew.de/service/daten-und-grafiken/

---

### 8. Government / Fiscal Data (GJG Proxy: Public Employment Programmes)

**What we need:** Public employment programme expenditure and participation in Germany, 2015–2024. Proxy for GJG cost calibration.

| Column | Description |
|--------|-------------|
| `year` | 2015–2024 |
| `active_labour_market_spend_bn_eur` | Total ALMP spending (€ billion) |
| `participants_public_employment` | Persons in public employment schemes |
| `avg_programme_wage_eur_hr` | Average wage in public employment |

**Source:** Bundesagentur für Arbeit — Eingliederungsbilanz (Integration Report)  
**URL:** https://statistik.arbeitsagentur.de ✅ verified working — navigate to "Arbeitsmarkt in Zahlen" → "Förderstatistik"  
**Citation:** Bundesagentur für Arbeit (2024). *Eingliederungsbilanz nach §54 SGB II*. Bundesagentur für Arbeit, Nürnberg. Retrieved from https://statistik.arbeitsagentur.de

---

### 9. Credit Conditions — German Construction Sector

**What we need:** Bank lending rates and credit availability for German construction SMEs, 2015–2024. Calibrates credit rationing `CR` in EIRIN.

| Column | Description |
|--------|-------------|
| `year` | 2015–2024 |
| `lending_rate_construction_pct` | Interest rate on new loans to construction (%) |
| `credit_standards_index` | ECB BSLS survey index (tightening = positive) |
| `loan_volume_construction_bn_eur` | Total outstanding loans to construction (€ billion) |

**Source:** Deutsche Bundesbank — Bank Lending Survey (BLS) / MFI interest rates  
**URL:** https://www.bundesbank.de/de/statistiken/geld-und-kapitalmaerkte/zinssaetze-und-renditen/einlagen-und-kreditzinssaetze ✅ verified working — MFI deposit and lending rates (euro-denominated loans, new business + outstanding, from 2003)  
**Supplement:** ECB Bank Lending Survey — https://www.ecb.europa.eu/stats/ecb_surveys/bank_lending_survey/html/index.en.html ✅ verified working  
**Citation:** Deutsche Bundesbank (2024). *MFI-Zinsstatistik — Einlagen- und Kreditzinssätze*. Bundesbank, Frankfurt. Retrieved from https://www.bundesbank.de/de/statistiken/geld-und-kapitalmaerkte/zinssaetze-und-renditen/einlagen-und-kreditzinssaetze. Also: ECB (2024). *Euro Area Bank Lending Survey*. European Central Bank, Frankfurt. Retrieved from https://www.ecb.europa.eu/stats/ecb_surveys/bank_lending_survey/html/index.en.html

---

## Data Files Status

Primary source: **Statistisches Bundesamt (Destatis)** — https://www.destatis.de/EN/Home/_node.html  
Database access: **GENESIS-Online** — http://genesis.destatis.de/datenbank/online/

| File | Status | Rows | Real data confirmed | Source |
|------|--------|------|--------------------|----|
| `data/heat_pump_sales.csv` | ✅ created | 7 (2019–2025) | Yes — BWP website | BWP Absatzstatistik |
| `data/minimum_wage.csv` | ✅ created | 12 (2015–2026) | Yes — BMAS confirmed €13.90 Jan 2026 | BMAS Mindestlohnkommission |
| `data/wages_construction.csv` | ✅ created | 7 sectors | Yes — Destatis April 2024 | Destatis Branch-Occupation Tables |
| `data/construction_price_index.csv` | ✅ created | 21 (2021 Q1–2026 Q1) | Yes — Destatis bpr110 | Destatis Construction Price Index |
| `data/shk_vacancies.csv` | ⚠️ needs download | ~10 rows | Requires BA portal login | BA Fachkräfteengpassanalyse |
| `data/unemployment.csv` | ⚠️ needs download | ~10 rows | Requires GENESIS | Destatis table 13321-0001 |
| `data/energy_prices.csv` | ⚠️ needs download | ~10 rows | Requires BDEW download | Destatis / BDEW |
| `data/public_employment.csv` | ⚠️ needs download | ~10 rows | Requires BA download | BA Eingliederungsbilanz |
| `data/credit_conditions.csv` | ⚠️ needs download | ~10 rows | Requires Bundesbank portal | Bundesbank MFI rates |

---

## Confirmed Real Data Points (used directly in simulation)

All values below are from verified live sources — **no mock data**.

| Parameter | Value | Source / Citation |
|-----------|-------|-------------------|
| Heat pump installations 2019 | 119,000/yr | BWP (2025). Absatzstatistik. waermepumpe.de |
| Heat pump installations 2022 | 236,000/yr | BWP (2025). Absatzstatistik. waermepumpe.de |
| Heat pump installations 2023 | 359,000/yr | BWP (2025). Absatzstatistik. waermepumpe.de |
| Heat pump installations 2024 | 193,000/yr | BWP (2025). Absatzstatistik. waermepumpe.de |
| Heat pump installations 2025 | 299,000/yr (+55%) | BWP (2025). Absatzstatistik. waermepumpe.de |
| Target installations/year | 500,000 | GEG (Gebäudeenergiegesetz) 2024, Germany |
| Construction monthly wage 2024 | €3,970/month | Destatis (2025). Branch-Occupation Table April 2024. destatis.de |
| Construction annual wage 2024 | €52,134/yr | Destatis (2025). Yearly Gross Earnings Table 2024. destatis.de |
| All-sector avg hourly wage 2024 | €27.28/hr | Destatis (2025). Branch-Occupation Table April 2024. destatis.de |
| Construction price index 2024 Q4 | 130.8 (2021=100) | Destatis (2026). bpr110 Residential Construction Price Index. destatis.de |
| Construction price inflation 2024 | +3.1% YoY | Destatis (2026). bpr110 Residential Construction Price Index. destatis.de |
| Construction price inflation 2022 | +14.5% to +17.4% | Destatis (2026). bpr110 Residential Construction Price Index. destatis.de |
| Minimum wage Jan 2015 | €8.50/hr | BMAS (2025). Mindestlohn history. bmas.de |
| Minimum wage Jan 2024 | €12.41/hr | BMAS (2025). Mindestlohn history. bmas.de |
| Minimum wage Jan 2025 | €12.82/hr | BMAS (2025). Mindestlohn history. bmas.de |
| Minimum wage Jan 2026 | €13.90/hr | BMAS (2025). Mindestlohn history. bmas.de |
| Capital adequacy ratio (CAR) | 10% | Basel II; Monasterolo & Raberto (2018, Table 2) |
| Markup rate μ | 0.10 | Monasterolo & Raberto (2018). EIRIN, Table 2. Ecol. Econ. 144 |
| Substitution elasticity (Scenario A) | 0.3 | Calibrated — GJG tasks ≠ SHK-certified tasks |
| Substitution elasticity (Scenario B) | 0.5 | Calibrated — moderate labour competition |
| Substitution elasticity (Scenario C) | ~0 | Near-zero — certified SHK legally required |

---

## Reference Papers

| Paper | Model | Role |
|-------|-------|------|
| Monasterolo & Raberto (2018), *Ecol. Econ.* 144 | **EIRIN** | **Primary simulation model** |
| Dafermos, Nikolaidi & Galanis (2017), *Ecol. Econ.* 131 | DEFINE 1.0 | Background ecological macro foundations |
| Dafermos & Nikolaidi (2021), *J. Financial Stability* 54 | DEFINE 1.1 | Green differentiated capital requirements; transmission channels |

---

## Paper Structure (from outline)

| Section | Word Count | Owner |
|---------|-----------|-------|
| 1. Introduction (Germany 2045 goals, SHK shortage, GJG concept, RQ, Hypothesis) | 1,000 | A |
| 2. Methodology & Model (EIRIN, equations, agents, parameters) | 2,500 | B |
| 3. Scenario Analysis (Baseline + A + B + C results) | 2,500 | A |
| 4. Discussion & Policy Implications (evaluate hypotheses, policy translation) | 1,500 | B |
| 5. Conclusion (core findings, limitations, future research) | 500 | A |
