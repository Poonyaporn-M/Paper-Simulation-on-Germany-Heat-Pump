# Green Job Guarantee and Sectoral Inflation in Germany's Heat Pump Market
### 10-Year Forecast (2025–2035)
**Authors:** Poonyaporn Muengsuwan · Zahrah Rawosi

---

## What this project does (simple explanation)

Germany wants to fight climate change by replacing gas boilers with heat pumps in millions of homes. But installing a heat pump requires a specially certified technician — called an **SHK technician** (plumber/heating engineer). Germany already has a severe shortage of these people, and training new ones takes years.

A **Green Job Guarantee (GJG)** is a policy idea where the government offers public green jobs to anyone who wants one. This sounds good — but it can accidentally make the heat pump shortage *worse*. Here's how:

1. The government offers public jobs at a decent wage (say €13–19/hour)
2. Semi-skilled workers who currently assist SHK firms take those public jobs instead (better pay, more stable)
3. Now SHK firms are short of *even their assistant workers*, so they raise wages to compete
4. Higher wages → higher costs → higher prices for homeowners wanting a heat pump
5. In the worst case: prices go up AND fewer heat pumps get installed (stagflation)

**This simulation models exactly that chain of events** across 4 scenarios over 10 years (2025–2034), using a well-established academic model (EIRIN) calibrated to real German economic data.

---

## How to run the project

### Requirements
- R (version 4.0+)
- Packages: `readr`, `ggplot2`, `dplyr`, `tidyr`

Install missing packages:
```r
install.packages(c("readr", "ggplot2", "dplyr", "tidyr"))
```

### Running

**Option 1 — Run everything at once (generates all figures):**
```r
# From the project root directory in R or RStudio:
setwd("/path/to/Paper-Simulation-on-Germany-Heat-Pump")
source("plots.R")
```
This automatically runs `scenarios.R` → `simulation.R` → `data/mock_params.R` in sequence.

**Option 2 — Step by step:**
```r
setwd("/path/to/Paper-Simulation-on-Germany-Heat-Pump")
source("data/mock_params.R")   # load parameters
source("simulation.R")          # define simulation function
source("scenarios.R")           # run 4 scenarios, save CSV
source("plots.R")               # generate 7 figures
```

**From terminal:**
```bash
cd "Paper-Simulation-on-Germany-Heat-Pump"
Rscript plots.R
```

### Outputs
- `data/simulation_results.csv` — all scenario results (year × scenario × 15 variables)
- `figures/fig1_wages.png` — SHK vs GJG wage trajectories
- `figures/fig2_price_index.png` — heat pump installation price index (2025=100)
- `figures/fig3_inflation.png` — sectoral inflation rate (%) vs ECB 2% target
- `figures/fig4_labour_gap.png` — SHK technician shortage gap over time
- `figures/fig5_installations.png` — annual installations vs 500k government target
- `figures/fig6_credit.png` — credit rationing rate (bank lending squeeze)
- `figures/fig7_phase_diagram.png` — stagflation check: inflation vs volume

---

## Scenarios

| Scenario | GJG Wage | Worker overlap with SHK | Government mandate |
|----------|---------|------------------------|-------------------|
| **Baseline** | None (no GJG) | — | Market-driven |
| **A** | €12.82/hr (min wage) | Low (σ=0.3) | Market-driven |
| **B** | €19/hr (above market) | Moderate (σ=0.5) | Market-driven |
| **C** | €12.82/hr | Near-zero (σ≈0) | 500k installs/year |

**σ (sigma)** = how substitutable GJG workers are for certified SHK technicians.
σ=0 means they cannot substitute at all (legally certified SHK required). σ=0.5 means GJG workers cover half the gap.

---

## Key 2034 results

| Scenario | SHK Wage | Installations/yr | Sectoral Inflation | Gov. Deficit |
|----------|---------|------------------|--------------------|-------------|
| Baseline | €32.83/hr | 357,000 | 2.2% | — |
| Scenario A | €33.58/hr | 384,000 | 2.4% | €0.29bn |
| Scenario B | €35.23/hr | 481,000 | 2.5% | €1.21bn |
| Scenario C | €34.49/hr | 359,000 | 2.4% | €0.39bn |

**Key finding:** Scenario C hits only 359k installs/year against a 500k mandate — a permanent 30% shortfall — while wages and prices still rise. This is the stagflation signal H1 predicts.

---

## File structure

```
Paper-Simulation-on-Germany-Heat-Pump/
├── README.md                         ← this file
├── objective.md                      ← research question, hypotheses, model docs
├── project_flow.md                   ← how data → model → output connects
│
├── data/
│   ├── mock_params.R                 ← load CSVs, build params list
│   ├── heat_pump_sales.csv           ✅ real (BWP 2025)
│   ├── minimum_wage.csv              ✅ real (BMAS 2025)
│   ├── wages_construction.csv        ✅ real (Destatis April 2024)
│   ├── construction_price_index.csv  ✅ real (Destatis bpr110)
│   ├── shk_vacancies.csv             ⚠️ calibrated (BA Engpassanalyse)
│   ├── unemployment.csv              ⚠️ calibrated (Destatis Mikrozensus)
│   ├── energy_prices.csv             ⚠️ calibrated (BDEW)
│   ├── public_employment.csv         ⚠️ calibrated (BA Eingliederungsbilanz)
│   ├── credit_conditions.csv         ⚠️ calibrated (Bundesbank MFI)
│   ├── data_sources_guide.md         ← how to download each dataset manually
│   └── simulation_results.csv        ← generated output (all scenarios)
│
├── simulation.R                      ← EIRIN model core
├── scenarios.R                       ← run 4 scenarios
├── plots.R                           ← 7 ggplot2 figures
│
└── figures/
    ├── fig1_wages.png
    ├── fig2_price_index.png
    ├── fig3_inflation.png
    ├── fig4_labour_gap.png
    ├── fig5_installations.png
    ├── fig6_credit.png
    └── fig7_phase_diagram.png
```

---

## Data sources

| Data | Source | Status |
|------|--------|--------|
| Heat pump sales | BWP — waermepumpe.de/presse/zahlen-daten/ | ✅ Real |
| Minimum wage | BMAS — bmas.de/Arbeitsrecht/Mindestlohn | ✅ Real |
| Construction wages | Destatis — destatis.de | ✅ Real |
| Construction price index | Destatis bpr110 — destatis.de | ✅ Real |
| SHK vacancies | BA — statistik.arbeitsagentur.de | ⚠️ Calibrated |
| Unemployment | Destatis GENESIS table 13321-0001 | ⚠️ Calibrated |
| Energy prices | BDEW — bdew.de | ⚠️ Calibrated |
| Credit conditions | Bundesbank MFI rates | ⚠️ Calibrated |

See `data/data_sources_guide.md` for step-by-step download instructions.

---

## Model reference

Monasterolo, I. & Raberto, M. (2018). The EIRIN Flow-of-funds Behavioural Model of Green Fiscal Policies and Private Green Investment. *Ecological Economics*, 144, 228–243.
