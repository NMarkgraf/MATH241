# Linear Regression
# Reference:  Chapter 3 of "Data analysis using regression and
# multilevel/hierarchical models" by Gelman and Hill
# Note all code/data from this book can be found at
# http://www.stat.columbia.edu/~gelman/arm
library(dplyr)
library(ggplot2)

# This package allows us to read .dta STATA files into R via read.dta()
library(foreign)

# Load child data from Gelman:  predicting cognitive test scores of 3-4 year old
# children given characteristics of their mothers, using data from the National
# Longitudinal Survey of Youth.
# Recall tbl_df() changes the data frame so that not all rows show when we print
# its contents
url <- "http://www.stat.columbia.edu/~gelman/arm/examples/child.iq/kidiq.dta"
kid.iq <- read.dta(url) %>% tbl_df()
kid.iq



#------------------------------------------------
# Model 0: Just the average
#------------------------------------------------
p <- qplot(data=kid.iq, x=kid_score)
p

ybar <- mean(kid.iq$kid_score)
p + geom_vline(xintercept=ybar, col="red", size=1)



#------------------------------------------------
# Model 1: Include mom's high school information
#------------------------------------------------
means <- group_by(kid.iq, mom_hs) %>%
  summarise(mean=mean(kid_score))
means

# Note we make mom_hs a categorical variable by as.factor() or factor()'ing it
ggplot(kid.iq, aes(x=as.factor(mom_hs), y=kid_score)) + geom_boxplot()
ggplot(kid.iq, aes(x=kid_score, y=..density..)) + geom_histogram() +
  facet_wrap(~ mom_hs, ncol=1)

p <- ggplot(kid.iq, aes(x=as.factor(mom_hs), y=kid_score, color=as.factor(mom_hs))) + geom_point()
p
# Now add horizontal lines corresponding to the means.  Note the [[2]] says
# extract the second column
p + geom_hline(yintercept=means[[2]], color=c("#F8766D", "#00BFC4"), size=1)

# This is how we fit a linear (regression) model in R:
model1 <- lm(kid_score ~ mom_hs, data=kid.iq)
model1
# The last output isn't so helpful; here is the full regression table.  Compare
# the table to the means data frame above
summary(model1)

# Other useful functions
coefficients(model1)
confint(model1)
fitted(model1) # the fitted yhat values
resid(model1) # the residuals


#------------------------------------------------
# Model 2: Include mom's IQ
#------------------------------------------------
p <- ggplot(kid.iq, aes(x=mom_iq, y=kid_score)) + geom_point()
p

model2 <- lm(kid_score ~ mom_iq, data=kid.iq)
summary(model2)

# We plot the regression line by extracting the intercept and slope using square
# brackets:
b <- coefficients(model2)
b
p + geom_abline(intercept=b[1], slope=b[2], col="blue", size=1)

# We can do this quick via geom_smooth()
p + geom_smooth(method="lm", size=1, level=0.95)



#------------------------------------------------
# Model 3: Include BOTH mom's IQ and high
#------------------------------------------------
ggplot(kid.iq, aes(x=mom_iq, y=kid_score, color=mom_hs)) + geom_point()

# Note we have the multiple colors b/c R is treating mom_hs as a numerical
# variable, when really it is a categorical variable.  So we convert it to a
# categorical variable via factor() or as.factor()
p <- ggplot(kid.iq, aes(x=mom_iq, y=kid_score, color=factor(mom_hs))) +
  geom_point(size=3)
p


# Model 3.a) We fit the first model assuming an intercept shift, or just the
# additive effect of a mom having completed high school
model3a <- lm(kid_score ~ mom_iq + mom_hs, data=kid.iq)
summary(model3a)

# Plot these lines
b <- coefficients(model3a)
b
p + geom_abline(intercept=b[1], slope=b[2], col="#F8766D", size=1) +
  geom_abline(intercept=b[1]+b[3], slope=b[2], col="#00BFC4", size=1)

