
library(MASS)
library(purrr)
library(ggplot2)
library(dplyr)

theme_set(theme_minimal())

simulate_norm <- function(dimension, n_samples) { 
  sim_data <- mvrnorm(n = n_samples, rep(0, dimension), diag(dimension))
  
  l2_norm <- sqrt(rowSums(sim_data ** 2))
  
  # quantile(l2_norm, quantile_val)
  data.frame(
    l2_norm = l2_norm,
    dimension = dimension
  )
  
}

dims_sim <- c(1, 5, 10, 25, 100, 400)

norm_simulations <- map_dfr(dims_sim, simulate_norm, n_samples = 20000)


norm_simulations %>% 
  mutate(`Multivariate normal dimension` = as.factor(dimension)) %>% 
  ggplot(aes(x = l2_norm, color = `Multivariate normal dimension`, fill = `Multivariate normal dimension`)) + 
  geom_density(alpha = 0.3) + 
  geom_rug() +
  xlab("Distance to origin")
  
