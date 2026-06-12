# mock_params.R
# Loads real CSV data and assembles the params list for simulation.R
# Sources: Destatis, BA Engpassanalyse 2023, EIRIN (Monasterolo & Raberto 2018)

library(readr)

# ---------------------------------------------------------------------------
# 1. Load CSVs (paths relative to project root; adjust working directory as
#    needed before sourcing this file)
# ---------------------------------------------------------------------------

heat_pump_sales       <- read_csv("data/heat_pump_sales.csv",       show_col_types = FALSE)
wages_construction    <- read_csv("data/wages_construction.csv",    show_col_types = FALSE)
minimum_wage          <- read_csv("data/minimum_wage.csv",          show_col_types = FALSE)
construction_price    <- read_csv("data/construction_price_index.csv", show_col_types = FALSE)

# ---------------------------------------------------------------------------
# 2. Extract key values from CSVs
# ---------------------------------------------------------------------------

# Heat pump installs 2025 baseline — column: hp_heating_total (BWP Absatzstatistik)
Q_0 <- heat_pump_sales$hp_heating_total[heat_pump_sales$year == 2025]
if (length(Q_0) == 0) Q_0 <- 299000

# SHK monthly wage (Destatis April 2024) — column: avg_monthly_gross_eur, sector: Construction
w_SHK_monthly_raw <- wages_construction$avg_monthly_gross_eur[
  wages_construction$year == 2024 & wages_construction$sector == "Construction"]
if (length(w_SHK_monthly_raw) == 0) w_SHK_monthly_raw <- 3970

# Minimum wages — column: min_wage_eur_hr
w_min_2025 <- minimum_wage$min_wage_eur_hr[minimum_wage$year == 2025]
w_min_2026 <- minimum_wage$min_wage_eur_hr[minimum_wage$year == 2026]
if (length(w_min_2025) == 0) w_min_2025 <- 12.82
if (length(w_min_2026) == 0) w_min_2026 <- 13.90

# Baseline sectoral inflation — column: yoy_change_pct, quarter stored as "Q4"
# Destatis bpr110: 3.1% for 2024 Q4; convert pct → decimal
pi_baseline_raw <- construction_price$yoy_change_pct[
  construction_price$year == 2024 & construction_price$quarter == "Q4"]
if (length(pi_baseline_raw) == 0 || is.na(pi_baseline_raw)) pi_baseline_raw <- 3.1
pi_baseline_raw <- pi_baseline_raw / 100   # 3.1 → 0.031

# ---------------------------------------------------------------------------
# 3. Derived parameters
# ---------------------------------------------------------------------------

# SHK hourly wage: monthly / (4.333 weeks * hours per week)
# Using 152 paid hours/month (Destatis standard for full-time)
annual_hours <- 1750
w_SHK_0 <- w_SHK_monthly_raw / (annual_hours / 12)   # ≈ €22.95/hr

# Labour supply and productivity
# N_SHK_supply_0: heat-pump-capable SHK workforce actually producing Q_0 (calibrated)
# L_gap_0: unfilled vacancies on top of current supply (BA Engpassanalyse 2023 ~20k)
N_SHK_supply_0 <- 45000
L_gap_0        <- 20000

# Leontief productivity: actual output / actual workers (Monasterolo & Raberto 2018, eq. 1)
productivity <- Q_0 / N_SHK_supply_0   # ≈ 6.64 installs/worker/yr

# Initial demand level (if no shortage, firms could absorb N_SHK_supply_0 + L_gap_0 workers)
Q_demand_0 <- (N_SHK_supply_0 + L_gap_0) * productivity   # ≈ 431k

# ---------------------------------------------------------------------------
# 4. Assemble params list
# ---------------------------------------------------------------------------

params <- list(

  # --- Real-data anchors ---------------------------------------------------
  Q_0               = Q_0,            # baseline installs/yr (heat_pump_sales.csv)
  w_SHK_0           = w_SHK_0,        # SHK hourly wage 2025 (wages_construction.csv)
  w_SHK_monthly_0   = w_SHK_monthly_raw,  # raw monthly for reference
  w_min_2025        = w_min_2025,     # minimum_wage.csv
  w_min_2026        = w_min_2026,     # minimum_wage.csv
  pi_baseline       = as.numeric(pi_baseline_raw),  # construction_price_index.csv

  # --- Calibrated parameters -----------------------------------------------
  N_SHK_supply_0    = N_SHK_supply_0,
  L_gap_0           = L_gap_0,
  productivity      = productivity,    # Q_0 / N_SHK_supply_0
  Q_demand_0        = Q_demand_0,      # demand at full supply+gap

  # Semi-skilled installation assistants: just below w_GJG_A (€12.82)
  # → GJG crowding activates immediately from year 1 in Scenarios A/B/C
  w_semi_0          = 12.00,
  hardware_cost_0   = 8000,    # €/unit heat pump hardware (market calibration)
  hardware_inflation = 0.025,  # 2.5%/yr hardware price growth

  N_SHK_supply_growth = 0.020, # 2%/yr training pipeline (calibrated)
  u_rate_0          = 0.055,   # German unemployment 2024 (Destatis)
  r_loan_0          = 0.045,   # SME construction lending rate 2024 (Bundesbank)

  kappa             = 0.8,     # crowding effect scalar (calibrated)
  # Semi-skilled helpers per certified SHK on installation jobs (calibrated)
  # Typical team: 1 SHK + 0.6 labourers. When GJG bids up w_semi, firm costs rise.
  alpha_semi        = 0.6,
  annual_hours      = annual_hours,

  tau               = 0.25,    # effective tax rate (GJG wage bill)

  # Credit rationing: driven by lending rate, not wage share
  # Neutral rate 3.5% (pre-2022 ECB baseline); sensitivity 8 → 1pp above neutral = 8% CR
  r_loan_neutral    = 0.035,
  cr_sensitivity    = 8.0,

  # Market demand ceiling: German housing stock replacement potential ~800k/yr
  # NOT the Scenario C policy mandate (which is 500k)
  Q_market_ceiling  = 800000,

  # --- EIRIN parameters (Monasterolo & Raberto 2018, Table 2) --------------
  mu                = 0.10,    # price markup
  CAR_min           = 0.10,    # minimum capital adequacy ratio (Basel II)
  gamma_1           = 0.018,   # Phillips curve intercept (EIRIN Table 2)
  gamma_2           = 0.020,   # Phillips curve slope on employment rate (EIRIN Table 2)

  # --- Demand growth (baseline market trend) --------------------------------
  # 5%/yr: conservative given BWP +55% in 2025, policy headwinds in 2024
  demand_growth_baseline = 0.05,

  # --- Scenario C mandate ceiling ------------------------------------------
  Q_target_C        = 500000,  # 500k installs/yr mandate (Scenario C)

  # --- GJG scenario parameters ---------------------------------------------
  # Scenario A: low-wage GJG, moderate substitution
  sigma_A           = 0.3,
  w_GJG_A           = 12.82,   # = w_min_2025
  N_GJG_scale_A     = 0.30,    # N_GJG = 0.30 * N_SHK_supply_0

  # Scenario B: high-wage GJG, higher substitution pressure
  sigma_B           = 0.5,
  w_GJG_B           = 19.00,
  N_GJG_scale_B     = 0.80,

  # Scenario C: mandate 500k installs, near-zero substitution → stagflation
  sigma_C           = 0.01,
  w_GJG_C           = 12.82,   # = w_min_2025
  N_GJG_scale_C     = 0.40
)

# Confirm key derived values (printed when file is sourced directly)
message(sprintf("w_SHK_0       = %.2f €/hr", params$w_SHK_0))
message(sprintf("productivity  = %.2f installs/worker/yr", params$productivity))
message(sprintf("pi_baseline   = %.1f%%", params$pi_baseline * 100))
