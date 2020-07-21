

library(dplyr)
library(purrr)
library(ggplot2)

theme_set(theme_minimal())


n <- 1000
effect <- 0.1

t_test_value <- function(n, effect, n_tries = 100) {
  # p_values <- map_dbl(
  #   1:n_tries, function(x) t.test(rnorm(n), rnorm(n, effect))$p.value
  #   )
  # 
  # mean(p_values)
  t.test(rnorm(n), rnorm(n, effect))$p.value
  
}


lseq <- function(from=1, to=100000, length.out=6) {
  # logarithmic spaced sequence
  # blatantly stolen from library("emdbook"), because need only this
  exp(seq(log(from), log(to), length.out = length.out))
}

results_tbl <- expand.grid(
  as.integer(lseq(50, 1e5, 100)),
  5:100 * 0.001
)
names(results_tbl) <- c("n", "effect")

p_values <- map2_dbl(
  .x = results_tbl$n,
  .y = results_tbl$effect,
  t_test_value
)

results_tbl$p_values <- p_values
results_tbl$hypothesis <- 
  if_else(results_tbl$p_values < 0.05, 'rejects', 'accepts')

ggplot(results_tbl, aes(x = n, y = effect, fill = p_values)) + 
  geom_tile() + 
  scale_x_log10()


ggplot(results_tbl, aes(x = n, y = effect, fill = hypothesis)) + 
  geom_tile() + 
  scale_x_log10()

ggplot(results_tbl %>% filter(effect == 0.1), 
       aes(x = n, y = p_values)) + 
  geom_point() + 
  scale_x_log10()
