---
toc: false
layout: post
categories: [r, probability-theory]
comments: true
title: Sampling for your marketing team
---

### Problem

Your marketing team has asked you to select a subpopulation of your
customers based on the values of some variables. For instance, they want
to have a population with 50% of the customers have been acquired
through the online channel. They also don’t want any customer under 18
in the population for the campaign. In the end, they have some
conditions based on several variables that can be expressed as
probabilistic statements that have to be held on the selected
population.

### Data

Let’s say your client database has the following information:

<details>

<summary>Code to generate artificial database</summary>

``` r
library("dplyr")

size <- 100000
countries <- c('Spain', 'France', 'UK', 'Germany', 'Italy', 'Poland')
countries_vctr <- sample(
  countries, 
  replace = T,
  size = size
  )

ages <- c('<18', '18-30', '30-50', '50-65', '>65')
age_vctr <- sample(
  ages, 
  replace = T,
  size = size
)

market_segments <- c('A', 'B', 'C')
marketing_vctr <- sample(
  market_segments, 
  replace = T,
  size = size,
  prob = c(.5, .25, .25)
)

channels <- c('Online', 'Shop', 'Phone')
channel_vctr <- sample(
  channels, 
  replace = T,
  size = size,
  prob = c(.6, .3, .1)
)


customer_db <- tibble(
  id = 1:size,
  country = countries_vctr,
  age = age_vctr,
  segment = marketing_vctr,
  channel = channel_vctr
)
```

</details>

``` r
head(customer_db, 10)
```

    ## # A tibble: 10 x 5
    ##       id country age   segment channel
    ##    <int> <chr>   <chr> <chr>   <chr>  
    ##  1     1 Poland  18-30 A       Shop   
    ##  2     2 France  <18   B       Online 
    ##  3     3 UK      >65   A       Phone  
    ##  4     4 Poland  18-30 A       Shop   
    ##  5     5 Germany <18   A       Online 
    ##  6     6 Italy   50-65 A       Shop   
    ##  7     7 UK      >65   C       Shop   
    ##  8     8 Poland  30-50 C       Online 
    ##  9     9 UK      18-30 A       Online 
    ## 10    10 UK      18-30 A       Shop

That is, you have the client country of residence, age, a segment based
on a marketing segmentation and channel. In addition, the marketing team
has given some conditions to generate the sample. For instance, they
don’t want any underage people in the sample, and they want 25% on
each of the other age groups.

<details>

<summary>Code to generate requested probabilities</summary>

``` r
countries_probs <- tibble(
  country = countries,
  probability = c(.1, .1, .2, .2, .2, .2)
)


age_probs <- tibble(
  age = ages,
  probability = c(.0, .25, .25, .25, .25)
)


segment_probs <- tibble(
  segment = market_segments,
  probability = c(.4, .4, .2)
)


channels_probs <- tibble(
  channel = channels,
  probability = c(.5, .45, .05)
)
```

</details>

``` r
age_probs
```

    ## # A tibble: 5 x 2
    ##   age   probability
    ##   <chr>       <dbl>
    ## 1 <18          0   
    ## 2 18-30        0.25
    ## 3 30-50        0.25
    ## 4 50-65        0.25
    ## 5 >65          0.25

``` r
countries_probs
```

    ## # A tibble: 6 x 2
    ##   country probability
    ##   <chr>         <dbl>
    ## 1 Spain           0.1
    ## 2 France          0.1
    ## 3 UK              0.2
    ## 4 Germany         0.2
    ## 5 Italy           0.2
    ## 6 Poland          0.2

### Sampling

We’ll use a simple sampling solution based on a probability of being
sampled. What we are going to do is score each customer with the
probabilites of feature in the market requirements:

\[
score = P(x_1) \times \dots \times P(x_n)
\]

For instance, if a customer has

    {
      'country': 'Spain',
      'age': '50-65',
      'segment': 'A',
      'channel': 'Online'
    }

and the probability requirements are

    {
      'Spain': 0.1,
      '50-65': 0.25,
      'A': 0.5,
      'Online': 0.6
    }

The score for the customer is `0.1 x 0.25 x 0.5 x 0.6 = 0.0075`. The
following code computes the scores of each customer:

``` r
customer_db_probs <- customer_db %>% 
  left_join(countries_probs, by = 'country') %>% 
  left_join(age_probs, by = 'age', suffix = c('', '_age')) %>% 
  left_join(segment_probs, by = 'segment', suffix = c('', '_segment')) %>% 
  left_join(channels_probs, by = 'channel', suffix = c('', '_channel')) %>% 
  rename(probability_country = probability)

# My rowProd function. Sweet, right?
rowProd <- function(x) exp(rowSums(log(x)))

# Compute total probability
score <- customer_db_probs %>% 
  select_at(vars(starts_with('prob'))) %>% 
  as.matrix() %>% 
  rowProd()

customer_db_probs$score <- score
```

Then, we’ll sample with these scores:

``` r
sampled_customers <- sample(
  customer_db$id, 2000, replace = FALSE, prob = customer_db_probs$score
  )
```

### Results

We can check if the sampling has worked propperly.

``` r
customer_db %>% 
  filter(id %in% sampled_customers) %>% 
  count(country) %>% 
  mutate(prob_sample = n / sum(n)) %>% 
  left_join(countries_probs, by = 'country') %>% 
  rename(required_probability = probability)
```

    ## # A tibble: 6 x 4
    ##   country     n prob_sample required_probability
    ##   <chr>   <int>       <dbl>                <dbl>
    ## 1 France    201       0.100                  0.1
    ## 2 Germany   420       0.21                   0.2
    ## 3 Italy     384       0.192                  0.2
    ## 4 Poland    410       0.205                  0.2
    ## 5 Spain     232       0.116                  0.1
    ## 6 UK        353       0.176                  0.2

``` r
customer_db %>% 
  filter(id %in% sampled_customers) %>% 
  count(age) %>% 
  mutate(prob_sample = n / sum(n)) %>% 
  left_join(age_probs, by = 'age') %>% 
  rename(required_probability = probability)
```

    ## # A tibble: 4 x 4
    ##   age       n prob_sample required_probability
    ##   <chr> <int>       <dbl>                <dbl>
    ## 1 >65     533       0.266                 0.25
    ## 2 18-30   465       0.232                 0.25
    ## 3 30-50   509       0.254                 0.25
    ## 4 50-65   493       0.246                 0.25

The required probability is very similar to the sampled probability,
**nice**\!
