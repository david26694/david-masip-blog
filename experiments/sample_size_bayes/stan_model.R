library(rstanarm)

n <- 100
effect <- 0.1


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

summary(model)
str(model, 1)


model

str(model$stanfit, 3)

model$linear.predictors
str(summary(model))
summary(model)
posterior_interval(model, prob = 0.9, pars = "group")

# quantile(rnorm(100000, 0.5, 0.4), 0.1)
# quantile(rnorm(100000, 0.5, 0.4), 0.9)


# str(pp_check(model))
