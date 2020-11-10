# Dr. Rush's Awesome Script
install.packages('foreach')
install.packages('quantmod') 
install.packages('foreach')
install.packages('xts')
require(quantmod); require(xts); require(foreach)

# Download Style Returns
#styles=c('VV','VO','VB','VEU','VGSH','VTV','VUG','VOT','VBR','VBK')
styles=c('VEU','VGSH','VTV','VUG','VOT','VBR','VBK')
getSymbols(styles,src='yahoo')

style.returns=foreach(i=styles,.combine='cbind') %do% {
periodReturn(get(i),period='daily')
}
colnames(style.returns)=styles
style.returns=na.omit(style.returns)
head(style.returns)
#rm(VV,VO,VB,VEU,VGSH,VTV,VUG,VOT,VBR,VBK)
rm(i,styles)

# Load Portfolio Returns
returns=read.csv(file="C:\\Users\\srrush\\Downloads\\Daily.csv",header=TRUE)
colnames(returns)=c('Date','Value')
head(returns)

# Format date as daily date data
returns[,'Date']=as.Date(as.character(returns[,'Date']),'%m/%d/%Y')
head(returns)
returns=na.omit(returns)
returns=as.xts(as.numeric(returns[,2]),order.by=returns[,1])
returns=periodReturn(returns,period="daily")
colnames(returns)='Portfolio'
head(returns)
# Merge
data=merge.xts(returns,style.returns)
data=na.omit(data)
head(data)

# Regression
#m1=Portfolio~VV+VO+VB+VEU+VGSH+VTV+VUG+VOT+VBR+VBK
m2=Portfolio~VEU+VGSH+VTV+VUG+VOT+VBR+VBK
ols=lm(m2,data=data)
summary(ols)
