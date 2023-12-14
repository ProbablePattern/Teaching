#!/usr/bin/awk -f
# Create ticker index from filenames
# Example: ls /Data/Drobo/Research/2011/Stocks2011 | gawk '{print >> "Ticker.csv"}'
# gawk -f /Data/Dropbox/Workspace/Command\ Line/Ticker_Index.awk Ticker.csv
BEGIN{ FS=","; OFS="," }
{
  split($1,tick,".",seps)
  print tick[1] >> "Tickers.csv"
}