#### Using polars for data analysis
#Install with:
#conda install polars

import polars as pl

# Windows WSL
os.chdir("/mnt/c/Users/Rush/code/")

df = pl.read_csv("https://j.mp/iriscsv")
print(df.filter(pl.col("sepal_length") > 5)
      .groupby("species")
      .agg(pl.all().sum())
)



query=pl.scan_csv('data.csv')
query.collect()