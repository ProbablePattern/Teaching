# Run once
#install.packages("tidyquant")

# Run each time
require(tidyquant)

# For Windows Users Only
fund=read.csv("C:\\Users\\srrush\\Downloads\\fund.csv",header=TRUE)

# For Mac Users Only
fund=read.csv("/Users/srrush/Downloads/fund.csv",header=TRUE)

head(fund)
str(fund)
fund=fund[,1:2]
colnames(fund)=c('Date','Value')

# Format date as daily date data
fund[,"Date"]=as.Date(fund[,"Date"],format="%m/%d/%Y")

# Mac Users may need to use this line instead
fund[,"Date"]=as.Date(fund[,"Date"],format="%m/%d/%y")

fund=as.xts(unlist(fund[,"Value"]),order.by=unlist(fund[,"Date"]))
colnames(fund)="Value"
fund=merge(fund,periodReturn(fund,period="daily"))
colnames(fund)=c("Value","Return")

# Factors
factors=read.csv(file="C:\\Users\\srrush\\Downloads\\FF5.CSV",header=TRUE,skip=3)
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
summary(lm(m1,data=data))
  
# Subsets
subset1=data["2021-01-01/2021-03-31"]
subset2=data["2021-03-31/"]
