# Dr. Rush's Awesome Script
#install.packages('foreach')
require(tidyquant); require(foreach)

#### Define file location
# Windows in Downloads folder named "R" with username "Classroom"
setwd("C:\\Users\\Classroom\\Downloads\\R\\")
# Mac in Downloads folder named "R" with username "srrush"
setwd("/Users/s73f4n/code/Teaching/Portfolio")

#### For Dr. Rush #####################################
setwd("C:\\Users\\srrush\\code\\Teaching\\Portfolio\\")
# USB Drive (alternative)
setwd("D:\\code\\")
#######################################################

# Load Portfolio Returns
returns=read.csv(file="Data/Portfolio Values 2023.csv",header=TRUE)
colnames(returns)=c('Date','Value')
returns=returns[,1:2]
head(returns)

# Format date as daily date data
returns[,'Date']=as.Date(as.character(returns[,'Date']),'%m/%d/%y')
head(returns)
returns=na.omit(returns)
returns=as.xts(as.numeric(returns[,2]),order.by=returns[,1])
returns=periodReturn(returns,period="daily")
colnames(returns)='Portfolio'
head(returns)

# Download Style Returns
styles=c('VEU','VTV','VUG','VBR','VBK')
style.names=c('International','Large.Value','Large.Growth','Small.Value','Small.Growth')
getSymbols(styles,src='yahoo',auto.assign=TRUE)

style.returns=foreach(i=styles,.combine='cbind') %do% {
  periodReturn(get(i),period='daily')
}

colnames(style.returns)=style.names
style.returns=na.omit(style.returns)
head(style.returns)


# Merge
data=merge.xts(returns,style.returns)
data=na.omit(data)
head(data)

# Select Subset (one at a time)
subset=data["2022-01-01/"] # Current Year
subset=data["2022-01-01/2022-04-30"] # First Half
subset=data["2022-05-01/"] # Second Half

# Standardize Data
subset=reclass(apply(subset,MARGIN=2,FUN=scale),match.to=subset)
head(subset)
summary(subset)

# Regression
m1=Portfolio~International+Large.Value+Large.Growth+Small.Value+Small.Growth
ols=lm(m1,data=subset)
summary(ols)
