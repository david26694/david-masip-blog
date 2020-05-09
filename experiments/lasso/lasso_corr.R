

# Prepare experiment ------------------------------------------------------


library(dplyr)
library(glmnet)
library(yardstick)

set.seed(42)

len <- 20000

var_1 <- rnorm(len)
var_2 <- rnorm(len)

error <- rnorm(len)

error_1a <- rnorm(len)
error_2a <- rnorm(len)

var_1a <- 0.8 * var_1 + 0.2 * error_1a
var_2a <- 0.8 * var_2 + 0.2 * error_2a

y <- var_1 + 0.1 * var_2 + 0.05 * error


model_tbl <- tibble(
 y = y,
 x1 = var_1,
 x2 = var_2,
 x1a = var_1a,
 x2a = var_2a
)

# Split train and test ----------------------------------------------------

X <- as.matrix(select(model_tbl, -y))

X_train <- X[1:(len/2),]
y_train <- y[1:(len/2)]
X_test <- X[(len/2 + 1):len,]
y_test <- y[(len/2 + 1):len]


# Correlation -------------------------------------------------------------

cor(X_train, y_train)

X_train_cor <- X_train[, c(1, 3)]
X_test_cor <- X_test[, c(1, 3)]

ridge <- cv.glmnet(X_train_cor, y_train, alpha = 0)

coef(ridge, s = "lambda.min")

y_pred_cor <- as.vector(predict(ridge, X_test_cor, s = "lambda.min"))

# Lasso -------------------------------------------------------------------

lasso <- cv.glmnet(X_train, y_train)

coef(lasso, s = "lambda.min")

cor(X, y)

y_pred <- as.vector(predict(lasso, X_test, s = "lambda.min"))

# Results -----------------------------------------------------------------

yardstick::rmse_vec(y_pred, y_test)
yardstick::rmse_vec(y_pred_cor, y_test)