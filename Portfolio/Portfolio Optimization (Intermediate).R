#### Constrained Portfolio Optimization
install.packages(c("PortfolioAnalytics","readxl","doParallel"))
install.packages(c("ROI","ROI.plugin.glpk","ROI.plugin.quadprog","DEoptim"))

require(PortfolioAnalytics)
require(doParallel)
require(readxl)
require(DEoptim)
require(ROI); require(ROI.plugin.glpk); require(ROI.plugin.quadprog)

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
data=data[,2:ncol(data)] # Only risk assets

#### Specify Forward-looking Expectations
RP=read_excel("Data/Bloomberg Collection.xlsx",sheet="Static",n_max=2)
colnames(RP)[1]="Series"
Ereturns=as.numeric(RP[2,3:ncol(RP)])
# Create stat moment assumptions
momentargs = list()
momentargs$mu = Ereturns
momentargs$sigma=cov(data)
momentargs$m3=matrix(0, nrow=ncol(data), ncol=ncol(data)^2)
momentargs$m4=matrix(0, nrow=ncol(data), ncol=ncol(data)^3)

#### Security Type, Sectors, and Benchmark
type=c(rep("ETF",11),rep("Stock",ncol(data)-11))

Benchmark=c(0.257, 0.158, 0.117, 0.098, 0.087, 0.072, 0.073, 0.052, 0.027, 0.032, 0.027)

sectors=c("Tech","Healthcare","Financials","ConsumerDisc","Industrials","ConsumerStaples",
          "Comms","Energy","Materials","Utilities","RealEstate")

sector=list(Tech=c(1,12:15),Healthcare=c(2,16:18),Financials=c(3,19:22),ConsumerDisc=c(4,23),
            Industrials=c(5,24:26),ConsumerStaples=c(6,27:30),Comms=c(7),Energy=c(8,31),
            Materials=c(9,32),Utilities=c(10,33),RealEstate=c(11,34))

stocks=colnames(data)[12:ncol(data)]


#### Portfolio Specification
P=portfolio.spec(assets=colnames(data), category_labels=type,
                 weight_seq=c(Benchmark,rep(0,ncol(data)-11)))
#P=add.constraint(P, type="long_only") # Not needed when using box constraint
P=add.constraint(P, type="weight_sum", min_sum=1, max_sum=1)
P=add.objective(portfolio=P, type="return", name="mean")
P=add.objective(portfolio=P, type="risk", name="StdDev")
# Active Sector Weights limited to +/- 2%
P=add.constraint(P, type="group", groups=sector, group_min=Benchmark-0.02,
                 group_max=Benchmark+0.02, group_labels=sectors)
# Stocks limited to 2%
P=add.constraint(P, type="box", min=rep(0,ncol(data)), max=c(rep(1,11),rep(0.02,ncol(data)-11)))

# R Optimization Infrastructure (ROI)
maxSR=optimize.portfolio(R=data, portfolio=P, optimize_method="ROI")
maxSR; as.numeric(maxSR$opt_values$mean/maxSR$opt_values$StdDev)

# Optimize with Expected Returns
maxSR=optimize.portfolio(R=data, portfolio=P, optimize_method="ROI", momentargs=momentargs)
maxSR; as.numeric(maxSR$opt_values$mean/maxSR$opt_values$StdDev)

# DE Optimization
#maxSR=optimize.portfolio(R=data, portfolio=P, optimize_method="DEoptim", search_size=999999, trace=TRUE, traceDE=100)
#maxSR$DEoptim_objective_results[[1]]$objective_measures$mean/maxSR$DEoptim_objective_results[[1]]$objective_measures$StdDev
#chart.RiskReward(maxSR, risk.col="StdDev", return.col="mean")

#### Efficient Frontier of feasible portfolios
meanvar.ef=create.EfficientFrontier(R=data, portfolio=P, type="mean-StdDev")
chart.EfficientFrontier(meanvar.ef, match.col="StdDev", type="l", RAR.text="Sharpe Ratio", pch=4)

#### Data Description #####
#Single Spreadsheet
#Line 1: Tickers
#Line 2: Beta
#Line 3: Expected Returns
#Line 4-end: returns
# Column 1: Dates
# Column 2: risk-free rate
# Column 3-end: risk assets
