# Probabilities

library(dplyr)
set.seed(42)

flip_0_1 <- function(x) {
  x_aux <- x
  x_aux[x == 0] <- 1
  x_aux[x == 1] <- 0
  x_aux
}

p_covid <- 0.02
n <- 100000

covid <- rbinom(n, 1, p_covid)
results_test <- covid

df <- data.frame(
  id = 1:n,
  covid = covid,
  results_test = results_test
)

fpr <- 0.01
fnr <- 0.01

n_covid <- sum(df$covid == 1)
fn <- rbinom(n_covid, 1, fnr) %>% flip_0_1

n_no_covid <- sum(df$covid == 0)
fp <- rbinom(n_no_covid, 1, fpr)


df$results_test[df$covid == 1] <- fn
df$results_test[df$covid == 0] <- fp

df %>% count(results_test, covid)

df %>% 
  filter(results_test == 1) %>% 
  count(covid) %>% 
  mutate(prop = 100 * n / sum(n))


# p(covid | positive) = p(positive | covid) * p(covid) / p(positive)
# p(covid | positive) = p(positive | covid) * p(covid) / (p(positive | covid) * p(covid) + p(positive | no covid) * p(no covid))


p_pos_covid <- 0.99
p_covid <- 0.02
p_pos_no_covid <- 0.01
p_no_covid <- 0.98

# It's not 2/3
(p_pos_covid * p_covid) / (p_pos_covid * p_covid + p_pos_no_covid * p_no_covid)


# Now with null hypothesis ------------------------------------------------



