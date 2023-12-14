library(quantmod)
getSymbols("DGS1",src="FRED") #1 Year US Treasury Daily Constant Maturity rate
getSymbols("DPRIME",src="FRED") #Daily Prime Loan Rate
getSymbols("DAAA",src="FRED") #Daily Moody's Aaa Corporate Bond Yield
getSymbols("DBAA",src="FRED") #Daily Moody's Baa Corporate Bond Yield
getSymbols("MORTG",src="FRED") #30 Year Conventional Mortgage Rate
getSymbols("FII10",src="FRED") #10 Year TIPS Constant Maturity
# Chart Data
layout(matrix(1:6, nrow=3))
chartSeries(last(DGS1,'36 months'),name="US Treasury 1 Year Constant Maturity",layout=NULL)
chartSeries(last(FII10,'36 months'),name="10 Year TIPS Constant Maturity",layout=NULL)
chartSeries(last(MORTG,'36 months'),name="30 Year Fixed Mortgage Rate",layout=NULL)
chartSeries(last(DPRIME,'36 months'),name="Prime Loan Rate",layout=NULL)
chartSeries(last(DAAA,'36 months'),name="Moody's Aaa Corporate Yield",layout=NULL)
chartSeries(last(DBAA,'36 months'),name="Moody's Baa Corporate Yield",layout=NULL)
