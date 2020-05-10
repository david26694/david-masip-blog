---
toc: false
layout: post
description: A critique to univariate selection methods
categories: [r, feature-selection]
comments: true
title: Feature selection part 1
---

The purpose of this post is to show the weaknesses of univariate feature
selection methods. This methods usually go in the following way:

  - Compute a correlation metric for every feature with the target (this
    metric might be correlation or mutual information, among others)
  - Select the features that score the best regarding this metric

A possible implementation is [SelectKBest in
sklearn](https://scikit-learn.org/stable/modules/generated/sklearn.feature_selection.SelectKBest.html).

If you’re an univariate method lover and have a different perspective,
don’t hesitate to contact me.

### Experiment set-up

Let’s prepare an experiment to see the deficiencies of these methods. We
generate two variables `x1` and `x2` and a target variable `y` that is
`x1 + 0.1 * x2 + noise`. So, the variable `y` is very similar to `x1`,
but has some `x2` as well. Then we create two variables `x1a` and `x2a`,
that are noisy versions of `x1` and `x2`.

Although the data is artifical, I believe this occurs in real life. When
performing feature engineering, we might end up with pretty good
features that are correlated, and also have not so good features.

``` r
library(dplyr)
library(glmnet)
library(yardstick)

set.seed(42)

len <- 20000

x1 <- rnorm(len)
x2 <- rnorm(len)

# All the rnorm(len) that appear from now on are to simulate noise
y <- x1 + 0.1 * x2 + 0.05 * rnorm(len)

x1a <- 0.8 * x1 + 0.2 * rnorm(len)
x2a <- 0.8 * x2 + 0.2 * rnorm(len)
```

After this, we split the data in train and test sets to estimate errors.
We also transform the data to matrix representation, as we’re going to
use *glmnet* package that uses matrices to fit models.

``` r
model_tbl <- tibble(
 y = y,
 x1 = x1,
 x2 = x2,
 x1a = x1a,
 x2a = x2a
)

# Split train and test ----------------------------------------------------

X <- as.matrix(select(model_tbl, -y))

X_train <- X[1:(len/2),]
y_train <- y[1:(len/2)]
X_test <- X[(len/2 + 1):len,]
y_test <- y[(len/2 + 1):len]
```

### Univariate-method approach

The univariate method approach that we follow here consists in keeping
the most correlated variables with the target. For this reason, we
compute the correlation for each variable:

``` r
cor(X_train, y_train)
```

    ##           [,1]
    ## x1  0.99390574
    ## x2  0.10012730
    ## x1a 0.96482998
    ## x2a 0.09786507

We’ll keep only the first and third variables, as they are the most
correlated with the target. We’ll train a *ridge* model using *glmnet*
and cross-validation to select the optimal hyperparameters:

``` r
X_train_cor <- X_train[, c(1, 3)]
X_test_cor <- X_test[, c(1, 3)]

ridge <- cv.glmnet(X_train_cor, y_train, alpha = 0)

y_pred_cor <- as.vector(predict(ridge, X_test_cor, s = "lambda.min"))
```

### Multivariate methods: the Lasso

The Lasso can be thought of as a multivariate feature selection method,
as it uses all the features at the same time to select a subset. Here we
are applying a Lasso because `cv.glmnet` does Lasso (`alpha = 1`) by
default.

``` r
lasso <- cv.glmnet(X_train, y_train)

y_pred_lasso <- as.vector(predict(lasso, X_test, s = "lambda.min"))
```

### Results

#### Coefficient comparison

By construction, the coefficients should be 1 for `x1` and 0.1 for `x2`.
In the ridge case (recall that we’ve applied univariate selection using
correlation), this won’t happen as we’ve deleted `x2` because the
correlation with the target was too low.

``` r
coef(ridge, s = "lambda.min")
```

    ## 3 x 1 sparse Matrix of class "dgCMatrix"
    ##                        1
    ## (Intercept) -0.000664586
    ## x1           0.589067554
    ## x1a          0.439495206

In fact, what we have is a mixture of `x1` and `x1a`.

On the other hand, the Lasso sets the coefficients of `x1a` and `x2a` to
0 (doesn’t select those variables), and estimates the coefficents of
`x1` and `x2` pretty well:

``` r
coef(lasso, s = "lambda.min")
```

    ## 5 x 1 sparse Matrix of class "dgCMatrix"
    ##                         1
    ## (Intercept) -0.0004744455
    ## x1           0.9954934728
    ## x2           0.0941690869
    ## x1a          .           
    ## x2a          .

#### Test set results

If you care more about model performance and not that much of proper
estimation of the parameters, I also have an argument for you. The Lasso
predictions are way better than the correlation method predictions:

``` r
rmse_vec(y_pred_lasso, y_test)
```

    ## [1] 0.05027135

``` r
rmse_vec(y_pred_cor, y_test)
```

    ## [1] 0.1563891

We can even interpret it:

  - The lasso error is around 0.05 which is the “noise size” used to
    generate `y`.
  - The error of the univariate method is 0.15, which is 0.05 (noise
    size used to generate `y`) plus 0.10 (error we are commiting by not
    considering `x2`).
