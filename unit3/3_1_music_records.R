# POPULARITY OF MUSIC RECORDS


# Problem 1.1 - Understanding the Data
# Use the read.csv function to load the dataset "songs.csv" into R.
# How many observations (songs) are from the year 2010?
songs <- read.csv("./data_unit3_1/songs.csv")
str(songs)
summary(songs)
table(songs$year)
## 373


# Problem 1.2 - Understanding the Data
# How many songs does the dataset include for which the artist name is "Michael
# Jackson"?
nrow(subset(songs, artistname == "Michael Jackson"))
## 18

# Problem 1.3 - Understanding the Data
# Which of these songs by Michael Jackson made it to the Top 10? Select all that
# apply.
subset(songs, 
       artistname == "Michael Jackson" & Top10 == 1,
       select = c(artistname, songtitle))
## You Rock My World, You Are Not Alone


# Problem 1.4 - Understanding the Data
# The variable corresponding to the estimated time signature (timesignature) is
# discrete, meaning that it only takes integer values (0, 1, 2, 3, . . . ). What
# are the values of this variable that occur in our dataset? Select all that
# apply.
summary(songs$timesignature)
table(songs$timesignature)
## 0    1    3    4    5    7

# Which timesignature value is the most frequent among songs in our dataset?
## 4


# Problem 1.5 - Understanding the Data
# Out of all of the songs in our dataset, the song with the highest tempo is one
# of the following songs. Which one is it?
summary(songs$tempo)
which.max(songs$tempo)
songs$tempo[6206]
nrow(subset(songs, tempo == 244.307))
songs$songtitle[6206]
## Wanna Be Startin' Somethin'


# Problem 2.1 - Creating Our Prediction Model
# We wish to predict whether or not a song will make it to the Top 10. To do
# this, first use the subset function to split the data into a training set
# "SongsTrain" consisting of all the observations up to and including 2009 song
# releases, and a testing set "SongsTest", consisting of the 2010 song releases.
SongsTrain <- subset(songs, year <= 2009)
SongsTest <- subset(songs, year == 2010)
nrow(songs)
nrow(SongsTrain) + nrow(SongsTest)
# How many observations (songs) are in the training set?
## 7201


# Problem 2.2 - Creating our Prediction Model
# In this problem, our outcome variable is "Top10" - we are trying to predict
# whether or not a song will make it to the Top 10 of the Billboard Hot 100
# Chart. Since the outcome variable is binary, we will build a logistic
# regression model. We'll start by using all song attributes as our independent
# variables, which we'll call Model 1.
# We will only use the variables in our dataset that describe the numerical
# attributes of the song in our logistic regression model. So we won't use the
# variables "year", "songtitle", "artistname", "songID" or "artistID".
# We have seen in the lecture that, to build the logistic regression model, we
# would normally explicitly input the formula including all the independent
# variables in R. However, in this case, this is a tedious amount of work since
# we have a large number of independent variables.
# There is a nice trick to avoid doing so. Let's suppose that, except for the
# outcome variable Top10, all other variables in the training set are inputs to
# Model 1. Then, we can use the formula
#   SongsLog1 = glm(Top10 ~ ., data=SongsTrain, family=binomial)
# to build our model. Notice that the "." is used in place of enumerating all
# the independent variables. (Also, keep in mind that you can choose to put
# quotes around binomial, or leave out the quotes. R can understand this
# argument either way.)
# However, in our case, we want to exclude some of the variables in our dataset
# from being used as independent variables ("year", "songtitle", "artistname", 
# "songID", and "artistID"). To do this, we can use the following trick. First
# define a vector of variable names called nonvars - these are the variables
# that we won't use in our model.
nonvars = c("year", "songtitle", "artistname", "songID", "artistID")
# To remove these variables from your training and testing sets, type the
# following commands in your R console:
SongsTrain = SongsTrain[ , !(names(SongsTrain) %in% nonvars) ]
SongsTest = SongsTest[ , !(names(SongsTest) %in% nonvars) ]
# Now, use the glm function to build a logistic regression model to predict
# Top10 using all of the other variables as the independent variables. You
# should use SongsTrain to build the model.
SongsLog1 <- glm(Top10 ~ ., data = SongsTrain, family=binomial)
# Looking at the summary of your model, what is the value of the Akaike
# Information Criterion (AIC)?
summary(SongsLog1)
## AIC: 4827.2


# Problem 2.3 - Creating Our Prediction Model
# Let's now think about the variables in our dataset related to the confidence
# of the time signature, key and tempo (timesignature_confidence, 
# key_confidence, and tempo_confidence). Our model seems to indicate that these
# confidence variables are significant (rather than the variables timesignature,
# key and tempo themselves). What does the model suggest?
## The higher our confidence about time signature, key and tempo, the more 
## likely the song is to be in the Top 10


# Problem 2.4 - Creating Our Prediction Model
# In general, if the confidence is low for the time signature, tempo, and key,
# then the song is more likely to be complex. What does Model 1 suggest in terms
# of complexity?
## Mainstream listeners tend to prefer less complex songs


# Problem 2.5 - Creating Our Prediction Model
# Songs with heavier instrumentation tend to be louder (have higher values in
# the variable "loudness") and more energetic (have higher values in the
# variable "energy").
# By inspecting the coefficient of the variable "loudness", what does Model 1
# suggest?
## Mainstream listeners prefer songs with heavy instrumentation  

# By inspecting the coefficient of the variable "energy", do we draw the same
# conclusions as above?
## No


# Problem 3.1 - Beware of Multicollinearity Issues!
# What is the correlation between the variables "loudness" and "energy" in the
# training set?
cor(SongsTrain$loudness, SongsTrain$energy)
## 0.7399067

# Given that these two variables are highly correlated, Model 1 suffers from
# multicollinearity. To avoid this issue, we will omit one of these two
# variables and rerun the logistic regression. In the rest of this problem,
# we'll build two variations of our original model: Model 2, in which we keep
# "energy" and omit "loudness", and Model 3, in which we keep "loudness" and
# omit "energy".


# Problem 3.2 - Beware of Multicollinearity Issues!
# Create Model 2, which is Model 1 without the independent variable "loudness".
# This can be done with the following command:
SongsLog2 = glm(Top10 ~ . - loudness, data=SongsTrain, family=binomial)
# We just subtracted the variable loudness. We couldn't do this with the
# variables "songtitle" and "artistname", because they are not numeric
# variables, and we might get different values in the test set that the training
# set has never seen. But this approach (subtracting the variable from the model
# formula) will always work when you want to remove numeric variables.
# Look at the summary of SongsLog2, and inspect the coefficient of the variable
# "energy". What do you observe?
summary(SongsLog2)
## Model 2 suggests that songs with high energy levels tend to be more popular.
## This contradicts our observation in Model 1.


# Problem 3.3 - Beware of Multicollinearity Issues!
# Now, create Model 3, which should be exactly like Model 1, but without the
# variable "energy".
SongsLog3 = glm(Top10 ~ . - energy, data=SongsTrain, family=binomial)
# Look at the summary of Model 3 and inspect the coefficient of the variable
# "loudness". Remembering that higher loudness and energy both occur in songs
# with heavier instrumentation, do we make the same observation about the
# popularity of heavy instrumentation as we did with Model 2?
summary(SongsLog3)
## 

# In the remainder of this problem, we'll just use Model 3.


# Problem 4.1 - Validating Our Model
# Make predictions on the test set using Model 3. What is the accuracy of Model
# 3 on the test set, using a threshold of 0.45? (Compute the accuracy as a
# number between 0 and 1.)
predSongsTest = predict(SongsLog3, type="response", newdata = SongsTest)
table(SongsTest$Top10, predSongsTest > 0.45)
(309 + 19) / nrow(SongsTest)
## 0.8793566


# Problem 4.2 - Validating Our Model
# Let's check if there's any incremental benefit in using Model 3 instead of a
# baseline model. Given the difficulty of guessing which song is going to be a
# hit, an easier model would be to pick the most frequent outcome (a song is not
# a Top 10 hit) for all songs. What would the accuracy of the baseline model be
# on the test set? (Give your answer as a number between 0 and 1.)
table(SongsTest$Top10)
314 / (314 + 59)


# Problem 4.3 - Validating Our Model
# It seems that Model 3 gives us a small improvement over the baseline model. 
# Still, does it create an edge?
# Let's view the two models from an investment perspective. A production company
# is interested in investing in songs that are highly likely to make it to the
# Top 10. The company's objective is to minimize its risk of financial losses
# attributed to investing in songs that end up unpopular.
# A competitive edge can therefore be achieved if we can provide the production
# company a list of songs that are highly likely to end up in the Top 10. We
# note that the baseline model does not prove useful, as it simply does not
# label any song as a hit. Let us see what our model has to offer.
# How many songs does Model 3 correctly predict as Top 10 hits in 2010 (remember
# that all songs in 2010 went into our test set), using a threshold of 0.45?
table(SongsTest$Top10, predSongsTest > 0.45)
## 19

# How many non-hit songs does Model 3 predict will be Top 10 hits (again, 
# looking at the test set), using a threshold of 0.45?
## 5


# Problem 4.4 - Validating Our Model
# What is the sensitivity of Model 3 on the test set, using a threshold of 0.45?
19 / (40 + 19)
## 0.3220339

# What is the specificity of Model 3 on the test set, using a threshold of 0.45?
309 / (309 + 5)
## 0.9840764


# Problem 4.5 - Validating Our Model
# What conclusions can you make about our model? (Select all that apply.)
## - Model 3 favors specificity over sensitivity.
## - Model 3 provides conservative predictions, and predicts that a song will
##   make it to the Top 10 very rarely. So while it detects less than half of
##   the Top 10 songs, we can be very confident in the songs that it does 
##   predict to be Top 10 hits.