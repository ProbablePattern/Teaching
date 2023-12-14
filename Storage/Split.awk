#!/usr/bin/awk -f
# Example:
# gawk -f /Data/Dropbox/Workspace/Command\ Line/Split.awk Ticker.csv
BEGIN{ FS=","; OFS=","; filename="" }
{
  # Skip the header
  if(NR==1) {
    # Extract year, month, and day from 2nd col
    yyyy=substr($5,1,4)
    #mm=substr($5,5,2)
    # Filename
    if(filename != yyyy) {
      # close old file
      close(filename)
      # assign new filename
      filename=yyyy
    }
    # Write columns
    print $0 >>filename".csv"
  }
}
