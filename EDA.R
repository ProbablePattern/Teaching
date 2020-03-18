require(data.table)
FF=read.csv("~/Downloads/FF_Factors_weekly.CSV",skip=4)
FF=as.data.table(FF)
colnames(FF)=c("Date","MRP","SMB","HML","RF")
FF[,Date:=as.Date(as.character(Date),"%Y%m%d")]

FF[,L.HML:=c(NA,head(HML,-1))]
FF[,L2.HML:=c(NA,head(L.HML,-1))]
FF[,L.MRP:=c(NA,head(MRP,-1))]
head(FF)

# Negative Return on the market
bad=FF[MRP<0]
summary(bad)
recent=FF
recent=FF[Date>'2012-01-01']
recent=FF[Date>'2012-01-01' & MRP<0]


summary(lm(HML~MRP,data=recent))
summary(lm(HML~L.MRP+L.HML+L2.HML+SMB+MRP,data=recent))
summary(lm(MRP~L.HML+L.MRP,data=recent))