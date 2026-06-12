# Project Status & Next Steps
**Green Job Guarantee and Sectoral Inflation in Germany's Heat Pump Market**
Authors: Poonyaporn Muengsuwan · Zahrah Rawosi

---

## What this project does (plain language)

Germany needs 500,000 heat pump installations per year to hit its 2045 climate targets. Installing a heat pump requires a certified SHK technician (plumber/heating engineer). Germany has a severe, documented shortage of these workers (~20,000 unfilled vacancies in 2024).

A Green Job Guarantee (GJG) offers public green jobs at a set wage. This simulation asks: does a GJG accidentally make heat pumps *more expensive* by pulling semi-skilled helpers out of private installation firms? And in the worst case, do prices rise while installations stall — i.e., stagflation?

The simulation models 4 scenarios over 2025–2034 using the EIRIN model (Monasterolo & Raberto 2018):
- **Baseline**: no GJG
- **Scenario A**: low GJG wage (€12.82/hr), low worker overlap with SHK
- **Scenario B**: high GJG wage (€19/hr), moderate overlap
- **Scenario C**: 500k install mandate + GJG, near-zero substitution → stagflation

---

## How to run everything

```r
setwd("/path/to/Paper-Simulation-on-Germany-Heat-Pump")
source("simulation.R")
```

This single file does everything: loads data → sets parameters → runs 4 scenarios → saves CSV → generates 7 figures.

---

## Current file structure

```
Paper-Simulation-on-Germany-Heat-Pump/
├── simulation.R              ← SINGLE ENTRY POINT: run this
├── README.md                 ← project overview + non-technical explanation
├── PROJECT_STATUS.md         ← this file
├── objective.md              ← research question, model, scenarios, data docs
├── project_flow.md           ← pipeline diagram
│
├── data/
│   ├── heat_pump_sales.csv           ✅ real (BWP 2025)
│   ├── minimum_wage.csv              ✅ real (BMAS 2025)
│   ├── wages_construction.csv        ✅ real (Destatis April 2024)
│   ├── construction_price_index.csv  ✅ real (Destatis bpr110)
│   ├── shk_vacancies.csv             ⚠️ calibrated (BA Engpassanalyse)
│   ├── unemployment.csv              ⚠️ calibrated (Destatis Mikrozensus)
│   ├── energy_prices.csv             ⚠️ calibrated (BDEW)
│   ├── public_employment.csv         ⚠️ calibrated (BA Eingliederungsbilanz)
│   ├── credit_conditions.csv         ⚠️ calibrated (Bundesbank MFI)
│   ├── data_sources_guide.md         ← step-by-step download instructions
│   └── simulation_results.csv        ← generated output (40 rows × 17 cols)
│
└── figures/
    ├── fig1_wages.png          SHK wage + GJG wage floor trajectories
    ├── fig2_price_index.png    Installation price index (2025=100)
    ├── fig3_inflation.png      Sectoral inflation vs ECB 2% target
    ├── fig4_labour_gap.png     SHK technician shortage gap
    ├── fig5_installations.png  Annual installs vs 500k GEG target
    ├── fig6_credit.png         Credit rationing rate
    └── fig7_phase_diagram.png  Stagflation check (inflation vs volume)
```

---

## Current 2034 simulation results

| Scenario | SHK Wage | Installations/yr | Sectoral Inflation | Gov. Cost |
|----------|---------|------------------|--------------------|-----------|
| Baseline | €32–33/hr | 357k | ~2.5% | — |
| Scenario A | €34/hr | 386k | ~3.0% | €0.29bn |
| Scenario B | €30/hr | 484k | ~2.7% | €1.24bn |
| Scenario C | €37/hr | 359k vs **500k mandate** | ~2.5% | €0.40bn |

**Key finding so far:** Scenario C shows persistent 28–40% shortfall against the 500k mandate while wages are highest → stagflation signal confirmed for the paper.

---

## What needs to be improved in the model

### High priority (affects paper conclusions)

1. **Scenario B wages too low** — with sigma=0.5, GJG fills half the labour gap which *reduces* scarcity pressure → w_SHK grows slower than Baseline. Economically this is consistent but the paper's H1 prediction is that Scenario B should show the *most* wage pressure. Consider either: lowering sigma_B to 0.3, raising N_GJG_scaleB, or adding a direct wage competition term where high w_GJG_B forces private SHK firms to bid above GJG to retain skilled staff.

2. **Credit rationing (CR) decays to 0% by 2028 in all scenarios** — because r_loan converges to neutral as pi_sector falls below 2.5%. CR should stay elevated in Scenarios B and C (high GJG program increases fiscal risk perception). Fix: add a fiscal pressure component — `CR[t] += 0.02 * def_G[t]`.

3. **No validation against historical BWP data (2019–2024)** — model should reproduce actual installation volumes before forecasting. Currently unchecked. Add a calibration chart (fig0) comparing model Baseline 2019–2024 vs real BWP data.

### Medium priority (improves robustness)

4. **Single-point calibration** — `productivity = Q_0 / N_SHK_supply_0` relies entirely on 2025 values. Should use 2019–2024 average from the heat_pump_sales.csv time series to reduce dependence on the anomalous 2025 rebound year.

5. **No sensitivity analysis** — key results depend heavily on `kappa` (0.8) and `alpha_semi` (0.6). A table showing 2034 results across kappa={0.4, 0.6, 0.8, 1.0} and alpha_semi={0.3, 0.6, 0.9} would show which conclusions are robust.

6. **SHK shortage treated as exogenous initial condition** — in reality, higher wages attract more people into SHK training (supply elasticity). Add: `N_SHK_supply_growth[t] = 0.02 + 0.005 * max(0, w_SHK[t-1] - w_SHK_0) / w_SHK_0` so supply responds to the wage signal.

---

## What data still needs to be downloaded

5 CSVs are currently calibrated estimates. Real data would strengthen the paper:

| Dataset | Where to get it | GENESIS code | Priority |
|---------|----------------|-------------|----------|
| SHK vacancies 2015–2024 | statistik.arbeitsagentur.de → Fachkräfteengpassanalyse | KldB 2421 | HIGH |
| Unemployment time series | genesis.destatis.de | 13321-0001 | HIGH |
| Construction wages 2015–2023 | genesis.destatis.de | 62321-0001 | MEDIUM |
| Energy prices 2015–2024 | bdew.de → Energiemarktdaten | — | LOW |
| Credit conditions | bundesbank.de → MFI Zinssätze | — | LOW |

See `data/data_sources_guide.md` for exact click-by-click instructions.

---

## What still needs to be written (the paper itself)

The simulation is done. The paper is not started. Required sections:

| Section | Content | Status |
|---------|---------|--------|
| 1. Introduction | Germany 2045 goals, SHK shortage, GJG concept, RQ, H0/H1 | ❌ Not started |
| 2. Methodology | EIRIN model equations, sector mapping, parameter table | ❌ Not started |
| 3. Results | 4 scenario outputs, figures 1–7, comparison table | ❌ Not started |
| 4. Discussion | Evaluate H1, policy implications, limitations | ❌ Not started |
| 5. Conclusion | Core findings, future research | ❌ Not started |

Target: ~8,000 words total. Format: likely LaTeX or Word depending on journal/course.

**Section 2 equations to write up:**

```
Wage dynamics:  Δw_SHK = (-γ₁ + γ₂·e) · w_{t-1} + 0.04·(L_gap/N_SHK) + κ·(1-σ)·gjg_premium·(L_gap/N_SHK)
Installation price:  p = (1+μ) · (w_SHK·N_SHK + w_semi·α·N_SHK)/Q + hardware
Inflation:  π_t = p_t/p_{t-1} - 1
Labour gap:  L_gap = Q_demand/θ - N_SHK_supply - σ·N_GJG
Credit rationing:  CR = max(0, (r_loan - r_neutral) · sensitivity)
```

---

## Recommended next session tasks

1. Fix Scenario B wage dynamics (add SHK-must-beat-GJG term)
2. Add calibration validation chart (model vs real BWP 2019–2024)
3. Download SHK vacancies + unemployment real CSVs (30 min)
4. Add sensitivity table (kappa × alpha_semi grid)
5. Start writing Section 2 (Methodology) using equations above
6. Start writing Section 3 (Results) using figures + 2034 summary table

---

## Model reference

Monasterolo, I. & Raberto, M. (2018). The EIRIN Flow-of-funds Behavioural Model of Green Fiscal Policies and Private Green Investment. *Ecological Economics*, 144, 228–243.

Supporting references:
- Dafermos, Nikolaidi & Galanis (2017). *Ecological Economics*, 131 — DEFINE 1.0
- Dafermos & Nikolaidi (2021). *Journal of Financial Stability*, 54 — DEFINE 1.1 (green capital requirements)
