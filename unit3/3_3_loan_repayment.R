# PREDICTING LOAN REPAYMENT


# Problem 1.1 - Preparing the Dataset
# Load the dataset loans.csv into a data frame called loans, and explore it 
# using the str() and summary() functions.
loans <- read.csv("./data_unit3_3/loans.csv")
str(loans)
summary(loans)
# What proportion of the loans in the dataset were not paid in full? Please 
# input a number between 0 and 1.
table(loans$not.fully.paid)
1533 / (8045 + 1533)
## 0.1600543


# Problem 1.2 - Preparing the Dataset
# Which of the following variables has at least one missing observation? Select 
# all that apply.
## - log.annual.inc
## - days.with.cr.line
## - revol.util
## - inq.last.6mths
## - delinq.2yrs
## - pub.rec


# Problem 1.3 - Preparing the Dataset
# Which of the following is the best reason to fill in the missing values for
# these variables instead of removing observations with missing data? (Hint: you
# can use the subset() function to build a data frame with the observations 
# missing at least one value. To test if a variable, for example pub.rec, is 
# missing a value, use is.na(pub.rec).)
loansNA <- subset(loans, is.na(log.annual.inc) | is.na(days.with.cr.line)
                  | is.na(revol.util) | is.na(inq.last.6mths)
                  | is.na(delinq.2yrs) | is.na(pub.rec))
str(loansNA)
summary(loansNA)
table(loansNA$not.fully.paid)
12 / (50 + 12)
## We want to be able to predict risk for all borrowers, instead of just the ones with all data reported.


# Problem 1.4 - Preparing the Dataset
# For the rest of this problem, we'll be using a revised version of the dataset
# that has the missing values filled in with multiple imputation (which was
# discussed in the Recitation of this Unit). To ensure everybody has the same 
# data frame going forward, you can either run the commands below in your R 
# console (if you haven't already, run the command install.packages("mice") 
# first), or you can download and load into R the dataset we created after running the imputation: loans_imputed.csv.
# IMPORTANT NOTE: On certain operating systems, the imputation results are not 
# the same even if you set the random seed. If you decide to do the imputation 
# yourself, please still read the provided imputed dataset (loans_imputed.csv) 
# into R and compare your results, using the summary function. If the results 
# are different, please make sure to use the data in loans_imputed.csv for the 
# rest of the problem.
#  library(mice)
#  set.seed(144)
#  vars.for.imputation = setdiff(names(loans), "not.fully.paid")
#  imputed = complete(mice(loans[vars.for.imputation]))
#  loans[vars.for.imputation] = imputed
loans <- read.csv("./data_unit3_3/loans_imputed.csv")
# Note that to do this imputation, we set vars.for.imputation to all variables 
# in the data frame except for not.fully.paid, to impute the values using all 
# of the other independent variables.
# What best describes the process we just used to handle missing values?
## We predicted missing variable values using the available independent 
## variables for each observation.


# Problem 2.1 - Prediction Models
# Now that we have prepared the dataset, we need to split it into a training and
# testing set. To ensure everybody obtains the same split, set the random seed 
# to 144 (even though you already did so earlier in the problem) and use the 
# sample.split function to select the 70% of observations for the training set 
# (the dependent variable for sample.split is not.fully.paid). Name the data 
# frames train and test.
set.seed(144)
library(caTools)
split = sample.split(loans$not.fully.paid, SplitRatio = 0.7)
train = subset(loans, split == TRUE)
test = subset(loans, split == FALSE)
# Now, use logistic regression trained on the training set to predict the 
# dependent variable not.fully.paid using all the independent variables.
LoansLog <- glm(not.fully.paid ~ ., data = train, family = binomial)
# Which independent variables are significant in our model? (Significant 
# variables have at least one star, or a Pr(>|z|) value less than 0.05.) Select 
# all that apply.
summary(LoansLog)
## - credit.policy
## - purposecredit_card
## - purposedebt_consolidation
## - purposemajor_purchase
## - purposesmall_business
## - installment
## - log.annual.inc
## - fico
## - revol.bal
## - inq.last.6mths
## - pub.rec


# Problem 2.2 - Prediction Models
# Consider two loan applications, which are identical other than the fact that 
# the borrower in Application A has FICO credit score 700 while the borrower in
# Application B has FICO credit score 710.
# Let Logit(A) be the log odds of loan A not being paid back in full, according 
# to our logistic regression model, and define Logit(B) similarly for loan B. 
# What is the value of Logit(A) - Logit(B)?
applicationA <- train[1, ]
applicationB <- applicationA
applicationA$fico = 700
applicationB$fico = 710
applicationA
applicationB
applications <- rbind(applicationA, applicationB)
applications
PredApplications <- predict(LoansLog, type = "response", newdata = applications)
PredApplications
PredApplications[1] - PredApplications[2]
## 0.01351347 => NOK!!
##
CalcApplicationA <- 
    1 / (1 + exp(-1 * (9.187e+00 + -9.317e-03 * 700))) # A = 0.9349356
CalcApplicationB <- 
    1 / (1 + exp(-1 * (9.187e+00 + -9.317e-03 * 710))) # B = 0.929033
CalcApplicationA - CalcApplicationB
## 0.005902546 => NOK!!
## For final result, look after the problem is finished: log(Odds)
## 0.0931679 => OK!

# Now, let O(A) be the odds of loan A not being paid back in full, according to 
# our logistic regression model, and define O(B) similarly for loan B. What is 
# the value of O(A)/O(B)? (HINT: Use the mathematical rule that 
# exp(A + B + C) = exp(A)*exp(B)*exp(C). Also, remember that exp() is the 
# exponential function in R.)
OddsApplicationA <- PredApplications[1] / (1 - PredApplications[1])
OddsApplicationA
OddsApplicationB <- PredApplications[2] / (1 - PredApplications[2])
OddsApplicationB
OddsApplicationA / OddsApplicationB
## 1.097646 => OK!!
# After computing the logs, try log(odds) for previous problem
log(OddsApplicationA)
log(OddsApplicationB)
log(OddsApplicationA) - log(OddsApplicationB)
## 0.0931679 => OK!


# Problem 2.3 - Prediction Models
# Predict the probability of the test set loans not being paid back in full 
# (remember type="response" for the predict function). Store these predicted 
# probabilities in a variable named predicted.risk and add it to your test set 
# (we will use this variable in later parts of the problem). Compute the 
# confusion matrix using a threshold of 0.5.
predicted.risk <- predict(LoansLog, type = "response", newdata = test)
str(predicted.risk)
str(test)
test$predicted.risk <- predicted.risk
summary(test)
table(test$not.fully.paid, test$predicted.risk > 0.5)
##

# What is the accuracy of the logistic regression model? Input the accuracy as 
# a number between 0 and 1.
(2400 + 3) / nrow(test)
## 0.8364079

# What is the accuracy of the baseline model? Input the accuracy as a number 
# between 0 and 1.
table(test$not.fully.paid)
2413 / (2413 + 460)
## 0.8398886


# Problem 2.4 - Prediction Models
# Use the ROCR package to compute the test set AUC.
library(ROCR)
ROCRpred = prediction(test$predicted.risk, test$not.fully.paid)
as.numeric(performance(ROCRpred, "auc")@y.values)
## 0.6720995

# The model has poor accuracy at the threshold 0.5. But despite the poor 
# accuracy, we will see later how an investor can still leverage this logistic
# regression model to make profitable investments.


# Problem 3.1 - A "Smart Baseline"
# In the previous problem, we built a logistic regression model that has an AUC
# significantly higher than the AUC of 0.5 that would be obtained by randomly 
# ordering observations.
# However, LendingClub.com assigns the interest rate to a loan based on their 
# estimate of that loan's risk. This variable, int.rate, is an independent 
# variable in our dataset. In this part, we will investigate using the loan's 
# interest rate as a "smart baseline" to order the loans according to risk.

# Using the training set, build a bivariate logistic regression model (aka a 
# logistic regression model with a single independent variable) that predicts 
# the dependent variable not.fully.paid using only the variable int.rate.
LoansLog2 <- glm(not.fully.paid ~ int.rate, data = train, family = binomial)
summary(LoansLog2)
# The variable int.rate is highly significant in the bivariate model, but it is
# not significant at the 0.05 level in the model trained with all the 
# independent variables. What is the most likely explanation for this 
# difference?
## int.rate is correlated with other risk-related variables, and therefore does
## not incrementally improve the model when those other variables are included.


# Problem 3.2 - A "Smart Baseline"
# Make test set predictions for the bivariate model. What is the highest 
# predicted probability of a loan not being paid in full on the testing set?
predicted.risk2 <- predict(LoansLog2, type = "response", newdata = test)
max(predicted.risk2)
## 0.426624

# With a logistic regression cutoff of 0.5, how many loans would be predicted as
# not being paid in full on the testing set?
table(test$not.fully.paid, predicted.risk2 > 0.5)
str(test)
## 0


# Problem 3.3 - A "Smart Baseline"
# What is the test set AUC of the bivariate model?
ROCRpred2 = prediction(predicted.risk2, test$not.fully.paid)
as.numeric(performance(ROCRpred2, "auc")@y.values)


# Problem 4.1 - Computing the Profitability of an Investment
# While thus far we have predicted if a loan will be paid back or not, an 
# investor needs to identify loans that are expected to be profitable. If the 
# loan is paid back in full, then the investor makes interest on the loan. 
# However, if the loan is not paid back, the investor loses the money invested. 
# Therefore, the investor should seek loans that best balance this risk and 
# reward.
# To compute interest revenue, consider a $c investment in a loan that has an 
# annual interest rate r over a period of t years. Using continuous compounding 
# of interest, this investment pays back c * exp(rt) dollars by the end of the 
# t years, where exp(rt) is e raised to the r*t power.
# How much does a $10 investment with an annual interest rate of 6% pay back 
# after 3 years, using continuous compounding of interest? Hint: remember to 
# convert the percentage to a proportion before doing the math. Enter the number
# of dollars, without the $ sign.
10 * exp(0.06 * 3)
## 11.97217


# Problem 4.2 - Computing the Profitability of an Investment
# While the investment has value c * exp(rt) dollars after collecting interest, 
# the investor had to pay $c for the investment. What is the profit to the 
# investor if the investment is paid back in full?
##  c * exp(rt) - c


# Problem 4.3 - Computing the Profitability of an Investment
# Now, consider the case where the investor made a $c investment, but it was not
# paid back in full. Assume, conservatively, that no money was received from the
# borrower (often a lender will receive some but not all of the value of the 
# loan, making this a pessimistic assumption of how much is received). What is 
# the profit to the investor in this scenario?
##  -c


# Problem 5.1 - A Simple Investment Strategy
# In the previous subproblem, we concluded that an investor who invested c 
# dollars in a loan with interest rate r for t years makes c * (exp(rt) - 1) 
# dollars of profit if the loan is paid back in full and -c dollars of profit if
# the loan is not paid back in full (pessimistically).

# In order to evaluate the quality of an investment strategy, we need to compute
# this profit for each loan in the test set. For this variable, we will assume a
# $1 investment (aka c=1). To create the variable, we first assign to the profit
# for a fully paid loan, exp(rt)-1, to every observation, and we then replace 
# this value with -1 in the cases where the loan was not paid in full. All the 
# loans in our dataset are 3-year loans, meaning t=3 in our calculations. Enter 
# the following commands in your R console to create this new variable:
test$profit = exp(test$int.rate*3) - 1
test$profit[test$not.fully.paid == 1] = -1
# What is the maximum profit of a $10 investment in any loan in the testing set 
# (do not include the $ sign in your answer)?
max(test$profit) * 10
## 8.894769


# Problem 6.1 - An Investment Strategy Based on Risk
# A simple investment strategy of equally investing in all the loans would yield
# profit $20.94 for a $100 investment. But this simple investment strategy does
# not leverage the prediction model we built earlier in this problem. As stated
# earlier, investors seek loans that balance reward with risk, in that they
# simultaneously have high interest rates and a low risk of not being paid back.

# To meet this objective, we will analyze an investment strategy in which the 
# investor only purchases loans with a high interest rate (a rate of at least 
# 15%), but amongst these loans selects the ones with the lowest predicted risk
# of not being paid back in full. We will model an investor who invests $1 in 
# each of the most promising 100 loans.

# First, use the subset() function to build a data frame called highInterest 
# consisting of the test set loans with an interest rate of at least 15%.
highInterest <- subset(test, int.rate >= 0.15)
# What is the average profit of a $1 investment in one of these high-interest 
# loans (do not include the $ sign in your answer)?
mean(highInterest$profit)
## 0.2251015

# What proportion of the high-interest loans were not paid back in full?
table(highInterest$not.fully.paid)
110 / (327 + 110)
## 0.2517162


# Problem 6.2 - An Investment Strategy Based on Risk
# Next, we will determine the 100th smallest predicted probability of not paying
# in full by sorting the predicted risks in increasing order and selecting the 
# 100th element of this sorted list. Find the highest predicted risk that we 
# will include by typing the following command into your R console:
cutoff = sort(highInterest$predicted.risk, decreasing=FALSE)[100]
cutoff
# Use the subset() function to build a data frame called selectedLoans 
# consisting of the high-interest loans with predicted risk not exceeding the 
# cutoff we just computed. Check to make sure you have selected 100 loans for 
# investment.
selectedLoans <- subset(highInterest, highInterest$predicted.risk <= cutoff)
summary(selectedLoans)
str(selectedLoans)
# What is the profit of the investor, who invested $1 in each of these 100 loans
# (do not include the $ sign in your answer)?
sum(selectedLoans$profit)
## 31.27825

# How many of 100 selected loans were not paid back in full?
table(selectedLoans$not.fully.paid)
## 19

# We have now seen how analytics can be used to select a subset of the 
# high-interest loans that were paid back at only a slightly lower rate than 
# average, resulting in a significant increase in the profit from our investor's
# $100 investment. Although the logistic regression models developed in this 
# problem did not have large AUC values, we see that they still provided the 
# edge needed to improve the profitability of an investment portfolio.

# We conclude with a note of warning. Throughout this analysis we assume that 
# the loans we invest in will perform in the same way as the loans we used to 
# train our model, even though our training set covers a relatively short period
# of time. If there is an economic shock like a large financial downturn, 
# default rates might be significantly higher than those observed in the 
# training set and we might end up losing money instead of profiting. Investors 
# must pay careful attention to such risk when making investment decisions.