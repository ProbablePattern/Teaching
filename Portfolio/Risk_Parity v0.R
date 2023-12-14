#### Risk Parity ##############################################################
# Prepare packages
#install.packages(c('quantmod','PortfolioAnalytics','foreach'))
#install.packages(c('DEoptim','ROI','ROI.plugin.glpk','ROI.plugin.quadprog'))
#install.packages('riskParityPortfolio')

# Start to run the script here
require(quantmod)
require(foreach)

# Download (Returns)
# VTSAX = Total Stock Market Index Fund
# VTIAX = Total International Stock Index Fund
# VGSH = Short Term Treasury
# VBTLX = Total Bond Market Index Fund (Investment Grade)

# Define the set of financial assets
assets=c('VTSAX','VTIAX','VGSH','VBTLX')
#assets=c('VTSAX','VTIAX','VBTLX')

#Download prices from Yahoo Finance
getSymbols(assets,src='yahoo')

# Calculate monthly returns from prices and combine them
asset.returns=foreach(i=assets,.combine='cbind') %do% {
  periodReturn(get(i),period='monthly')
}
# Rename the columns with the tickers of the assets
colnames(asset.returns)=assets

# Check the data
head(asset.returns)

# Remove rows with missing observations
asset.returns=na.omit(asset.returns)

# Check the top and bottom of the data
head(asset.returns)
tail(asset.returns)

# Calculate the mean return of each asset by applying 'mean' by column 
Returns=apply(asset.returns,2,mean)

#### Expected Performance
# Find the risk-free rate and divide by 12 for monthly rf
rf=.0013/12

# The return on the equal-weighted portfolio is the mean of the expected returns
return_e=mean(Returns)

# Calculate variance using a weight vector that changes based on the number of assets
ew=length(Returns)
var_e=t(rep(1/ew,ew)) %*% cov(asset.returns) %*% rep(1/ew,ew)

# Sharpe ratio of the equal-weighted portfolio
Sharpe_e=(return_e-rf)/sqrt(var_e)


#### Mean-Variance
require(PortfolioAnalytics)
require(DEoptim)
require(ROI)
require(ROI.plugin.glpk)
require(ROI.plugin.quadprog)

# Define the portfolio specification for the Portfolio Analytics package
pspec=portfolio.spec(assets=assets)

# Weights sum to 1
pspec=add.constraint(portfolio=pspec, type="weight_sum",min_sum=1,max_sum=1)

# No negative weights (Long-only)
pspec=add.constraint(portfolio=pspec, type="long_only")

# Maximize Sharpe ratio
pspec=add.objective(portfolio=pspec, type="return", name="mean")
pspec=add.objective(portfolio=pspec, type="risk", name="StdDev")

# Run the portfolio optimizer in Portfolio Analytics
out=optimize.portfolio(R=asset.returns,portfolio=pspec,optimize_method="ROI",maxSR=TRUE,trace=TRUE)

# The full output is messy
#summary(out)

# Just show the optimal weights
out$weights

# Look at the data structure of the output
str(out)

# Show the mean return and standard deviation of the efficient portfolio
out$objective_measures$mean
out$objective_measures$StdDev

# Sharpe ratio of the mean-variance efficient portfolio
Sharpe=(out$objective_measures$mean-rf)/out$objective_measures$StdDev


#### Risk Parity Portfolio
require(riskParityPortfolio)

# Use the package to calculate the risk parity portfolio
rpp=riskParityPortfolio(cov(asset.returns))

# Show the weights of the risk parity portfolio
rpp

# Show the data structure of the output
str(rpp)

# Calculate the return of the risk parity portfolio
return_rp=t(rpp$w) %*% Returns

# Calculate the variance of the risk parity portfolio
var_rp=t(rpp$w) %*% cov(asset.returns) %*% rpp$w

# Sharpe ratio of the risk parity portfolio
Sharpe_rp=(return_rp-rf)/sqrt(var_rp)



##### Compare the Share ratios of each of the three portfolios
Sharpe
Sharpe_e
Sharpe_rp

#### Use leverage on Risk Parity
# Find weight to make expected return equal to mean-variance expected return
# MV = w*RP-(1-w)*rf
w=(out$objective_measures$mean + rf)/(return_rp + rf)

# Calculate Sharpe ratio of levered Risk Parity Portfolio
Sharpe_lrp=(out$objective_measures$mean - rf) / sqrt(w*var_rp)

##### Compare the Sharpe ratios of each of the four portfolios
Sharpe
Sharpe_e
Sharpe_rp
Sharpe_lrp
