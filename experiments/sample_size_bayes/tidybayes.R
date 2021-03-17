library(tidybayes)
library(dplyr)
library(tidyr)
library(ggplot2)
library(rstanarm)

theme_set(theme_minimal())
options(mc.cores = 4)

n <- 100
effect <- .1


group_1 <- data.frame(y = rnorm(n), group = "1")
group_2 <- data.frame(y = rnorm(n, effect), group = "2")
df <- bind_rows(group_1, group_2)


m <- stan_lmer(
  y ~ (1|group), data = df, 
  # prior = normal(0, 1, autoscale = FALSE),
  # prior_aux = student_t(3, 0, 1, autoscale = FALSE),
  # adapt_delta = .99
  )

get_variables(m)

draws <- m %>%
  spread_draws(b[term,group])

draws %>% 
  ggplot(aes(x = b, color = group, fill = group)) + 
  geom_density(alpha = 0.3) + 
  geom_rug()

draws_wide <- draws %>% 
  pivot_wider(
    id_cols = c("term", ".chain", ".iteration", ".draw"), 
    names_from = "group", 
    values_from = "b"
    ) %>% 
  rename(
    group_1 = `group:1`,
    group_2 = `group:2`,
    ) %>% 
  ungroup()

difflim <- 1
draws_wide %>% 
  group_by(
    diff = case_when(
      (group_1 - group_2) > difflim ~ "positive",
      (group_1 - group_2) < -difflim ~ "negative",
      T ~ "no diff"
    )
    ) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(prop = 100 * n / sum(n))

draws_wide %>% 
  mutate(diff = group_1 - group_2) %>% 
  ggplot(aes(x = diff, fill = stat(abs(x) < 1))) +
  stat_halfeye() +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed") +
  scale_fill_manual(values = c("gray80", "skyblue"))
  
