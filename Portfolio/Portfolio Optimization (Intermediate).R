
install.packages(c("PortfolioAnalytics","DEoptim","ROI","data.table","readxl"))
require(PortfolioAnalytics)
require(doParallel)
require(data.table)
require(readxl)
require(DEoptim); require(ROI); require(ROI.plugin.glpk); require(ROI.plugin.quadprog)

#### Set Number of Processing Cores
registerDoParallel(detectCores()-1) # Mac or Linux
#registerDoParallel(max((detectCores()/2)-1,1)) # Windows
print(paste("This machine has",detectCores(),"cores and is using",getDoParWorkers(),"core(s)."))

#### Working Directory
setwd("/Users/s73f4n/code/Teaching/Portfolio")

#### Load and Prepare Data
data=read_excel("Data/Bloomberg Collection.xlsx",sheet="Static",skip=3,col_names=FALSE)
colnames(data)=c("Date",colnames(read_excel("Data/Bloomberg Collection.xlsx",sheet="Static",n_max = 0)))
data=as.xts(data)

RP=read_excel("Data/Bloomberg Collection.xlsx",sheet="Static",n_max=2)
RP=as.data.table(RP)
colnames(RP)[1]="Series"
RP[,RF:=c(0,mean(tail(data$RF,3)))]
#returns=as.numeric(RP[2,3:ncol(RP)])

data=data[,2:ncol(data)] # Prep only for PortfolioAnalytics

type=c(rep("ETF",11),rep("Stock",ncol(data)-11))

Benchmark=c(0.257, 0.158, 0.117, 0.098, 0.087, 0.072, 0.073, 0.052, 0.027, 0.032, 0.027)

sectors=c("Tech","Healthcare","Financials","ConsumerDisc","Industrials","ConsumerStaples",
          "Comms","Energy","Materials","Utilities","RealEstate")

sector=list(Tech=c(1,12:15),Healthcare=c(2,16:18),Financials=c(3,19:22),ConsumerDisc=c(4,23),
            Industrials=c(5,24:26),ConsumerStaples=c(6,27:30),Comms=c(7),Energy=c(8,31),
            Materials=c(9,32),Utilities=c(10,33),RealEstate=c(11,34))

stocks=colnames(data)[12:ncol(data)]

P=portfolio.spec(assets=colnames(data), category_labels=type, weight_seq=c(Benchmark,rep(0,ncol(data)-11)))
P=add.constraint(P, type="long_only"); P=add.constraint(P, type="weight_sum", min_sum=0.99, max_sum=1.01)
P=add.objective(portfolio=P, type="return", name="mean")
P=add.objective(portfolio=P, type="risk", name="StdDev")
# Active Sector Weights limited to +/- 2%
P=add.constraint(P, type="group", groups=sector, group_min=Benchmark-0.02,
                 group_max=Benchmark+0.02, group_labels=sectors)
# Stocks limited to 2%
P=add.constraint(P, type="box", min=rep(0,ncol(data)), max=c(rep(1,11),rep(0.02,ncol(data)-11)))

# R Optimization Infrastructure (ROI)
maxSR=optimize.portfolio(R=data, portfolio=P, optimize_method="ROI", trace=TRUE)
maxSR
as.numeric(maxSR$opt_values$mean/maxSR$opt_values$StdDev)
chart.RiskReward(maxSR, risk.col="StdDev", return.col="mean")

# DE Optimization
#maxSR=optimize.portfolio(R=data, portfolio=P, optimize_method="DEoptim", search_size=999999, trace=TRUE, traceDE=100)
#maxSR$DEoptim_objective_results[[1]]$objective_measures$mean/maxSR$DEoptim_objective_results[[1]]$objective_measures$StdDev
#chart.RiskReward(maxSR, risk.col="StdDev", return.col="mean")

#### Efficient Frontier
meanvar.ef=create.EfficientFrontier(R=data, portfolio=P, type="mean-StdDev")
chart.EfficientFrontier(meanvar.ef, match.col="StdDev", type="l", RAR.text="Sharpe Ratio", pch=4)
#chart.EfficientFrontier(meanvar.ef, match.col="StdDev", type="b", rf=RP$RF[2])
#chart.EfficientFrontier(meanvar.ef, match.col="StdDev", type="l", tangent.line=FALSE)
