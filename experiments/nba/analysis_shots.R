library(nbastatR)
library(dplyr)
library(ggplot2)
theme_set(theme_minimal())

# https://github.com/swar/nba_api
df <- read.csv("experiments/nba/shot_logs.csv")

df %>% View
df %>% count(SHOT_RESULT)


# profiles %>% View

player_summaries <- df %>% 
  filter(PTS_TYPE == 3) %>% 
  group_by(player_name, player_id) %>% 
  summarise(
    n = n(),
    n_shots_made = sum(SHOT_RESULT == 'made'),
    made_ratio = sum(SHOT_RESULT == 'made') / n()
  ) %>% 
  arrange(desc(made_ratio))

if (FALSE) {
  profiles <- nbastatR::player_profiles(player_ids = player_summaries$player_id)
  write.csv(profiles, row.names = F, file = 'experiments/nba/player_data.csv')
} else {
  profiles <- read.csv("experiments/nba/player_data.csv")
}

# profiles %>% View
player_info <- player_summaries %>% left_join(profiles, by = c("player_id" = "idPlayer"))

player_info %>% summary()

player_info %>% 
  ggplot(aes(x = numberOverallPick, y = made_ratio)) + 
  geom_smooth()


player_info %>%
  ggplot(aes(x = n, y = made_ratio)) + 
  geom_point() + 
  geom_smooth()


player_info %>% 
  ggplot(aes(x = yearDraft, y = made_ratio)) + 
  geom_smooth()


player_info %>% 
  ggplot(aes(x = heightInches, y = made_ratio)) + 
  geom_smooth()


player_info %>% 
  ggplot(aes(x = weightLBS, y = made_ratio)) + 
  geom_smooth()

player_info %>% 
  ggplot(aes(x = dateBirth, y = made_ratio)) + 
  geom_smooth()


player_info %>% 
  ggplot(aes(x = as.factor(coalesce(countAllStarGames, 0)), y = made_ratio)) + 
  geom_boxplot()

player_info %>% View

player_info %>% 
  ggplot(aes(x = made_ratio, color = teamName, fill = teamName)) +
  geom_density(alpha = 0.3) + 
  geom_rug()


player_info %>% 
  mutate(numberRound = as.factor(numberRound)) %>% 
  ggplot(aes(x = made_ratio, color = numberRound, fill = numberRound)) +
  geom_density(alpha = 0.3) + 
  geom_rug()

player_info %>% filter(numberRound == 1) %>% View

klay <- nbastatR::players_careers(player_ids = '202691')

klay$dataTable[1]
