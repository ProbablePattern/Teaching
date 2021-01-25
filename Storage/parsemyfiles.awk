#!/usr/bin/awk -f
# parse_files.awk
#
# Decent tutorials:
# http://www.grymoire.com/Unix/Awk.html
# http://docstore.mik.ua/orelly/unix3/sedawk/
#
BEGIN{ FS=","; OFS=","; filename="" }
{
  if(filename != $1) {
    close(filename)                # close old file
    filename=$1                    # assign new filename
  }
  # Extract year, month, and day from 2nd col
  yyyy=substr($2,1,4)
  mm=substr($2,5,2)
  dd=substr($2,7,2)
  # Get H:M:S and append leading zero
  hms=$3
  if(length($3)==7) {
    hms="0"hms
  }
  # Write datetime column
  printf("%s-%s-%s %s,",yyyy,mm,dd,hms) >>filename".csv"
  # Write remaining columns
  print $4,$5,$6,$7,$8,$9 >>filename".csv"

}

