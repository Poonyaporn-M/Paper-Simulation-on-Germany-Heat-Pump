# Project Flow: GJG Heat Pump Inflation Simulation

## Overview

This project simulates how a Green Job Guarantee (GJG) affects inflation in Germany's residential heat pump installation sector (2025–2035) using an EIRIN-based Stock-Flow Consistent model implemented in R.

## Data → Model → Output Pipeline

```
[Real Data Sources]
       ↓
[data/ CSV files]
       ↓
[data/mock_params.R — calibrate model parameters]
       ↓
[simulation.R — EIRIN model, 10-year loop]
       ↓
[scenarios.R — inject Baseline / A / B / C shocks]
       ↓
[plots.R — ggplot2 output]
       ↓
[Thesis figures + scenario comparison tables]
```

## Step 1 — Data Inputs

| File | What it provides | Used for |
|------|-----------------|----------|
| `data/heat_pump_sales.csv` | Annual installation volume 2019–2025 | Calibrate initial Q (installation volume) and demand growth rate |
| `data/minimum_wage.csv` | Statutory minimum wage 2015–2026 | Set w_min lower bound; Scenario A wage floor |
| `data/wages_construction.csv` | Construction sector gross wages (Destatis) | Calibrate w_SHK initial value; wage markup |
| `data/construction_price_index.csv` | Residential construction price index 2021–2026 | Calibrate baseline π_sector (inflation); validate model price outputs |
| `data/shk_vacancies.csv` | SHK vacancy rate and shortage (BA) | Calibrate initial L_gap (labour shortage) |
| `data/unemployment.csv` | German unemployment rate 2015–2024 | Phillips curve calibration for wage dynamics |
| `data/energy_prices.csv` | Household electricity & gas prices | Demand-side calibration (heat pump cost vs. gas boiler) |
| `data/public_employment.csv` | Active labour market programme spending | Proxy GJG fiscal cost scaling |
| `data/credit_conditions.csv` | Bank lending rates to construction | Credit rationing (CR) calibration |

## Step 2 — Parameter Calibration (`data/mock_params.R`)

Key EIRIN parameters set from real data:

| Parameter | Symbol | Value | Data source |
|-----------|--------|-------|-------------|
| Initial installation volume | Q_0 | 300,000/yr | BWP 2023 |
| Target volume (policy shock) | Q_target | 500,000/yr | GEG 2024 |
| Construction wage (baseline) | w_SHK_0 | €3,970/month ≈ €23/hr | Destatis 2024 |
| Minimum wage (2024) | w_min | €12.41/hr | BMAS 2024 |
| Markup rate | μ | 0.10 | EIRIN calibration (Monasterolo & Raberto 2018, Table 2) |
| Construction price inflation (baseline) | π_0 | 3.1% | Destatis bpr110 Q4 2024 |
| Capital adequacy ratio | CAR | 0.10 | Basel II / EIRIN |
| Initial L_gap (SHK shortage) | L_gap_0 | ~60,000 | BA Fachkräfteengpassanalyse 2023 |

## Step 3 — Simulation Model (`simulation.R`)

**Time horizon:** 2025–2035 (T=10 annual steps)

### Agents

| Agent | Variables | Behaviour rule |
|-------|-----------|---------------|
| SHK Firms | Q, p_install, N_SHK_demand | Set markup price: p = (1+μ)×w×N/Q |
| GJG Program | N_GJG, w_GJG | Exogenous wage floor; absorbs unemployed |
| Workers | N_SHK_supply, N_GJG_eligible | SHK supply fixed short-run; GJG pool = unemployed + semi-skilled |
| Commercial Bank | CR, loans | Credit rationing based on CAR and debt-service ratio |
| Government | def_G, bonds | Finances GJG; adjusts tax rate τ |

### Core Equations (from EIRIN, Monasterolo & Raberto 2018)

**Wage dynamics (Phillips curve):**
```
Δw_t = (-γ_1 + γ_2 × e_t) × w_{t-1}
```
where e_t = employment rate, γ_1 = 0.018, γ_2 = 0.02

**GJG wage crowding effect:**
```
w_SHK_t = w_SHK_{t-1} × (1 + f(w_GJG_t, L_gap_t, σ))
```
where σ = substitution elasticity (scenario parameter)

**Installation price (markup):**
```
p_install_t = (1 + μ) × (w_SHK_t × N_SHK_t + w_GJG_t × N_GJG_t) / Q_t
```

**Inflation index:**
```
π_sector_t = (p_install_t / p_install_{t-1}) - 1
```

**Credit rationing:**
```
CR_t = f(dsr_{t-1}, CAR_{t-1} - CAR_min)
```
(from EIRIN Eq. 20, Monasterolo & Raberto 2018)

**Labour shortage gap:**
```
L_gap_t = N_SHK_demand_t - N_SHK_supply_t
```
N_SHK_supply grows at ~2%/yr (training pipeline); N_SHK_demand = Q_t / productivity

## Step 4 — Scenarios (`scenarios.R`)

Each scenario changes 3–4 parameters relative to baseline:

| Parameter | Baseline | Scenario A | Scenario B | Scenario C |
|-----------|----------|-----------|-----------|-----------|
| w_GJG | — | €12.41/hr | €19/hr | €12.41/hr |
| σ (substitution) | — | 0.3 | 0.5 | ~0 |
| Q_target shock | 300k | 300k | 300k | 500k (mandated) |
| GJG scale | 0 | Small | Large | Medium |

## Step 5 — Outputs (`plots.R`)

Seven ggplot2 figures:

1. **Wage trajectories** — w_SHK and w_GJG over 2025–2035 per scenario
2. **Installation price index** — π_sector per scenario vs. baseline
3. **Labour shortage gap** — L_gap over time per scenario
4. **Installation volume** — Q per scenario
5. **Credit rationing** — CR over time
6. **Government deficit** — def_G (GJG fiscal cost)
7. **Phase diagram** — π_sector vs. Q (stagflation quadrant check)

Plus one comparison summary table: key variable values in 2035 across all scenarios.

## Key Causal Chain

```
GJG wage floor rises
        ↓
Semi-skilled workers leave private sector for GJG
        ↓
SHK firms face labour cost pressure (bid up wages to retain assistants)
        ↓
w_SHK rises → unit cost rises → p_install = (1+μ) × unit_cost rises
        ↓
π_sector increases (sectoral inflation)
        ↓  [Scenario C only]
Q stalls (Leontief: can't substitute, certified SHK bottleneck)
        ↓
Stagflation: high prices + low output
```

## Data Availability Status

| Dataset | Status | Gap |
|---------|--------|-----|
| Heat pump sales 2019–2025 | ✅ Real data (BWP) | Pre-2019 not available from BWP |
| Minimum wage 2015–2026 | ✅ Real data (BMAS) | Complete |
| Construction wages 2024 | ✅ Real data (Destatis) | Time series pre-2024 requires GENESIS access |
| Construction price index 2021–2026 | ✅ Real data (Destatis) | Pre-2021 not available from this table |
| SHK vacancies | ⚠️ Requires BA portal access | Available at statistik.arbeitsagentur.de |
| Unemployment rate | ⚠️ Requires GENESIS access | Table 13321-0001 |
| Energy prices | ⚠️ Requires BDEW download | Available at bdew.de |
| Credit conditions | ⚠️ Requires Bundesbank portal | Available at bundesbank.de |
| Public employment | ⚠️ Requires BA download | Available at statistik.arbeitsagentur.de |

For datasets marked ⚠️, the simulation uses calibrated values anchored to confirmed real data points as starting values.

## File Structure

```
Paper-Simulation-on-Germany-Heat-Pump/
├── objective.md              # Project goals, data, citations
├── project_flow.md           # This file — how everything connects
├── data/
│   ├── heat_pump_sales.csv   ✅ real data
│   ├── minimum_wage.csv      ✅ real data
│   ├── wages_construction.csv ✅ real data (2024)
│   ├── construction_price_index.csv ✅ real data (2021–2026)
│   ├── shk_vacancies.csv     ⚠️ needs BA download
│   ├── unemployment.csv      ⚠️ needs GENESIS download
│   ├── energy_prices.csv     ⚠️ needs BDEW download
│   ├── public_employment.csv ⚠️ needs BA download
│   └── credit_conditions.csv ⚠️ needs Bundesbank download
├── simulation.R              # Main EIRIN model [TO BUILD]
├── scenarios.R               # Scenario parameters [TO BUILD]
└── plots.R                   # ggplot2 outputs [TO BUILD]
```
