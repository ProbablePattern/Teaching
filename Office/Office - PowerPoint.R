#### Microsoft Office with R (PowerPoint) ####
install.packages(c("tidyquant","dplyr","timetk","officer"))

require(tidyquant) # fetch data
require(dplyr) # data munging
require(timetk) # Plot
require(officer) # Powerpoint

#### Working Directory ####
setwd("/Users/s73f4n/code/Teaching/Office")
# Create a blank PowerPoint presentation called stock_report.pptx in this directory

### Get Data ####
stock_data_tbl = c("AAPL","GOOG","NVDA") %>%
  tq_get(from = "2019-01-01", to = "2020-08-31")

#### Calculate returns and make a table ####
stock_returns_tbl = stock_data_tbl %>%
  select(symbol, date, adjusted) %>%
  group_by(symbol) %>%
  summarise(week = last(adjusted) / first(tail(adjusted,7)) -1,
    month = last(adjusted) / first(tail(adjusted,30)) -1,
    quarter = last(adjusted) / first(tail(adjusted, 90)) -1,
    year = last(adjusted) / first (tail(adjusted, 365)) -1,
    all = last (adjusted) / first(adjusted) - 1 )

stock_returns_tbl

#### Plot the returns ####
stock_plot = stock_data_tbl %>%
  group_by(symbol) %>%
  summarize_by_time(adjusted=AVERAGE(adjusted), .by="week") %>%
  plot_time_series(date, adjusted, .facet_ncol=2, .interactive=FALSE)

stock_plot

#### Create the PowerPoint slide ####
doc = read_pptx()
doc = add_slide(doc)
doc = ph_with(doc, value="Stock Report", location=ph_location_type(type="title"))
doc = ph_with(doc, value=stock_returns_tbl, location=ph_location_left())
doc = ph_with(doc, value=stock_plot, location=ph_location_right())

print(doc, target="stock_report.pptx")
