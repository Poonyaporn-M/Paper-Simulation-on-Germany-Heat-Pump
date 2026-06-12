# simulation.R
# EIRIN-based Stock-Flow Consistent simulation of Germany's heat pump market.
# Reference: Monasterolo & Raberto (2018), Ecological Economics 144, 228–243.
#
# Scenarios:
#   Baseline : no GJG
#   A        : low-wage GJG  (w_GJG=12.82, sigma=0.3)
#   B        : high-wage GJG (w_GJG=19.00, sigma=0.5)
#   C        : 500k mandate  (w_GJG=12.82, sigma≈0, Q_mandate=500000)

run_simulation <- function(p, scenario_name, w_GJG_vec, sigma, Q_mandate = NA,
                           gjg_scale = 0, T = 10) {

  annual_hours           <- p$annual_hours
  productivity           <- p$productivity
  mu                     <- p$mu
  gamma_1                <- p$gamma_1
  gamma_2                <- p$gamma_2
  kappa                  <- p$kappa
  hardware_inflation     <- p$hardware_inflation
  supply_growth_SHK      <- p$N_SHK_supply_growth
  demand_growth_baseline <- p$demand_growth_baseline
  tau                    <- p$tau

  if (length(w_GJG_vec) < T)
    w_GJG_vec <- c(w_GJG_vec, rep(w_GJG_vec[length(w_GJG_vec)], T - length(w_GJG_vec)))
  w_GJG_vec <- w_GJG_vec[seq_len(T)]

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
  def_G      <- numeric(T)
  u_rate     <- numeric(T)
  r_loan     <- numeric(T)

  # -----------------------------------------------------------------------
  # t = 1 initialisation
  # -----------------------------------------------------------------------

  w_SHK[1]     <- p$w_SHK_0
  w_semi[1]    <- p$w_semi_0
  N_SHK_sup[1] <- p$N_SHK_supply_0
  u_rate[1]    <- p$u_rate_0
  r_loan[1]    <- p$r_loan_0
  hardware[1]  <- p$hardware_cost_0

  # Scenario C: demand = policy mandate; others: start from calibrated Q_demand_0
  Q_demand[1] <- if (!is.na(Q_mandate)) Q_mandate else p$Q_demand_0

  # Leontief: actual output = min(demand, workforce capacity)
  effective_workers_1 <- N_SHK_sup[1] + sigma * (p$N_SHK_supply_0 * gjg_scale)
  Q[1]         <- min(Q_demand[1], effective_workers_1 * productivity)

  N_GJG[1]     <- p$N_SHK_supply_0 * gjg_scale

  N_SHK_dem[1] <- Q_demand[1] / productivity
  L_gap[1]     <- max(0, N_SHK_dem[1] - N_SHK_sup[1] - sigma * N_GJG[1])

  N_SHK_eff_1          <- min(N_SHK_sup[1], N_SHK_dem[1])
  N_semi_eff_1         <- N_SHK_eff_1 * p$alpha_semi
  unit_labour_1        <- (w_SHK[1] * N_SHK_eff_1 + w_semi[1] * N_semi_eff_1) *
                          annual_hours / max(Q[1], 1)
  p_install[1]         <- (1 + mu) * (unit_labour_1 + hardware[1])
  pi_sector[1]         <- p$pi_baseline

  wage_bill_1          <- (w_SHK[1] * N_SHK_eff_1 + w_semi[1] * N_semi_eff_1) * annual_hours
  wage_share[1]        <- wage_bill_1 / (p_install[1] * max(Q[1], 1))

  # CR from lending rate spread above neutral (4.5% actual vs ~3.5% neutral)
  CR[1]    <- max(0, min(1, (r_loan[1] - p$r_loan_neutral) * p$cr_sensitivity))

  def_G[1] <- N_GJG[1] * w_GJG_vec[1] * annual_hours * (1 - tau) / 1e9  # store in €bn

  # -----------------------------------------------------------------------
  # Main loop t = 2 … T
  # -----------------------------------------------------------------------

  for (t in 2:T) {

    # SHK training pipeline
    N_SHK_sup[t] <- N_SHK_sup[t - 1] * (1 + supply_growth_SHK)

    # Unemployment (loose Phillips feedback from credit tightening)
    u_rate[t] <- max(0.03, u_rate[t - 1] - 0.003 + 0.002 * CR[t - 1])
    e_t        <- 1 - u_rate[t]

    # Base wage change: Phillips curve (EIRIN eq. 14, Table 2)
    delta_w_base <- -gamma_1 + gamma_2 * e_t

    # Scarcity premium: persistent SHK shortage drives wages above Phillips
    # 0.04 coefficient → ~1pp extra per 25% vacancy ratio; calibrated to
    # reproduce Destatis bpr110 baseline ~3%/yr inflation
    labour_pressure  <- L_gap[t - 1] / N_SHK_sup[t - 1]
    scarcity_premium <- 0.04 * labour_pressure

    # GJG crowding: w_GJG > w_semi → semi-skilled leave private sector
    # → SHK firms must bid up wages to retain/attract remaining helpers
    # (1-sigma): lower substitutability → more wage pressure on SHK market
    gjg_premium_ratio <- max(0, (w_GJG_vec[t] - w_semi[t - 1]) / w_SHK[t - 1])
    crowding_premium  <- kappa * (1 - sigma) * gjg_premium_ratio * labour_pressure

    w_SHK[t]  <- w_SHK[t - 1] * (1 + delta_w_base + scarcity_premium + crowding_premium)
    # w_semi adjusts gradually toward w_GJG (50% catch-up per year) to avoid
    # the one-period snap that caused N_GJG to spike then collapse
    w_semi_market  <- w_semi[t - 1] * (1 + delta_w_base)
    w_semi[t]      <- w_semi_market + 0.5 * max(0, w_GJG_vec[t] - w_semi_market)

    # GJG participation: smooth attraction proportional to wage premium over w_semi
    gjg_attraction <- max(0, (w_GJG_vec[t] - w_semi[t - 1]) / w_semi[t - 1])
    N_GJG[t]       <- p$N_SHK_supply_0 * gjg_scale * (1 + gjg_attraction)

    # Lending rate: rises with sectoral wage inflation (higher costs → riskier loans)
    # pi_sector[t-1] > ECB target adds spread; CR feeds back too
    r_loan[t] <- max(p$r_loan_neutral,
                     r_loan[t - 1] + 0.3 * max(0, pi_sector[t - 1] - 0.025) - 0.005 * (1 - CR[t-1]))

    # Installation demand
    if (!is.na(Q_mandate)) {
      Q_demand[t] <- Q_mandate
    } else {
      # Market demand grows 5%/yr; credit tightening reduces it
      Q_demand[t] <- Q_demand[t - 1] * (1 + demand_growth_baseline - CR[t - 1] * 0.4)
      Q_demand[t] <- min(Q_demand[t], p$Q_market_ceiling)
    }

    # Leontief supply constraint
    effective_workers <- N_SHK_sup[t] + sigma * N_GJG[t]
    Q[t]              <- min(Q_demand[t], effective_workers * productivity)

    # Labour demand from what firms *want* (Q_demand)
    # Gap accounts for GJG substitution: sigma*N_GJG partially fills certified need
    N_SHK_dem[t] <- Q_demand[t] / productivity
    L_gap[t]     <- max(0, N_SHK_dem[t] - N_SHK_sup[t] - sigma * N_GJG[t])

    # Unit cost: SHK firms employ certified technicians AND private semi-skilled helpers.
    # GJG wages are govt expenditure (not firm cost), but w_semi rises because GJG
    # competes for the same pool → private helpers get more expensive (the crowding channel).
    # alpha_semi = semi-skilled helpers per certified SHK (calibrated 0.6)
    N_SHK_eff            <- min(N_SHK_sup[t], N_SHK_dem[t])
    N_semi_eff           <- N_SHK_eff * p$alpha_semi
    unit_labour          <- (w_SHK[t] * N_SHK_eff + w_semi[t] * N_semi_eff) *
                            annual_hours / max(Q[t], 1)
    hardware[t]          <- hardware[t - 1] * (1 + hardware_inflation)
    p_install[t]         <- (1 + mu) * (unit_labour + hardware[t])

    pi_sector[t] <- (p_install[t] / p_install[t - 1]) - 1

    # Wage share (total labour bill / revenue)
    wage_bill    <- (w_SHK[t] * N_SHK_eff + w_semi[t] * N_semi_eff) * annual_hours
    wage_share[t] <- wage_bill / (p_install[t] * max(Q[t], 1))
    CR[t]         <- max(0, min(1, (r_loan[t] - p$r_loan_neutral) * p$cr_sensitivity))

    def_G[t] <- N_GJG[t] * w_GJG_vec[t] * annual_hours * (1 - tau) / 1e9  # €bn
  }

  data.frame(
    year       = seq(2025, by = 1, length.out = T),
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

run_all_scenarios <- function(p, T = 10) {
  baseline <- run_simulation(p, "Baseline",   rep(0, T),                          0,          NA,              0,                   T)
  scen_A   <- run_simulation(p, "Scenario A", p$w_GJG_A * (1.025)^(0:(T-1)),     p$sigma_A,  NA,              p$N_GJG_scale_A,     T)
  scen_B   <- run_simulation(p, "Scenario B", p$w_GJG_B * (1.030)^(0:(T-1)),     p$sigma_B,  NA,              p$N_GJG_scale_B,     T)
  scen_C   <- run_simulation(p, "Scenario C", p$w_GJG_C * (1.025)^(0:(T-1)),     p$sigma_C,  p$Q_target_C,   p$N_GJG_scale_C,     T)
  rbind(baseline, scen_A, scen_B, scen_C)
}
