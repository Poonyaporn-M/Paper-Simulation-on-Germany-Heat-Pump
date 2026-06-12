# =============================================================================
# simulation.R
# EIRIN-based simulation: GJG sectoral inflation, Germany heat pump market
# Monasterolo & Raberto (2018), Ecological Economics 144, 228-243
#
# HOW TO RUN: source("simulation.R")  -- this file runs everything end-to-end
# OUTPUT: results_all data frame + data/simulation_results.csv + figures/
# =============================================================================

library(readr)
library(ggplot2)
library(dplyr)
library(tidyr)

# =============================================================================
# STEP 1: LOAD REAL DATA
# =============================================================================

heat_pump_sales    <- read_csv("data/heat_pump_sales.csv",          show_col_types = FALSE)
wages_construction <- read_csv("data/wages_construction.csv",       show_col_types = FALSE)
minimum_wage       <- read_csv("data/minimum_wage.csv",             show_col_types = FALSE)
construction_price <- read_csv("data/construction_price_index.csv", show_col_types = FALSE)

# =============================================================================
# STEP 2: EXTRACT VALUES FROM CSVs
# =============================================================================

# BWP 2025: 299,000 heat pump installs
Q_0 <- heat_pump_sales$hp_heating_total[heat_pump_sales$year == 2025]
if (length(Q_0) == 0) Q_0 <- 299000

# Destatis April 2024: construction sector monthly wage
w_SHK_monthly <- wages_construction$avg_monthly_gross_eur[
  wages_construction$year == 2024 & wages_construction$sector == "Construction"]
if (length(w_SHK_monthly) == 0) w_SHK_monthly <- 3970

# BMAS minimum wage
w_min_2025 <- minimum_wage$min_wage_eur_hr[minimum_wage$year == 2025]
w_min_2026 <- minimum_wage$min_wage_eur_hr[minimum_wage$year == 2026]
if (length(w_min_2025) == 0) w_min_2025 <- 12.82
if (length(w_min_2026) == 0) w_min_2026 <- 13.90

# Destatis bpr110: construction price inflation 2024 Q4 = 3.1%
pi_raw <- construction_price$yoy_change_pct[
  construction_price$year == 2024 & construction_price$quarter == "Q4"]
if (length(pi_raw) == 0 || is.na(pi_raw)) pi_raw <- 3.1
pi_baseline <- pi_raw / 100   # 3.1 -> 0.031

# =============================================================================
# STEP 3: SET ALL PARAMETERS
# =============================================================================

T            <- 10          # simulation years: 2025-2034
annual_hours <- 1750        # paid hours per worker per year

# --- Labour market (calibrated from BA Engpassanalyse 2023) ---
N_SHK_supply_0    <- 45000  # heat-pump-capable SHK workforce
L_gap_0           <- 20000  # initial unfilled vacancies
productivity      <- Q_0 / N_SHK_supply_0        # ~6.64 installs/worker/yr
Q_demand_0        <- (N_SHK_supply_0 + L_gap_0) * productivity  # ~432k

# --- Wages ---
w_SHK_0           <- w_SHK_monthly / (annual_hours / 12)  # monthly -> hourly ~27.22
w_semi_0          <- 12.00   # semi-skilled helpers: just below GJG_A floor (12.82)
alpha_semi        <- 0.6     # semi-skilled helpers per certified SHK on job site

# --- EIRIN model parameters (Monasterolo & Raberto 2018, Table 2) ---
mu                <- 0.10    # markup rate
gamma_1           <- 0.018   # Phillips curve intercept
gamma_2           <- 0.020   # Phillips curve slope (employment rate)
kappa             <- 0.8     # GJG crowding effect scalar

# --- Costs and finance ---
hardware_cost_0   <- 8000    # EUR per unit (heat pump hardware)
hardware_inflation <- 0.025  # 2.5%/yr
r_loan_0          <- 0.045   # construction SME lending rate 2024 (Bundesbank)
r_loan_neutral    <- 0.035   # pre-2022 ECB neutral rate
cr_sensitivity    <- 8.0     # 1pp above neutral = 8% credit rationing
tau               <- 0.25    # effective tax rate on GJG wage bill

# --- Labour supply and demand growth ---
N_SHK_supply_growth    <- 0.020   # 2%/yr training pipeline
demand_growth_baseline <- 0.050   # 5%/yr market demand growth
Q_market_ceiling       <- 800000  # theoretical max (German housing stock)

# --- Scenario GJG parameters ---
# Scenario A: low-wage GJG, low substitution (sigma=0.3)
w_GJG_A      <- 12.82   # = 2025 minimum wage
sigma_A      <- 0.3
N_GJG_scaleA <- 0.30    # N_GJG = scale * N_SHK_supply_0

# Scenario B: high-wage GJG, moderate substitution (sigma=0.5)
w_GJG_B      <- 19.00
sigma_B      <- 0.5
N_GJG_scaleB <- 0.80

# Scenario C: 500k mandate, near-zero substitution -> stagflation
w_GJG_C      <- 12.82
sigma_C      <- 0.01
N_GJG_scaleC <- 0.40
Q_target_C   <- 500000

message(sprintf("w_SHK_0      = %.2f EUR/hr", w_SHK_0))
message(sprintf("productivity = %.2f installs/worker/yr", productivity))
message(sprintf("pi_baseline  = %.1f%%", pi_baseline * 100))

# =============================================================================
# STEP 4: RUN EACH SCENARIO
# Flat loop per scenario - no functions, easy to read and modify
# =============================================================================

run_one_scenario <- function(scenario_name, w_GJG_vec, sigma, Q_mandate, gjg_scale) {

  # pre-allocate state vectors
  w_SHK      <- numeric(T)
  w_semi     <- numeric(T)
  N_SHK_sup  <- numeric(T)
  N_SHK_dem  <- numeric(T)
  N_GJG      <- numeric(T)
  Q          <- numeric(T)
  Q_demand   <- numeric(T)
  hardware   <- numeric(T)
  p_install  <- numeric(T)
  pi_sector  <- numeric(T)
  L_gap      <- numeric(T)
  wage_share <- numeric(T)
  CR         <- numeric(T)
  r_loan     <- numeric(T)
  def_G      <- numeric(T)
  u_rate     <- numeric(T)

  # --- t = 1: initialise year 2025 ---
  w_SHK[1]     <- w_SHK_0
  w_semi[1]    <- w_semi_0
  N_SHK_sup[1] <- N_SHK_supply_0
  u_rate[1]    <- 0.055          # German unemployment 2024 (Destatis)
  r_loan[1]    <- r_loan_0
  hardware[1]  <- hardware_cost_0
  N_GJG[1]     <- N_SHK_supply_0 * gjg_scale

  Q_demand[1]  <- if (!is.na(Q_mandate)) Q_mandate else Q_demand_0
  Q[1]         <- min(Q_demand[1], (N_SHK_sup[1] + sigma * N_GJG[1]) * productivity)

  N_SHK_dem[1] <- Q_demand[1] / productivity
  L_gap[1]     <- max(0, N_SHK_dem[1] - N_SHK_sup[1] - sigma * N_GJG[1])

  N_SHK_eff_1  <- min(N_SHK_sup[1], N_SHK_dem[1])
  N_semi_eff_1 <- N_SHK_eff_1 * alpha_semi
  unit_lab_1   <- (w_SHK[1] * N_SHK_eff_1 + w_semi[1] * N_semi_eff_1) * annual_hours / max(Q[1], 1)
  p_install[1] <- (1 + mu) * (unit_lab_1 + hardware[1])
  pi_sector[1] <- pi_baseline

  wage_bill_1  <- (w_SHK[1] * N_SHK_eff_1 + w_semi[1] * N_semi_eff_1) * annual_hours
  wage_share[1] <- wage_bill_1 / (p_install[1] * max(Q[1], 1))
  CR[1]        <- max(0, min(1, (r_loan[1] - r_loan_neutral) * cr_sensitivity))
  def_G[1]     <- N_GJG[1] * w_GJG_vec[1] * annual_hours * (1 - tau) / 1e9

  # --- t = 2 to T: main loop ---
  for (t in 2:T) {

    # SHK training pipeline grows 2%/yr
    N_SHK_sup[t] <- N_SHK_sup[t-1] * (1 + N_SHK_supply_growth)

    # Unemployment: falls slowly, rises with credit tightening
    u_rate[t] <- max(0.03, u_rate[t-1] - 0.003 + 0.002 * CR[t-1])
    e_t        <- 1 - u_rate[t]

    # Phillips curve base wage change (EIRIN eq. 14, Table 2)
    delta_w_base <- -gamma_1 + gamma_2 * e_t

    # Scarcity premium: SHK shortage bids wages above Phillips
    # 0.04 calibrated to reproduce Destatis bpr110 ~3%/yr baseline inflation
    labour_pressure  <- L_gap[t-1] / N_SHK_sup[t-1]
    scarcity_premium <- 0.04 * labour_pressure

    # GJG crowding: w_GJG > w_semi -> semi-skilled workers leave private sector
    # SHK firms compete for remaining pool -> wages bid up
    # (1-sigma): less substitutability = more wage pressure
    gjg_premium      <- max(0, (w_GJG_vec[t] - w_semi[t-1]) / w_SHK[t-1])
    crowding_premium <- kappa * (1 - sigma) * gjg_premium * labour_pressure

    w_SHK[t] <- w_SHK[t-1] * (1 + delta_w_base + scarcity_premium + crowding_premium)

    # w_semi: gradual 50% catch-up toward w_GJG (avoids one-period spike/collapse)
    w_semi_market <- w_semi[t-1] * (1 + delta_w_base)
    w_semi[t]     <- w_semi_market + 0.5 * max(0, w_GJG_vec[t] - w_semi_market)

    # GJG workers: base + attraction bonus when w_GJG beats w_semi
    gjg_attraction <- max(0, (w_GJG_vec[t] - w_semi[t-1]) / w_semi[t-1])
    N_GJG[t]       <- N_SHK_supply_0 * gjg_scale * (1 + gjg_attraction)

    # Lending rate rises when sectoral inflation exceeds ECB 2% target
    r_loan[t] <- max(r_loan_neutral,
                     r_loan[t-1] + 0.3 * max(0, pi_sector[t-1] - 0.025) - 0.005 * (1 - CR[t-1]))

    # Installation demand (market) or mandate (Scenario C)
    if (!is.na(Q_mandate)) {
      Q_demand[t] <- Q_mandate
    } else {
      Q_demand[t] <- Q_demand[t-1] * (1 + demand_growth_baseline - CR[t-1] * 0.4)
      Q_demand[t] <- min(Q_demand[t], Q_market_ceiling)
    }

    # Leontief supply cap: output = min(demand, what workforce can actually produce)
    Q[t] <- min(Q_demand[t], (N_SHK_sup[t] + sigma * N_GJG[t]) * productivity)

    # Labour demand from desired Q; gap = unfilled certified-tech need
    N_SHK_dem[t] <- Q_demand[t] / productivity
    L_gap[t]     <- max(0, N_SHK_dem[t] - N_SHK_sup[t] - sigma * N_GJG[t])

    # Unit cost: SHK firm pays certified techs + private semi-skilled helpers
    # GJG wages are GOVERNMENT cost (not here); but w_semi rises -> firm helpers cost more
    N_SHK_eff  <- min(N_SHK_sup[t], N_SHK_dem[t])
    N_semi_eff <- N_SHK_eff * alpha_semi
    unit_lab   <- (w_SHK[t] * N_SHK_eff + w_semi[t] * N_semi_eff) * annual_hours / max(Q[t], 1)

    hardware[t]  <- hardware[t-1] * (1 + hardware_inflation)
    p_install[t] <- (1 + mu) * (unit_lab + hardware[t])

    pi_sector[t] <- (p_install[t] / p_install[t-1]) - 1

    wage_bill     <- (w_SHK[t] * N_SHK_eff + w_semi[t] * N_semi_eff) * annual_hours
    wage_share[t] <- wage_bill / (p_install[t] * max(Q[t], 1))
    CR[t]         <- max(0, min(1, (r_loan[t] - r_loan_neutral) * cr_sensitivity))

    def_G[t] <- N_GJG[t] * w_GJG_vec[t] * annual_hours * (1 - tau) / 1e9  # EUR bn
  }

  data.frame(
    year       = 2025:(2024 + T),
    scenario   = scenario_name,
    w_SHK      = w_SHK,
    w_GJG      = w_GJG_vec,
    w_semi     = w_semi,
    N_SHK_sup  = N_SHK_sup,
    N_SHK_dem  = N_SHK_dem,
    N_GJG      = N_GJG,
    Q          = Q,
    Q_demand   = Q_demand,
    p_install  = p_install,
    pi_sector  = pi_sector,
    L_gap      = L_gap,
    CR         = CR,
    r_loan     = r_loan,
    def_G      = def_G,
    wage_share = wage_share,
    stringsAsFactors = FALSE
  )
}

# --- Baseline: no GJG ---
res_baseline <- run_one_scenario(
  scenario_name = "Baseline",
  w_GJG_vec     = rep(0, T),
  sigma         = 0,
  Q_mandate     = NA,
  gjg_scale     = 0
)

# --- Scenario A: low wage GJG (min wage), low substitution ---
res_A <- run_one_scenario(
  scenario_name = "Scenario A",
  w_GJG_vec     = w_GJG_A * (1.025)^(0:(T-1)),   # 2.5%/yr indexation
  sigma         = sigma_A,
  Q_mandate     = NA,
  gjg_scale     = N_GJG_scaleA
)

# --- Scenario B: high wage GJG (EUR 19/hr), moderate substitution ---
res_B <- run_one_scenario(
  scenario_name = "Scenario B",
  w_GJG_vec     = w_GJG_B * (1.030)^(0:(T-1)),   # 3%/yr indexation
  sigma         = sigma_B,
  Q_mandate     = NA,
  gjg_scale     = N_GJG_scaleB
)

# --- Scenario C: 500k mandate, near-zero substitution -> stagflation ---
res_C <- run_one_scenario(
  scenario_name = "Scenario C",
  w_GJG_vec     = w_GJG_C * (1.025)^(0:(T-1)),
  sigma         = sigma_C,
  Q_mandate     = Q_target_C,
  gjg_scale     = N_GJG_scaleC
)

# =============================================================================
# STEP 5: COMBINE AND SAVE RESULTS
# =============================================================================

results_all <- rbind(res_baseline, res_A, res_B, res_C)
results_all$scenario <- factor(results_all$scenario,
  levels = c("Baseline", "Scenario A", "Scenario B", "Scenario C"), ordered = TRUE)

write.csv(results_all, "data/simulation_results.csv", row.names = FALSE)

# --- 2034 summary table ---
r2034 <- results_all[results_all$year == 2034, ]
cat(sprintf("\n%-12s %10s %10s %12s %10s %8s %12s\n",
            "Scenario", "w_SHK", "Q (000s)", "pi_sector%", "L_gap", "CR%", "def_G (EURbn)"))
cat(strrep("-", 80), "\n")
for (i in 1:nrow(r2034)) {
  row <- r2034[i, ]
  cat(sprintf("%-12s %10.2f %10.1f %12.1f %10.0f %8.1f %12.2f\n",
    as.character(row$scenario), row$w_SHK, row$Q/1000,
    row$pi_sector*100, row$L_gap, row$CR*100, row$def_G))
}
cat("\nResults saved to data/simulation_results.csv\n")

# =============================================================================
# STEP 6: GENERATE ALL 7 FIGURES
# =============================================================================

scenario_colours <- c(
  "Baseline"   = "#2c7bb6",
  "Scenario A" = "#1a9641",
  "Scenario B" = "#fdae61",
  "Scenario C" = "#d7191c"
)

year_breaks <- 2025:2034

theme_paper <- theme_minimal(base_size = 11) +
  theme(legend.position = "bottom", panel.grid.minor = element_blank(),
        strip.text = element_text(face = "bold"))

dir.create("figures", showWarnings = FALSE)

save_fig <- function(p, path, h = 5) {
  ggsave(path, plot = p, width = 8, height = h, dpi = 300)
}

# Fig 1: Wages
wages_long <- results_all %>%
  select(year, scenario, w_SHK, w_GJG) %>%
  pivot_longer(cols = c(w_SHK, w_GJG), names_to = "wage_type", values_to = "wage") %>%
  filter(!(wage_type == "w_GJG" & wage == 0)) %>%
  mutate(linetype = ifelse(wage_type == "w_SHK", "SHK Market Wage", "GJG Wage Floor"))

fig1 <- ggplot(wages_long, aes(x = year, y = wage, colour = scenario, linetype = linetype)) +
  geom_line(linewidth = 0.8) +
  scale_colour_manual(values = scenario_colours, name = "Scenario") +
  scale_linetype_manual(values = c("SHK Market Wage" = "solid", "GJG Wage Floor" = "dashed"),
                        name = "Wage series") +
  scale_x_continuous(breaks = year_breaks) +
  labs(title = "SHK Market Wage and GJG Wage Floor (2025-2034)",
       x = "Year", y = "Hourly Wage (EUR/hr)") + theme_paper
save_fig(fig1, "figures/fig1_wages.png")

# Fig 2: Price index (2025 = 100)
price_idx <- results_all %>%
  group_by(scenario) %>%
  mutate(price_idx = p_install / first(p_install) * 100) %>%
  ungroup()

fig2 <- ggplot(price_idx, aes(x = year, y = price_idx, colour = scenario)) +
  geom_hline(yintercept = 100, linetype = "dotted", colour = "grey50") +
  geom_line(linewidth = 0.8) +
  scale_colour_manual(values = scenario_colours, name = "Scenario") +
  scale_x_continuous(breaks = year_breaks) +
  labs(title = "Heat Pump Installation Price Index (2025 = 100)",
       x = "Year", y = "Price Index") + theme_paper
save_fig(fig2, "figures/fig2_price_index.png")

# Fig 3: Inflation
fig3 <- ggplot(results_all, aes(x = year, y = pi_sector * 100, colour = scenario)) +
  geom_hline(yintercept = 2, linetype = "dashed", colour = "grey50") +
  annotate("text", x = 2026, y = 2.15, label = "ECB 2% target",
           size = 3, colour = "grey40", hjust = 0) +
  geom_line(linewidth = 0.8) +
  scale_colour_manual(values = scenario_colours, name = "Scenario") +
  scale_x_continuous(breaks = year_breaks) +
  labs(title = "Sectoral Inflation Rate - Heat Pump Installation (%)",
       x = "Year", y = "Inflation (%)") + theme_paper
save_fig(fig3, "figures/fig3_inflation.png")

# Fig 4: Labour gap
fig4 <- ggplot(results_all, aes(x = year, y = L_gap / 1000, colour = scenario)) +
  geom_line(linewidth = 0.8) +
  scale_colour_manual(values = scenario_colours, name = "Scenario") +
  scale_x_continuous(breaks = year_breaks) +
  labs(title = "SHK Technician Shortage Gap (thousands)",
       x = "Year", y = "Labour Gap (000s)") + theme_paper
save_fig(fig4, "figures/fig4_labour_gap.png")

# Fig 5: Installations vs 500k target
fig5 <- ggplot(results_all, aes(x = year, y = Q / 1000, colour = scenario)) +
  geom_hline(yintercept = 500, linetype = "dashed", colour = "grey50") +
  annotate("text", x = 2026, y = 508, label = "GEG 500k target",
           size = 3, colour = "grey40", hjust = 0) +
  geom_line(linewidth = 0.8) +
  scale_colour_manual(values = scenario_colours, name = "Scenario") +
  scale_x_continuous(breaks = year_breaks) +
  labs(title = "Annual Heat Pump Installations (thousands/yr)",
       x = "Year", y = "Installations (000s/yr)") + theme_paper
save_fig(fig5, "figures/fig5_installations.png")

# Fig 6: Credit rationing
fig6 <- ggplot(results_all, aes(x = year, y = CR * 100, colour = scenario)) +
  geom_line(linewidth = 0.8) +
  scale_colour_manual(values = scenario_colours, name = "Scenario") +
  scale_x_continuous(breaks = year_breaks) +
  labs(title = "Credit Rationing Rate (%)", x = "Year", y = "CR (%)") + theme_paper
save_fig(fig6, "figures/fig6_credit.png")

# Fig 7: Phase diagram (stagflation check)
starts <- results_all %>% filter(year == 2025)

fig7 <- ggplot(results_all, aes(x = Q / 1000, y = pi_sector * 100, colour = scenario)) +
  annotate("rect", xmin = -Inf, xmax = 300, ymin = 5, ymax = Inf,
           fill = "red", alpha = 0.07) +
  annotate("text", x = 50, y = 7, label = "Stagflation zone",
           size = 3, colour = "darkred", hjust = 0, fontface = "italic") +
  geom_path(linewidth = 0.8, arrow = arrow(type = "closed", length = unit(0.18, "cm"))) +
  geom_point(data = starts, shape = 21, fill = "white", size = 2.5) +
  scale_colour_manual(values = scenario_colours, name = "Scenario") +
  labs(title = "Phase Diagram: Sectoral Inflation vs Installation Volume",
       x = "Annual Installations (000s/yr)", y = "Sectoral Inflation (%)",
       caption = "Arrows show time direction (2025->2034). Open circles = 2025 start.") +
  theme_paper
save_fig(fig7, "figures/fig7_phase_diagram.png", h = 6)

cat("Figures saved to figures/\n")
