library(gamlss)
library(nbastatR)
library(dplyr)
library(ggplot2)
library(ebbr)
theme_set(theme_minimal())

# https://github.com/swar/nba_api
df <- read.csv("experiments/nba/shot_logs.csv")

# df %>% View
player_summaries <- df %>% 
  filter(PTS_TYPE == 3, PERIOD == 4) %>% 
  group_by(player_name, player_id) %>% 
  summarise(
    n = n(),
    n_3pts = sum(SHOT_RESULT == 'made'),
    ratio_3pt = sum(SHOT_RESULT == 'made') / n()
  ) %>% 
  arrange(desc(ratio_3pt)) %>% 
  ungroup()

profiles <- read.csv("experiments/nba/player_data.csv")

player_df <- player_summaries %>% left_join(profiles, by = c("player_id" = "idPlayer"))

player_df$weight <- player_df$weightLBS / 2.2
player_df$height <- player_df$heightInches * 2.54 / 100
player_df$age <- 2015 - lubridate::year(player_df$dateBirth)
# player_df$age <- pmin(player_df$age, 35L)
player_df$imc <- player_df$weight / (player_df$height) ** 2
  
prior <- player_df %>% ebb_fit_prior(n_3pts, n)
  
# Plain estimation
player_df <- player_df %>%
  add_ebb_estimate(n_3pts, n)

player_df %>% 
  select(player_name, n, n_3pts, .alpha1:.high)


ggplot(player_df, aes(.raw, .fitted, color = n)) +
  geom_point() +
  geom_abline(color = "red") +
  geom_hline(yintercept = tidy(prior)$mean, color = "red", lty = 2)

# Errors depend on n
ggplot(player_df, aes(log(n), .fitted, color = n)) +
  geom_point() + 
  geom_smooth(method = 'lm', se = F)

# Errors depend on n (for raw)
ggplot(player_df, aes(log(n), .raw, color = n)) +
  geom_point() + 
  geom_smooth(method = 'lm', se = F) + 
  geom_hline(yintercept = tidy(prior)$mean, color = "red", lty = 2)

# Errors depend on weight?
ggplot(player_df, aes(weight, .raw, color = n)) +
  geom_point() + 
  geom_smooth(method = 'lm', se = F)



ggplot(player_df, aes(age, .raw, color = n)) +
  geom_point() +
  geom_smooth() + 
  geom_smooth(method = 'lm')

ggplot(player_df, aes(imc, .raw, color = n)) +
  geom_point() +
  # geom_smooth(method = 'lm', se = F) +
  geom_smooth(se = F)


# 
clean_df <- player_df %>% 
  filter(!is.na(weight)) %>%
  select(n, n_3pts, weight, imc, age)

fit <- gamlss(
  cbind(n_3pts, n - n_3pts) ~ age + imc + n, 
  data = clean_df,
  family = BB(mu.link = "identity")
)

summary(fit)

mu <- fitted(fit, parameter = "mu")
sigma <- fitted(fit, parameter = "sigma")

sigma

player_df_good <- player_df %>%
  filter(!is.na(weight), !is.na(age)) %>%
  dplyr::select(
    player_name, n, n_3pts, original_eb = .fitted, raw_estimate = .raw, weight, age, imc
  ) %>% 
  mutate(
    mu = mu,
    alpha0 = mu / sigma,
    beta0 = (1 - mu) / sigma,
    alpha1 = alpha0 + n_3pts,
    beta1 = beta0 + n - n_3pts,
    new_eb = alpha1 / (alpha1 + beta1)
  )

player_df_good 

ggplot(player_df_good, aes(original_eb, new_eb, color = imc)) +
  geom_point() +
  geom_abline(color = "red")
  # geom_hline(yintercept = tidy(prior)$mean, color = "red", lty = 2)


ggplot(player_df_good, aes(original_eb, new_eb, color = age)) +
  geom_point() +
  geom_abline(color = "red")


ggplot(player_df_good, aes(n, new_eb, color = imc)) +
  geom_point() + 
  geom_smooth(method = 'lm', se = F)


ggplot(player_df_good, aes(n, new_eb, color = age)) +
  geom_point() + 
  geom_smooth(method = 'lm', se = F)

player_df_good %>% 
  filter(n < 10) %>% 
  select(player_name:n_3pts, raw_estimate, age, imc, new_eb) %>% View

summary(fit)


player_df %>% 
  filter(!is.na(imc)) %>% 
  group_by(
    ntile(n, 2),
    ntile(age, 2)
  ) %>% 
  summarise(
    # min(n),mean(n), max(n),
    mean(n),
    sum(n),
    mean(age),
    shooting_pct = 100 * sum(n_3pts) / sum(n)
  )


player_df %>% 
  filter(!is.na(imc)) %>% 
  group_by(
    ntile(n, 5),
  ) %>% 
  summarise(
    # min(n),mean(n), max(n),
    mean(n),
    sum(n),
    shooting_pct = 100 * sum(n_3pts) / sum(n)
  )
