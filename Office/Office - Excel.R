#### Microsoft Office with R (Excel) ####
install.packages("readXL")

require(readxl)

#### Working Directory ####
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

#### Data Description #####
#Single Spreadsheet
#Line 1: Tickers
#Line 2: Beta
#Line 3: Expected Returns
#Line 4-end: returns
# Column 1: Dates
# Column 2: risk-free rate
# Column 3-end: risk assets