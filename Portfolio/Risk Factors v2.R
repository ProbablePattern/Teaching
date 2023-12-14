# Run once
#install.packages("tidyquant")

# Run each time
require(tidyquant)

#### Define file location
# Windows in Downloads folder named "code" with username "Classroom"
setwd("C:\\Users\\Classroom\\Downloads\\R\\")
# Mac in Downloads folder named "R" with username "srrush"
setwd("/Users/s73f4n/code/Teaching/Portfolio")

fund=read.csv("Data/Portfolio Values 2023.csv",header=TRUE)

head(fund)
str(fund)
fund=fund[,1:2]
colnames(fund)=c('Date','Value')

# Format date as daily date data
fund[,"Date"]=as.Date(fund[,"Date"],format="%m/%d/%y")

# Mac Users may need to use this line instead if you have 2 digit year
#fund[,"Date"]=as.Date(fund[,"Date"],format="%m/%d/%y")

fund=as.xts(unlist(fund[,"Value"]),order.by=unlist(fund[,"Date"]))
colnames(fund)="Value"
fund=merge(fund,periodReturn(fund,period="daily"))
colnames(fund)=c("Value","Return")

# Factors
factors=read.csv(file="Data/FF5 2023.CSV",header=TRUE,skip=3)

head(factors)
# Format date as daily date data
factors[,"Date"]=as.Date(as.character(factors[,1]),format="%Y%m%d")
factors[,1]=NULL
# Decimal Format
factors[,1:6]=factors[,1:6]/100

factors=as.xts(factors[,1:6],order.by=unlist(factors[,7]))

# Merge
data=merge(fund,factors)
data=data[!is.na(data[,2])]
data=data[!is.na(data[,3])]
summary(data)

# Calculate Risk Premium
RP=data[,"Return"]-data[,"RF"]
colnames(RP)="RP"
data=merge(data,RP)

# APT model
m1=RP~Mkt.RF+SMB+HML+RMW+CMA
summary(lm(m1,data=data["2022-01-01/2022-12-31"]))

# Subsets
#subset1=data["2021-01-01/2021-04-30"]
#subset2=data["2021-05-01/"]

# If data is not available for the current year
subset1=data["2020-01-01/2020-06-30"]
subset2=data["2020-07-01/2020-12-31"]

summary(lm(m1,data=subset1))
summary(lm(m1,data=subset2))

#########################################################################################
#########################################################################################
#### q factor model #####################################################################
#########################################################################################
require(tidyquant)

# For Windows Users Only
fund=read.csv("Portfolio Values 2022.csv",header=TRUE)

# For Mac Users Only
fund=read.csv("Portfolio Values 2022.csv",header=TRUE)

head(fund)
str(fund)
fund=fund[,1:2]
colnames(fund)=c('Date','Value')

# Format date as daily date data
fund[,"Date"]=as.Date(fund[,"Date"],format="%m/%d/%Y")

fund=as.xts(unlist(fund[,"Value"]),order.by=unlist(fund[,"Date"]))
colnames(fund)="Value"
fund=merge(fund,periodReturn(fund,period="daily"))
colnames(fund)=c("Value","Return")

# Factors
qfactors=read.csv(file="q5_factors_daily_2021.csv")
head(qfactors)
# Format date as daily date data
qfactors[,"Date"]=as.Date(as.character(qfactors[,1]),format="%Y%m%d")
qfactors[,1]=NULL
# Decimal Format
qfactors[,1:6]=qfactors[,1:6]/100

qfactors=as.xts(qfactors[,1:6],order.by=unlist(qfactors[,7]))

head(qfactors)

# Merge
data=merge(fund,qfactors)
data=data[!is.na(data[,3])]
data=data[!is.na(data[,'Return'])]
summary(data)

# Calculate Risk Premium
RP=data[,"Return"]-data[,"R_F"]
colnames(RP)="RP"
data=merge(data,RP)

# APT model
m2=RP~R_MKT+R_ME+R_IA+R_ROE+R_EG
summary(lm(m2,data=data["2021-01-01/2021-12-31"]))

# Subsets
#subset1=data["2021-01-01/2021-04-30"]
#subset2=data["2021-05-01/"]

# If data is not available for the current year
subset1=data["2020-01-01/2020-06-30"]
subset2=data["2020-07-01/2020-12-31"]

summary(lm(m2,data=subset1))
summary(lm(m2,data=subset2))
