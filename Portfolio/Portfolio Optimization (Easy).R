#### Portfolio Optimization ######
install.packages(c("tidyquant","data.table","ggplot2","doParallel")) # Only run this line once

require(tidyquant)
require(readxl)
require(foreach)
require(doParallel)
require(data.table)

#### Set Number of Processing Cores ####
registerDoParallel(detectCores()-1) # Mac or Linux
#registerDoParallel(max((detectCores()/2)-1,1)) # Windows
print(paste("This machine has",detectCores(),"cores and is using",getDoParWorkers(),"core(s)."))

#### Working Directory ####
setwd("/Users/s73f4n/code/Teaching/Portfolio")

#### S&P 500 sector weights (used for comparison) ####
Benchmark=c(0.257, 0.158, 0.117, 0.098, 0.087, 0.072, 0.073, 0.052, 0.027, 0.032, 0.027)

#### Load and Prepare Data ####
data=read_excel("Data/Bloomberg Collection.xlsx",sheet="Static",skip=3,col_names=FALSE)
colnames(data)=c("Date",colnames(read_excel("Data/Bloomberg Collection.xlsx",sheet="Static",n_max = 0)))
data=as.data.table(data)

# Forward-Looking Expectations
RP=read_excel("Data/Bloomberg Collection.xlsx",sheet="Static",n_max=2)
RP=as.data.table(RP)
colnames(RP)[1]="Series"
rf=mean(tail(data$RF,3)); RP[,RF:=c(0,rf)]
returns=as.numeric(RP[2,3:ncol(RP)])

#### Covariance Matrix of Risky Assets ####
Sigma=cov(data[,3:ncol(data)])

#### Specify Starting Weights ####
weight0=rep(1/nrow(Sigma),nrow(Sigma)) # Equal Weights

# Performance Not Optimized
rp=t(weight0) %*% returns # Risk Premium
sd=sqrt(t(weight0) %*% (Sigma %*% weight0)) # Standard Deviation
sharpe=rp/sd # Sharpe Ratio

# Set up Performance Tracking
performance0=c(weight0,rp,sd,sharpe)
performance0=as.data.table(t(performance0))
tickers=colnames(RP[,3:ncol(RP)])
names(performance0)=c(tickers,"RiskPremium","SD","Sharpe")
performance0

#### Optimize Long-only using Random Weights #####
performance=foreach(i=1:50000,.combine=rbind) %dopar% {
  weights=runif(length(weight0)) # Long-only
  weights=weights/sum(weights) # Weights constrained to 100%
  rp=t(weights) %*% returns # Risk Premium
  sd=sqrt(t(weights) %*% (Sigma %*% weights)) # Standard Deviation
  sharpe=rp/sd # Sharpe Ratio
  performance=as.data.table(t(c(weights,rp,sd,sharpe)))
  names(performance)=c(tickers,"RiskPremium","SD","Sharpe")
  return(performance)
}

# Create Index Portfolio
weights=Benchmark
weights=weights/sum(weights)
rp=t(weights) %*% returns[1:11] # Risk Premium
sigma=cov(data[,3:13])
sd=sqrt(t(weights) %*% (sigma %*% weights)) # Standard Deviation
sharpe=rp/sd # Sharpe Ratio
index=as.data.table(t(c(weights,rp,sd,sharpe)))
names(index)=c(tickers[1:11],"RiskPremium","SD","Sharpe")

# Identify Minimum Variance and Tangency Portfolios
MinVar=performance[which.min(performance$SD),]; MinVar
Tangency=performance[which.max(performance$Sharpe),]; Tangency

#### Visualization ####
require(ggplot2)

# Calculate graph parameters
label1=c(quantile(performance$SD,.015),quantile(performance$RiskPremium,.99))
label2=c(quantile(performance$SD,.01),min(performance$RiskPremium)*.99)
label3=c(quantile(performance$SD,.5),quantile(performance$RiskPremium,.999))

# Offsets for arrows
offset1=c(abs(label1[1]-Tangency$SD),abs(label1[2]-Tangency$RiskPremium))/20
offset2=c(abs(label2[1]-MinVar$SD),abs(label2[2]-MinVar$RiskPremium))/10
offset3=c(abs(label3[1]-index$SD),abs(label3[2]-index$RiskPremium))/10

# Graph the Frontier
ggplot(performance,aes(x=SD, y=RiskPremium, color=Sharpe)) +
  geom_point() + theme_classic() +
  scale_y_continuous(labels=scales::percent) +
  scale_x_continuous(labels=scales::percent) +
  labs(x='Daily Standard Deviation', y='Daily Risk Premium',
       title="Efficient Frontier using Random Portfolios") +
  geom_point(aes(x=SD, y=RiskPremium), data=Tangency, color='red') +
  geom_point(aes(x=SD, y=RiskPremium), data=MinVar, color='red') +
  geom_point(aes(x=SD, y=RiskPremium), data=index, color='red') +
  annotate('text', x=label1[1], y=label1[2], label="Tangency Portfolio \n (Market Portfolio)")+
  annotate('text', x=label2[1], y=label2[2], label="Min Variance Portfolio") +
  annotate('text', x=label3[1], y=label3[2], label="Index Portfolio") +
  annotate(geom='segment', x=label1[1], xend=Tangency$SD+offset1[1],
           y=label1[2]-2*offset1[2], yend=(Tangency$RiskPremium+offset1[2]),
           color='red', arrow=arrow(type="open")) +
  annotate(geom='segment', x=label2[1], xend=MinVar$SD+offset2[1],
           y=label2[2]+offset2[2], yend=(MinVar$RiskPremium-offset2[2]),
           color='red', arrow=arrow(type="open")) +
  annotate(geom='segment', x=label3[1], xend=index$SD,
           y=label3[2]-offset3[2], yend=(index$RiskPremium+offset3[2]),
           color='red', arrow=arrow(type="open"))

#### Performance Improvement over Equal-Weighted Portfolio
# Match risk and calculate return improvement
performance0$Sharpe # Equal-Weight Portfolio Sharpe Ratio
Tangency$Sharpe # Tangency Portfolio Sharpe Ratio
# Equal-Weighted Portfolio Return/Year (in percent)
(performance0$RiskPremium+rf)*252*100
# Levered Estimated Tangency Return/Year (in percent with no compounding)
(Tangency$Sharpe*performance0$SD+rf)*252*100
# Return Improvement/year (in percent with no compounding)
(Tangency$Sharpe*performance0$SD-performance0$RiskPremium)*25200

# AUM (in millions) necessary for performance improvement to justify 6-figure/year salary
100000/((Tangency$Sharpe*performance0$SD-performance0$RiskPremium)*252)/1000000


#### Data Description #####
#Single Spreadsheet
#Line 1: Tickers
#Line 2: Beta
#Line 3: Expected Returns
#Line 4-end: returns
# Column 1: Dates
# Column 2: risk-free rate
# Column 3-end: risk assets

