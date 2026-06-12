source("data/mock_params.R")
source("simulation.R")

T <- 10

# --- Run scenarios ---

res_baseline <- run_simulation(
  p             = params,
  scenario_name = "Baseline",
  w_GJG_vec     = rep(0, T),
  sigma         = 0,
  Q_mandate     = NA,
  gjg_scale     = 0,
  T             = T
)

res_A <- run_simulation(
  p             = params,
  scenario_name = "Scenario A",
  w_GJG_vec     = params$w_GJG_A * (1.025)^(0:(T - 1)),  # 2.5%/yr indexation
  sigma         = params$sigma_A,
  Q_mandate     = NA,
  gjg_scale     = params$N_GJG_scale_A,
  T             = T
)

res_B <- run_simulation(
  p             = params,
  scenario_name = "Scenario B",
  w_GJG_vec     = params$w_GJG_B * (1.03)^(0:(T - 1)),   # 3%/yr indexation
  sigma         = params$sigma_B,
  Q_mandate     = NA,
  gjg_scale     = params$N_GJG_scale_B,
  T             = T
)

res_C <- run_simulation(
  p             = params,
  scenario_name = "Scenario C",
  w_GJG_vec     = params$w_GJG_C * (1.025)^(0:(T - 1)),
  sigma         = params$sigma_C,
  Q_mandate     = params$Q_target_C,
  gjg_scale     = params$N_GJG_scale_C,
  T             = T
)

# --- Combine and set scenario as ordered factor ---

results_all <- rbind(res_baseline, res_A, res_B, res_C)
results_all$scenario <- factor(
  results_all$scenario,
  levels  = c("Baseline", "Scenario A", "Scenario B", "Scenario C"),
  ordered = TRUE
)

write.csv(results_all, "data/simulation_results.csv", row.names = FALSE)

# --- Summary table for 2034 (year 10) ---

r2034 <- results_all[results_all$year == max(results_all$year), ]

cat(sprintf("\n%-12s %10s %10s %12s %10s %8s %12s\n",
            "Scenario", "w_SHK", "Q (000s)", "pi_sector%", "L_gap", "CR%", "def_G (€bn)"))
cat(strrep("-", 78), "\n")

for (i in seq_len(nrow(r2034))) {
  row <- r2034[i, ]
  cat(sprintf("%-12s %10.2f %10.1f %12.1f %10.0f %8.1f %12.2f\n",
              as.character(row$scenario),
              row$w_SHK,
              row$Q / 1000,
              row$pi_sector * 100,
              row$L_gap,
              row$CR * 100,
              row$def_G))
}

cat("\nSimulation complete. Results in data/simulation_results.csv\n")
