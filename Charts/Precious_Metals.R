# Charts Gold prices in USD from Oanda
require(quantmod)
#fetch data
getSymbols(c("XAU/USD","XPT/USD","XPD/USD","XAG/USD"),src="oanda")
#setup the plot area, each TA is another graph
layout(matrix(1:4, nrow=2))
#charts to be included
chartSeries(XAUUSD,name="Gold (.oz) in USD", layout=NULL)
chartSeries(XPTUSD,name="Platinum (.oz) in USD", layout=NULL)
chartSeries(XPDUSD,name="Palladium (.oz) in USD", layout=NULL)
chartSeries(XAGUSD,name="Silver (.oz) in USD", layout=NULL)
