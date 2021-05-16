library(dplyr)

library(palmerpenguins)

df <- palmerpenguins::penguins

# Count based on 1 column
df %>% count(species)

# Count based on 2 columns
df %>% count(species, island)

# Many aggregates per column
df %>% 
  group_by(species, island) %>% 
  summarise(
    mean_bill_length_mm = mean(bill_length_mm, na.rm = T),
    median_bill_length_mm = median(bill_length_mm, na.rm = T),
    not_null_flipper = sum(!is.na(flipper_length_mm))
  )

# Group by filter (having)
df %>% 
  group_by(species, island) %>%
  filter(n() > 70)

# Group by mutate
df %>% 
  group_by(species, island) %>% 
  mutate(
    mean_bill_length = mean(bill_length_mm, na.rm = T)
  )

# Count relative
df %>% 
  count(species, island) %>% 
  group_by(species) %>% 
  mutate(fraction =n / sum(n))

# Agg with two columns
df %>% 
  group_by(species) %>% 
  summarise(
    depth_length_ratio = mean(bill_depth_mm / bill_length_mm, na.rm = T)
  )

