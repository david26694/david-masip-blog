
library("dplyr")
library("randomForest")
library("glmnet")
library("yardstick")


set.seed(42)

len <- 20000

x1 <- rnorm(len)
x2 <- rnorm(len)
x3 <- rnorm(len)
x4 <- rnorm(len)

x11 <- 0.95 * x1 + 0.05 * rnorm(len)
x12 <- 0.95 * x1 + 0.05 * rnorm(len)
x13 <- 0.95 * x1 + 0.05 * rnorm(len)
x14 <- 0.95 * x1 + 0.05 * rnorm(len)
x15 <- 0.95 * x1 + 0.05 * rnorm(len)
x16 <- 0.95 * x1 + 0.05 * rnorm(len)
x17 <- 0.95 * x1 + 0.05 * rnorm(len)
x18 <- 0.95 * x1 + 0.05 * rnorm(len)

y <- x1 + 0.5 * x2 + 0.5 * x3 + 0.5 * x4 + rnorm(len)


model_tbl <- tibble(
  y = y,
  x1 = x1,
  x2 = x2,
  x3 = x3,
  x4 = x4,
  x11 = x11,
  x12 = x12,
  x13 = x13,
  x14 = x14,
  x15 = x15,
  x16 = x16,
  x17 = x17,
  x18 = x18
)

# Split train and test ----------------------------------------------------

X <- as.matrix(select(model_tbl, -y))

X_train <- X[1:(len/2),]
y_train <- y[1:(len/2)]
X_test <- X[(len/2 + 1):len,]
y_test <- y[(len/2 + 1):len]


# Random forest importance ------------------------------------------------

rf <- randomForest(X_train, y_train, importance = T)

rf$importance

corrplot::corrplot(cor(X_train))

varImpPlot(rf)


# Lasso -------------------------------------------------------------------

lasso <- cv.glmnet(X_train, y_train)

# Kind of makes it
coef(lasso, s = "lambda.min")

# x1 is the last one to go
plotmo::plot_glmnet(lasso$glmnet.fit)



# Results -----------------------------------------------------------------


rmse_vec(as.vector(predict(rf, X_test)), y_test)
rmse_vec(as.vector(predict(lasso, X_test, s = "lambda.min")), y_test)
