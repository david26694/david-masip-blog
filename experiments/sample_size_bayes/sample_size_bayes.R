library(dplyr)
library(purrr)
library(ggplot2)
library(rstanarm)

options(mc.cores = 4)

theme_set(theme_minimal())

rnorm(10, 0)
rnorm(10, 100)
n <- 10
effect <- 0.1
# Given sample size n and effect, compute the p-value of 
# t-test generating the respective samples
t_test_value <- function(n, effect) {
  group_1 <- data.frame(y = rnorm(n), group = 1)
  group_2 <- data.frame(y = rnorm(n, effect), group = 2)
  df <- bind_rows(group_1, group_2)
  model <- rstanarm::stan_glm(
    y ~ group, 
    data = df, 
    prior = normal(0, 10),
    family = gaussian(),
    # algorithm = 'optimizing'
    )
  
  # bayes_fctr <- bayesfactor_parameters(model, null = c(-1, 1))
  # bayes_fctr$BF[2]
  # posterior_predict(model, df)
  group_posterior <- posterior_interval(model, prob = 0.9, pars = "group")
  accept <- (0 > group_posterior[1])
  accept
}



# Surprisingly logarithmic sequences don't exist in base R
lseq <- function(from, to, length.out) {
  # logarithmic spaced sequence
  # blatantly stolen from library("emdbook"), because need only this
  exp(seq(log(from), log(to), length.out = length.out))
}

# Create pairs of samples sizes and effects
results_tbl <- expand.grid(
  as.integer(lseq(50, 1e5, 10)),
  1:10 / 100
)
names(results_tbl) <- c("n", "effect")

# We make use of the elegant purrr
# to apply the funciton in the grid
results_tbl$accept <- map2_lgl(
  .x = results_tbl$n,
  .y = results_tbl$effect,
  t_test_value
)

results_tbl$hypothesis <- if_else(
  # results_tbl$p_values < 0.05, 
  results_tbl$accept, 
  'accepts', 
  'rejects'
)

results_tbl

ggplot(results_tbl, aes(x = n, y = effect, fill = hypothesis)) + 
  geom_tile() + 
  scale_x_log10()
