library(ggplot2)
library(dplyr)
library(tidyr)

source("scenarios.R")  # loads results_all

# --- Palette and theme ---

scenario_colours <- c(
  "Baseline"   = "#2c7bb6",
  "Scenario A" = "#1a9641",
  "Scenario B" = "#fdae61",
  "Scenario C" = "#d7191c"
)

theme_paper <- theme_minimal(base_size = 11) +
  theme(
    legend.position  = "bottom",
    panel.grid.minor = element_blank(),
    strip.text       = element_text(face = "bold")
  )

dir.create("figures", showWarnings = FALSE)

# Helper: save 8x5 PNG at 300 dpi
save_fig <- function(p, path, h = 5) {
  ggsave(path, plot = p, width = 8, height = h, dpi = 300)
}

# -------------------------------------------------------------------------
# Fig 1: SHK market wage + GJG wage floor
# -------------------------------------------------------------------------

wages_long <- results_all %>%
  select(year, scenario, w_SHK, w_GJG) %>%
  pivot_longer(cols = c(w_SHK, w_GJG),
               names_to  = "wage_type",
               values_to = "wage") %>%
  filter(!(wage_type == "w_GJG" & wage == 0)) %>%  # drop zero GJG rows
  mutate(linetype = ifelse(wage_type == "w_SHK", "SHK Market Wage", "GJG Wage Floor"))

fig1 <- ggplot(wages_long, aes(x = year, y = wage,
                                colour = scenario, linetype = linetype)) +
  geom_line(linewidth = 0.8) +
  scale_colour_manual(values = scenario_colours, name = "Scenario") +
  scale_linetype_manual(values = c("SHK Market Wage" = "solid",
                                   "GJG Wage Floor"  = "dashed"),
                        name = "Wage series") +
  labs(title = "SHK Market Wage and GJG Wage Floor (2025–2034)",
       x = "Year", y = "Hourly Wage (€/hr)") +
  theme_paper

save_fig(fig1, "figures/fig1_wages.png")

# -------------------------------------------------------------------------
# Fig 2: Price index (2025 = 100)
# -------------------------------------------------------------------------

price_idx <- results_all %>%
  group_by(scenario) %>%
  mutate(price_idx = p_install / first(p_install) * 100) %>%
  ungroup()

fig2 <- ggplot(price_idx, aes(x = year, y = price_idx, colour = scenario)) +
  geom_hline(yintercept = 100, linetype = "dotted", colour = "grey50") +
  geom_line(linewidth = 0.8) +
  scale_colour_manual(values = scenario_colours, name = "Scenario") +
  labs(title = "Heat Pump Installation Price Index (2025 = 100)",
       x = "Year", y = "Price Index (2025 = 100)") +
  theme_paper

save_fig(fig2, "figures/fig2_price_index.png")

# -------------------------------------------------------------------------
# Fig 3: Sectoral inflation
# -------------------------------------------------------------------------

fig3 <- ggplot(results_all, aes(x = year, y = pi_sector * 100, colour = scenario)) +
  geom_hline(yintercept = 2, linetype = "dashed", colour = "grey50") +
  annotate("text", x = min(results_all$year) + 0.3, y = 2.3,
           label = "ECB 2% target", size = 3, colour = "grey40", hjust = 0) +
  geom_line(linewidth = 0.8) +
  scale_colour_manual(values = scenario_colours, name = "Scenario") +
  labs(title = "Sectoral Inflation Rate — Heat Pump Installation (%)",
       x = "Year", y = "Inflation Rate (%)") +
  theme_paper

save_fig(fig3, "figures/fig3_inflation.png")

# -------------------------------------------------------------------------
# Fig 4: Labour gap
# -------------------------------------------------------------------------

fig4 <- ggplot(results_all, aes(x = year, y = L_gap / 1000, colour = scenario)) +
  geom_line(linewidth = 0.8) +
  scale_colour_manual(values = scenario_colours, name = "Scenario") +
  labs(title = "SHK Technician Shortage Gap (thousands)",
       x = "Year", y = "Labour Gap (000s)") +
  theme_paper

save_fig(fig4, "figures/fig4_labour_gap.png")

# -------------------------------------------------------------------------
# Fig 5: Installations
# -------------------------------------------------------------------------

fig5 <- ggplot(results_all, aes(x = year, y = Q / 1000, colour = scenario)) +
  geom_hline(yintercept = 500, linetype = "dashed", colour = "grey50") +
  annotate("text", x = min(results_all$year) + 0.3, y = 510,
           label = "GEG 500k target", size = 3, colour = "grey40", hjust = 0) +
  geom_line(linewidth = 0.8) +
  scale_colour_manual(values = scenario_colours, name = "Scenario") +
  labs(title = "Annual Heat Pump Installations (thousands/yr)",
       x = "Year", y = "Installations (000s/yr)") +
  theme_paper

save_fig(fig5, "figures/fig5_installations.png")

# -------------------------------------------------------------------------
# Fig 6: Credit rationing rate
# -------------------------------------------------------------------------

fig6 <- ggplot(results_all, aes(x = year, y = CR * 100, colour = scenario)) +
  geom_line(linewidth = 0.8) +
  scale_colour_manual(values = scenario_colours, name = "Scenario") +
  labs(title = "Credit Rationing Rate (%)",
       x = "Year", y = "Credit Rationing (%)") +
  theme_paper

save_fig(fig6, "figures/fig6_credit.png")

# -------------------------------------------------------------------------
# Fig 7: Phase diagram — inflation vs installation volume
# -------------------------------------------------------------------------

# Identify start-of-path points (2025)
starts <- results_all %>% filter(year == min(year))

fig7 <- ggplot(results_all, aes(x = Q / 1000, y = pi_sector * 100, colour = scenario)) +
  # Shade stagflation zone: Q < 300k AND pi > 5%
  annotate("rect",
           xmin = -Inf, xmax = 300,
           ymin = 5,    ymax = Inf,
           fill = "red", alpha = 0.07) +
  annotate("text", x = 50, y = 7,
           label = "Stagflation zone", size = 3,
           colour = "darkred", hjust = 0, fontface = "italic") +
  # Paths with arrow at end
  geom_path(linewidth = 0.8,
            arrow = arrow(type = "closed", length = unit(0.18, "cm"))) +
  # Open circle for 2025 start
  geom_point(data = starts, shape = 21, fill = "white", size = 2.5) +
  scale_colour_manual(values = scenario_colours, name = "Scenario") +
  labs(title = "Phase Diagram: Sectoral Inflation vs Installation Volume",
       x = "Annual Installations (000s/yr)",
       y = "Sectoral Inflation (%)",
       caption = "Arrows show time direction (2025→2034). Open circles = 2025 start.") +
  theme_paper

save_fig(fig7, "figures/fig7_phase_diagram.png", h = 6)

cat("Figures saved to figures/\n")
