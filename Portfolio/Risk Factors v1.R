# Use Fama-French 3 Factor Model to estimate betas and alpha
# install packages once, require packages each time you run the script
install.packages(c('quantmod','xts'))
require(quantmod); require(xts)

# Load FF3 data from French's website
factors=read.csv(file="C:\\Users\\srrush\\Downloads\\FF3.CSV",header=TRUE)
#factors=read.csv(file="FF3_Daily.CSV",header=TRUE)
#factors=FF3

# Look at the beginning of the data
head(factors)
colnames(factors)=c("Date","MRP","SMB","HML","RF")

# Statistical summary of the data
summary(factors)

# If not in decimal format, run this
factors[,2:5]=factors[,2:5]/100

# Format dates as daily date data
factors[,'Date']=as.Date(as.character(factors[,'Date']),'%Y%m%d')

# Remove rows with missing observations
factors=na.omit(factors)

# Convert to XTS format for time series
factors=as.xts(factors[,c('MRP','SMB','HML','RF')],order.by=factors[,'Date'])

# Check the data
head(factors['2018-01-01/2018-02-01'])

#################################################################################
# Load portfolio returns
#returns=read.csv(file="C:\\Users\\srrush\\Downloads\\BGSU.csv",header=TRUE)
#returns=read.csv(file="BGSU.csv",header=TRUE)
value=Weekly; rm(Weekly)

# Only use first 2 columns: date and return
value=value[,1:2]
colnames(value)=c('Date','Value')

# Format date as daily date data
value[,'Date']=as.Date(as.character(value[,'Date']),'%m/%d/%Y')

# Check the data
head(value)

# Remove missing observations
value=na.omit(value)
value=as.xts(as.numeric(value[,2]),order.by=value[,1])
returns=periodReturn(value,period="weekly")
#returns1=periodReturn[value,period='weekly']

# Merge factors and portfolio returns
data=merge.xts(returns,factors)
colnames(data)[1]="returns"

# Check the data
head(data)
tail(data)
# Remove missing observations
data=na.omit(data)

# Calculate the risk premium of the portfolio (either syntax)
data$RP=as.numeric(data$returns-data$RF)
#data[,'RP']=as.numeric(data[,'returns']-data[,'RF'])

# Define the model and run the regression
m1=RP~MRP+SMB+HML; ols=lm(m1,data)
#m2=RP~Mkt.RF; ols=lm(m2,data)

# Show the regression output
summary(ols)

# Show a different time period
ols=lm(m1,data=data['2020-01-01/2020-09-01']); summary(ols)
