# add libraries to shiny app
if(!require("pacman")){install.packages("pacman")}

pacman::p_load("dplyr",
               "DT",
               "ggplot2",
               "leaflet",
               "lubridate",
               "RColorBrewer",
               "sf",
               "shiny",
               "shinycssloaders",
               "shinyjs",
               "shinyWidgets")



# Pre-processing
## Load functions -----------------------------------------------------------
source("./R/shiny_common_functions.R")

# load data
load("./data/bigfoot_county_date_aggregations.rda")
load("./data/bigfoot_points.rda")
load("./data/season_columns.rda")
load("./data/statewide_date_aggregations.rda")
load("./data/wa_counties.rda")
load("./data/Bigfoot_county_aggregations.rda")



### set default Shiny port----------------------------------------------------
options(shiny.port = 6599)


# This creates a sequence of dates from the earliest sighting to the last sighting
# the sequence is every year, we use it for factor levels


sightings_date_range <- seq.Date(from = min(bigfoot_points$year_as_date),
                                 to = max(bigfoot_points$year_as_date),
                                 by = "years")




### Make missing values  for under chart labels---------------------------
# see shiny_common_functions.R for details

report_missing <- make_missing_values_labels("classification", df = bigfoot_points)
weekday_missing <- make_missing_values_labels("report_weekday", df = bigfoot_points)
season_missing <- make_missing_values_labels("season", df = bigfoot_points)




### aesthetic specifications for cloropleth------------------------------------------------

# this is an easter egg for someone to find!
# probably won't make it to the final draft QQ

BigFootIcon <- makeIcon(
  iconUrl = "https://images.fineartamerica.com/images/artworkimages/medium/3/gluten-free-cute-bigfoot-cartoon-noirty-designs-transparent.png",
  iconWidth = 38 ,
  iconAnchorX = 22,
  iconAnchorY = 24
)




### County Cloropleth labels ---------------------------------------------------

# these are the popup labels for the map
# it creates a vector of text strings
# that we then lapply into html
# it defines the labels in html


map_labels <- paste0("<strong>County: </strong>",  # <strong> create bold text
                     wa_counties$JURISDICT_LABEL_NM,
                     "<br>",                      # br creates a line break
                     "<strong>Total Number of Bigfoot Sightings: </strong>",
                     wa_counties$sightings_count,
                     "<br>",
                     "<strong>Percent of Total sightings: </strong>",
                     round(wa_counties$percent_of_total, digits = 2),
                     "<br>",
                     "<br>",
                     "Counts that are below 10 are suppressed for<br> the Bigfeets privacy and represented with an '*'") %>%
  # there's a pipe to the right of the line above
  # we use lapply, because we're creating a separate HTML string for each row in the shape file
  lapply(htmltools::HTML)



# this creates the breaks for the color scheme we use to represent Sightings count on the cloropleth
# They are the same bins as the PowerBI map
bins <- c(0, 1, 5, 20, 35, 50, 65, Inf)

# This assigns colors to the breaks
# There's one fewer color than bin, because the bins vector defines
# the start and end point of each range

pal <- colorBin(c("#E6E6E6", "#C5E2FE", "#6EA6D9",
                  "#3D88CC", "#0A508F", "#073560", "#062E53"),
                #                # This must be how the function maps variable values
                #                # to the color ranges:
                domain = wa_counties$sightings_count,
                bins = bins)

# the color pallete
large_pal <- c("#e60049", "#0bb4ff", "#50e991",
               "#e6d800", "#9b19f5", "#ffa300",
               "#dc0ab4", "#b3d4ff", "#00bfa0")


# map legend labels
legend_labels <-  c("Zero", "> 0 - 5", "> 5 - 20",
                    "> 20 - 35", "> 35 - 50" ,
                    "> 50 - 65","  65+")





### Point map labels -----------------------------------------------------------
# This defines the popup for the point map

popup <- paste0(
  "<p id='popup-title'><strong>", bigfoot_points$summary, "</strong></p>",
  "<div id='first-popbox'>",
  "<strong>Report Date: </strong>", format(as.Date(bigfoot_points$report_date2), "%B %d, %Y"),
  "<br><strong>Report Classification: </strong>", bigfoot_points$classification,
  "<br><strong>Length of Report: </strong>", bigfoot_points$report_length, " characters",
  "<br><strong>Report Season: </strong>", bigfoot_points$season,
  "<br><br><strong>County: </strong>", bigfoot_points$county,
  "<br><strong>Nearest Town: </strong>", bigfoot_points$nearest_town,
  "<br><strong>Environment: </strong>", bigfoot_points$environment,
  "</div>",
  "<div id='second-popbox'>",
  "<p id='popbox-report-text'><strong>Report text</strong></p><br>",
  substr(bigfoot_points$observed, 1, 400),"... ",
  "<br><a href='",bigfoot_points$url, "'>click to see full report</a></div>"
) %>%
  lapply(htmltools::HTML)




### ggplot standard theme ----------------------------------------------------
# Define a standard theme for all the ggplot charts in the shiny

ggplot_standard_theme <- theme(axis.line.y = element_blank(),
                               panel.background = element_blank(),
                               panel.grid.major = element_blank(),
                               panel.grid.minor = element_blank(),
                               axis.title.x = element_text(size = 20),
                               title = element_text(size = 20))





ui <- fluidPage(
  
  # include CSS
  tags$link(rel = "stylesheet", type = "text/css", href = "css/styles.css"),
  
  
  #titlePanel("Upload a gpx file to get started!"),
  page1("page1"),
  activity_header_UI("activity_header"),
  summary_map_UI("summary_map"),
  stats_table_UI("stats_table"),
  elevation_plot_UI("elevation_plot"),
  aknowledgements_UI("aknowledgements")
  
  
)