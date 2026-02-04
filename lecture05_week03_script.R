# ============================================================================
# Lecture 05 - Week 03: CRD Advanced - Contrasts and Multiple Comparisons
# AGST 50104 Experimental Design | Spring 2026
# Dr. Samuel B Fernandes
# ============================================================================

# PACKAGE LOADING ============================================================
# Note: Install packages if needed with install.packages("package_name")

# Data manipulation and transformation
library(dplyr)      # Data manipulation (filter, mutate, summarize, select)
library(tidyr)      # Data tidying (pivot, separate, unite)

# Visualization
library(ggplot2)    # Grammar of graphics plotting system
library(see)        # Visualization companion for easystats (optional)

# String manipulation
library(stringr)    # String operations (str_trim, str_detect, etc.)

# Statistical analysis - Estimated marginal means and contrasts
library(emmeans)    # Estimated marginal means, contrasts, and comparisons

# Agricultural datasets
library(agridat)    # Collection of agricultural datasets for teaching

# Model utilities
library(broom)      # Convert statistical objects to tidy data frames

# Multiple comparisons
library(multcomp)   # Simultaneous inference (compact letter displays)

# Tidyverse-friendly statistical tests
library(rstatix)    # Pipe-friendly wrapper for statistical tests

# Publication-ready plots with automated annotations
library(ggpubr)     # ggplot2-based publication-ready plots

# easystats ecosystem - modern statistical reporting
library(performance) # Model quality assessment and diagnostics
library(parameters)  # Extract and format model parameters
library(effectsize)  # Calculate and interpret effect sizes
library(report)      # Automated statistical reporting

# Set random seed for reproducibility
set.seed(2026)

# Increase expression limit for complex operations
options(expressions = 5000)

# Set default ggplot2 theme
theme_set(theme_minimal() +
    theme(
        plot.title = element_text(size = 16, face = "bold"),
        axis.title = element_text(size = 13),
        axis.text = element_text(size = 11)
    ))


# DIAGNOSTIC PLOTS: EXAMPLE WITH APPLE DATA ==================================

# Load apple variety trial data
data(archbold.apple, package = "agridat")
apple <- archbold.apple |>
    mutate(gen = as.factor(gen))

# Fit CRD model
model_apple <- lm(yield ~ gen, data = apple)

# Create diagnostic plots
par(mfrow = c(2, 2))
plot(model_apple)
par(mfrow = c(1, 1))


# RADON RELEASE EXPERIMENT (REAL DATA) =======================================

# Load radon data from GitHub
radon_url <- "https://raw.githubusercontent.com/Jaisai0611/CRD-example/main/EX%203.21.csv"
radon_data <- read.csv(radon_url) |>
    mutate(
        orifice = factor(Orifice.Diameter,
            levels = sort(unique(Orifice.Diameter))
        )
    ) |>
    pivot_longer(
        cols = starts_with("Radon"),
        names_to = "sample",
        values_to = "response"
    ) |>
    select(orifice, -sample, response) |>
    filter(!is.na(response))

# Summary statistics by orifice size
radon_data |>
    group_by(orifice) |>
    summarize(
        n = n(),
        mean = mean(response)
    ) |>
    knitr::kable(digits = 1)

# Visualize treatment effects
ggplot(radon_data, aes(x = orifice, y = response, fill = orifice)) +
    geom_boxplot(alpha = 0.7, outlier.shape = NA) +
    geom_jitter(width = 0.15, alpha = 0.5, size = 2.5) +
    labs(
        title = "Radon Release by Orifice Diameter",
        x = "Orifice Diameter (mm)",
        y = "Radon Released (%)",
        fill = "Orifice (mm)"
    ) +
    scale_fill_viridis_d(option = "plasma") +
    theme_minimal() +
    theme(
        text = element_text(size = 14),
        legend.position = "none"
    )

# Fit CRD model for radon data
model_radon <- lm(response ~ orifice, data = radon_data)

# ANOVA table
anova(model_radon)

# Model coefficients
summary(model_radon)

# Diagnostic plots
par(mfrow = c(2, 2), mar = c(4, 4, 2, 2))
plot(model_radon)
par(mfrow = c(1, 1))

# Estimated marginal means
emm_radon <- emmeans(model_radon, ~orifice)
emm_radon

# Tukey HSD using base R
TukeyHSD(aov(response ~ orifice, data = radon_data))

# Plot EMMs with confidence intervals
plot(emm_radon, comparisons = TRUE) +
    labs(
        title = "Estimated Marginal Means: Radon Release",
        x = "Radon Released (%)",
        y = "Orifice Diameter (mm)"
    ) +
    theme_minimal() +
    theme(text = element_text(size = 13))


# NPK FERTILIZER TRIAL (SIMULATED DATA) ======================================

# Create simulated NPK application data
set.seed(2026)
npk_data <- data.frame(
    treatment = factor(rep(c("Control", "Jan_Plow", "Jan_Broadcast", "Apr_Broadcast"), each = 8),
        levels = c("Control", "Jan_Plow", "Jan_Broadcast", "Apr_Broadcast")
    ),
    block = factor(rep(1:8, 4)),
    yield = c(
        rnorm(8, 45, 5), # Control: lower yield
        rnorm(8, 62, 5), # Jan plowed: best
        rnorm(8, 58, 5), # Jan broadcast: good
        rnorm(8, 55, 6)  # Apr broadcast: moderate
    )
)

# Summary by treatment
npk_data |>
    group_by(treatment) |>
    summarize(
        n = n(),
        mean = mean(yield),
        sd = sd(yield),
        .groups = "drop"
    ) |>
    knitr::kable(digits = 1)

# Visualize NPK trial data
ggplot(npk_data, aes(x = treatment, y = yield, fill = treatment)) +
    geom_boxplot(alpha = 0.7) +
    geom_jitter(width = 0.15, alpha = 0.5, size = 2.5) +
    labs(
        title = "Effect of NPK Application Method on Crop Yield",
        x = "Treatment",
        y = "Yield (bushels/acre)",
        fill = "Treatment"
    ) +
    scale_fill_viridis_d(option = "plasma") +
    theme_minimal() +
    theme(
        text = element_text(size = 14),
        axis.text.x = element_text(angle = 30, hjust = 1),
        legend.position = "none"
    )


# PLANNED CONTRASTS ===========================================================

# Fit CRD model
model_npk <- lm(yield ~ treatment, data = npk_data)

# Get estimated marginal means
emm_npk <- emmeans(model_npk, ~treatment)

# Define contrasts as a list
contrast_list <- list(
    "Control vs NPK" = c(3, -1, -1, -1) / 3,     # Divide to get average
    "Jan vs Apr" = c(0, 1, 1, -2) / 2,           # Compare averages
    "Plow vs Broadcast" = c(0, 1, -1, 0)         # Simple comparison
)

# Test contrasts
contrast_results <- contrast(emm_npk, contrast_list)
print(contrast_results)

# With confidence intervals
confint(contrast_results)

# Visualize contrast results
contrast_df <- confint(contrast_results) |> as.data.frame()
if (!all(c("lower.CL", "upper.CL") %in% names(contrast_df))) {
    contrast_df <- contrast_df |>
        mutate(
            lower.CL = estimate - 1.96 * SE,
            upper.CL = estimate + 1.96 * SE
        )
}

contrast_df |>
    ggplot(aes(x = contrast, y = estimate)) +
    geom_point(size = 4, color = "steelblue") +
    geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL),
        width = 0.2, linewidth = 1.2, color = "steelblue"
    ) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "red", linewidth = 0.8) +
    coord_flip() +
    labs(
        title = "Planned Contrasts: NPK Application Methods",
        x = "Contrast",
        y = "Effect Size (bushels/acre)",
        caption = "Error bars show 95% confidence intervals. Red line at zero = no effect."
    ) +
    theme_minimal() +
    theme(text = element_text(size = 13))


# TUKEY HSD WITH COMPACT LETTER DISPLAY ======================================

# Pairwise comparisons with Tukey adjustment
tukey_results <- pairs(emm_npk, adjust = "tukey")
tukey_results

# Compact letter display (CLD)
cld_tukey <- cld(emm_npk, adjust = "tukey", Letters = letters)
cld_tukey |>
    as.data.frame() |>
    knitr::kable(digits = 1)

# Visualize Tukey results with compact letters
cld_df <- cld_tukey |>
    as.data.frame() |>
    mutate(treatment = factor(treatment, levels = treatment))

ggplot(cld_df, aes(x = treatment, y = emmean)) +
    geom_point(size = 5, color = "darkgreen") +
    geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL),
        width = 0.3, linewidth = 1.2, color = "darkgreen"
    ) +
    geom_text(aes(label = str_trim(.group)),
        vjust = -1.5, size = 5, fontface = "bold", color = "red"
    ) +
    labs(
        title = "NPK Treatment Effects with Tukey Groupings",
        x = "Treatment",
        y = "Estimated Mean Yield (bushels/acre)"
    ) +
    scale_y_continuous(limits = c(40, 72)) +
    theme_minimal() +
    theme(
        text = element_text(size = 12),
        axis.text.x = element_text(angle = 30, hjust = 1)
    )


# DUNNETT'S TEST ==============================================================

# Dunnett's test: all treatments vs Control
# Control must be the reference level (first level of factor)
dunnett_results <- contrast(emm_npk, method = "trt.vs.ctrl", adjust = "dunnett")
dunnett_results |>
    as.data.frame() |>
    knitr::kable(digits = 2)

# With confidence intervals
confint(dunnett_results) |>
    as.data.frame() |>
    knitr::kable(digits = 2)


# RSTATIX: TIDY WORKFLOWS =====================================================

# emmeans_test() - pipe-friendly!
rstatix_results <- npk_data |>
    emmeans_test(yield ~ treatment, p.adjust.method = "tukey")

# Display key columns
rstatix_results |>
    select(term, .y., group1, group2, statistic, p, p.adj, p.adj.signif) |>
    knitr::kable(digits = 3)

# Simple tukey_hsd() function from rstatix
npk_tukey <- npk_data |>
    tukey_hsd(yield ~ treatment)

# Display pairwise comparison results
npk_tukey |>
    select(group1, group2, estimate, conf.low, conf.high, p.adj, p.adj.signif) |>
    knitr::kable(digits = 2)


# GGPUBR: PUBLICATION-READY PLOTS ============================================

# Run statistical test using rstatix
pwc <- npk_data |>
    emmeans_test(yield ~ treatment, p.adjust.method = "tukey")

# Prepare positions for brackets
pwc <- pwc |> add_xy_position(x = "treatment")

# Create plot with automated significance brackets
ggplot(npk_data, aes(x = treatment, y = yield, fill = treatment)) +
    geom_boxplot(alpha = 0.7, outlier.shape = NA) +
    geom_jitter(width = 0.15, alpha = 0.5, size = 2) +
    # Add significance brackets automatically
    stat_pvalue_manual(pwc,
        hide.ns = TRUE, label = "p.adj.signif",
        tip.length = 0.01, step.increase = 0.05
    ) +
    labs(
        title = "NPK Treatment Effects with Automated Significance Testing",
        subtitle = "Brackets show significant pairwise differences (Tukey HSD, α = 0.05)",
        x = "Treatment",
        y = "Yield (bushels/acre)",
        fill = "Treatment"
    ) +
    scale_fill_viridis_d(option = "plasma") +
    theme_minimal() +
    theme(
        text = element_text(size = 13),
        axis.text.x = element_text(angle = 30, hjust = 1),
        legend.position = "none"
    )


# COMPARISON OF ADJUSTMENT METHODS ============================================

# Compare different adjustment methods
methods_comparison <- list(
    Tukey = as.data.frame(pairs(emm_npk, adjust = "tukey")),
    Bonferroni = as.data.frame(pairs(emm_npk, adjust = "bonferroni")),
    None = as.data.frame(pairs(emm_npk, adjust = "none"))  # Fisher's LSD
) |>
    bind_rows(.id = "method")

# Plot p-values across methods
methods_comparison |>
    as.data.frame() |>
    ggplot(aes(x = contrast, y = p.value, color = method, group = method)) +
    geom_point(size = 3, position = position_dodge(width = 0.5)) +
    geom_hline(yintercept = 0.05, linetype = "dashed", color = "red") +
    coord_flip() +
    labs(
        title = "P-values Across Multiple Comparison Methods",
        subtitle = "Red line shows α = 0.05 threshold",
        x = "Pairwise Comparison",
        y = "P-value",
        color = "Adjustment"
    ) +
    scale_color_viridis_d(option = "plasma", end = 0.9) +
    theme_minimal() +
    theme(text = element_text(size = 12))


# EASYSTATS: COMPREHENSIVE REPORTING ==========================================

# Check model assumptions with performance package
check_model(model_npk, check = c("normality", "homogeneity", "qq", "outliers"))

# Extract model parameters with confidence intervals
model_parameters(model_npk, effects = "fixed", ci = 0.95)

# Calculate effect sizes - proportion of variance explained by treatment
# η² (eta-squared): Proportion of total variance explained (biased, overestimates)
#   - Calculated as: SS_treatment / SS_total
#   - Problem: Inflated in sample, doesn't generalize well to population
# ω² (omega-squared): Less biased estimate, adjusts for sample size
#   - Preferred for making inferences about population effects
#   - Generally smaller than η² (more conservative)
# ε² (epsilon-squared): Alternative unbiased estimate
#   - Similar to ω² but uses different adjustment formula
#
# All range from 0 (no effect) to 1 (treatment explains all variance)
# Effect size interpretation (Cohen, 1988):
#   Small: η² ≈ 0.01, ω² ≈ 0.01  (1% variance explained)
#   Medium: η² ≈ 0.06, ω² ≈ 0.06  (6% variance explained)
#   Large: η² ≈ 0.14, ω² ≈ 0.14  (14% variance explained)

eta_squared(model_npk, partial = TRUE, ci = 0.95)

# Omega-squared (less biased than eta-squared)
omega_squared(model_npk, partial = TRUE, ci = 0.95)

# Comprehensive automated report
report(model_npk)


# END OF SCRIPT ===============================================================
# For more information:
# - emmeans: https://cran.r-project.org/package=emmeans
# - rstatix: https://rpkgs.datanovia.com/rstatix/
# - ggpubr: https://rpkgs.datanovia.com/ggpubr/
# - easystats: https://easystats.github.io/easystats/
# - agridat: https://kwstat.github.io/agridat/
