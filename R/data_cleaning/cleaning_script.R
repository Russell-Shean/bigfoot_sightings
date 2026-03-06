#################################################################################3
# This script cleans and aggregates the data scraped from the bigfoot field 
# researchers organization's website. It should only be run if the data has 
# been re-scraped. The scrapping scripts are in the python folder. 

# Last updated: 12/23/2023
###############################################################################




# Install and load packages -----------------------------------------------------------------
if(!require("pacman")){install.packages("pacman")}

pacman::p_load(dplyr,
               jsonlite,
               lubridate,
               lwgeom,
               magrittr,
               sf,
               stringr,
               tidyr)



## Define paths to data-----------------------------------------------

# link to a shape file of washington state counties
counties_shapefile_url <- "https://gis.dnr.wa.gov/site3/rest/services/Public_Boundaries/WADNR_PUBLIC_Cadastre_OpenData/FeatureServer/11/query?outFields=*&where=1%3D1&f=geojson"
all_sightings_path <- "./data/raw_data/all_sightings.json"

# Load data  -------------------------------------------------------------------------------------------------- 

# counties shapefile
wa_counties <- sf::st_read(counties_shapefile_url)


json_data <- jsonlite::fromJSON(all_sightings_path)


# Process all sightings data ----------------------------------------------------------------

# convert from json to dataframe
bigfoot_df <- dplyr::bind_rows(json_data[1:length(json_data)])


# change individual variables
bigfoot_df <- bigfoot_df |>
  
              # force column names to lowercase
              dplyr::rename_with(function(x)tolower(stringr::str_replace_all(x," ","_"))) |>
  
              # find the total length of the interesting bits
              dplyr::mutate(report_length = nchar(
                paste0(observed, location_details, nearest_town, 
                                         nearest_road, also_noticed, other_witnesses, 
                                         other_stories, time_and_conditions, environment)),
                     
                     # extract first set of numbers (any length) 
                     # we'll assume that this is the year....
                     year = stringr::str_extract(year, "\\d+")) |>
  
  
  dplyr::mutate(  # if the number of characters are two
           # check to see if the two numbers are less than 
           # the last two numbers of todays year (so for this year 23)
           # if they are more than 23 paste 19 to the front
           # otherwise paste 20
           year = ifelse( nchar(year) != 2,
                          year,
                          ifelse(
                            as.numeric(year) <= as.numeric(substr(Sys.Date(), 3, 4)),
                            paste0("20", year), 
                            paste0("19", year))),
          
           
           # generalize all years as january 1st, [year]
           year_as_date = as.Date(paste0(year, "-01-01")),
           
           
           # extract the date part of the report date field
           report_date = stringr::str_extract(report_date, "(?<= on ).*"),
           report_date2 = as.Date(lubridate::parse_date_time(report_date, "Bdy")),
           
           # find the day of the week the report was made
           report_weekday = weekdays(report_date2),
           
           
           
           # convert variables into factors
           classification =  factor(classification),
           
           report_weekday = factor(report_weekday,
                                               levels = c("Monday",
                                                          "Tuesday",
                                                          "Wednesday",
                                                          "Thursday",
                                                          "Friday",
                                                          "Saturday",
                                                          "Sunday")),
           
           
           season = factor(season, 
                                       levels = c("Spring",
                                                  "Summer",
                                                  "Fall",
                                                  "Winter", 
                                                  "Unknown"))
           
           
           
           ) 
  

## Convert Washington State sightings to a sf dataframe--------------------------------------------------

# filter for washington state
WA_bigfoot_df <- bigfoot_df |>
                 dplyr::filter(state == "Washington")


# find the number of sightings for each county
# this returns only counties that actually have sightings
counties_with_bigfoots <- WA_bigfoot_df %>%
  dplyr::group_by(county) %>%
  dplyr::count()


  



#### Assign a random point within the county to each sighting ---------------------------------------------------------------------
  # This randomly samples from the county's shape file
  # once for each sightings and returns a random point within the subboundary
  # This is a way of randomly assigning locations to each sighting
  
  
  
  # Join geometry first
WA_joined <- WA_bigfoot_df %>%
  left_join(
    wa_counties %>% select(JURISDICT_NM, geometry),
    by = c("county" = "JURISDICT_NM")
  ) %>%
  sf::st_as_sf()

# Sample one point per geometry using lengths trick
bigfoot_points <- sf::st_sample(
  WA_joined$geometry,
  size = rep(1, nrow(WA_joined))
) %>%
  sf::st_as_sf() %>%
  cbind(WA_bigfoot_df)


### aggregate sightings by just county-------------------------------------------------

Bigfoot_county_aggregations <- WA_bigfoot_df %>%
  dplyr::count(county) %>%
  dplyr::mutate(percent_of_total = round(n / nrow(WA_bigfoot_df) * 100, digits = 1)) %>%
  dplyr::rename(sightings_count = n)

### aggregate sightings by just date -----------------------------------------------

statewide_date_aggregations <- WA_bigfoot_df %>%
  dplyr::count(year_as_date) %>%
  dplyr::mutate(percent_of_total = round(n / nrow(WA_bigfoot_df) * 100, digits = 1)) %>%
  dplyr::rename(sightings_count = n)

### aggregate by county AND date --------------------------------------------------

bigfoot_county_date_aggregations <- WA_bigfoot_df %>%
  dplyr::group_by(county, year_as_date, .drop = FALSE) %>%
  dplyr::summarise(sightings_count = dplyr::n())


# This creates a sequence of dates from the earliest sigthing to the last sighting
# the sequence is every year, we use it for factor levels


sightings_date_range <- seq.Date(from = min(WA_bigfoot_df$year_as_date),
                                 to = max(WA_bigfoot_df$year_as_date),
                                 by = "years") 




bigfoot_county_date_aggregations <- WA_bigfoot_df %>%
    dplyr::group_by(county, year_as_date, .drop = FALSE) %>%
  dplyr::summarise(sightings_count = dplyr::n())







### Find date range of sightings ----------------------------------------------



# This is a data frame of every date+ county combination possible in the data
# We need this because we need to fill in combos that aren't in the data
# so we can make the sightings count zero instead of just not having that combo
# in the data.

county_date_combos <- data.frame(
  county = rep(
    #  repeat each county for all dates
    unique(bigfoot_county_date_aggregations$county),
    each = length(sightings_date_range)),
  
  # repeat each date for all counties
  year_as_date = rep(sightings_date_range,
                     times = length(unique(bigfoot_county_date_aggregations$county))))


### add all possible date + county combos to data ----------------------------------



# Here we merge the date+county combos dataframe
# onto the county + date  aggregated data set
# to make sure  that every county + date combination with no sightings
# has 0 in the data instead of just not being in the data

bigfoot_county_date_aggregations <- bigfoot_county_date_aggregations %>%
  dplyr::right_join(county_date_combos) %>%
  replace(is.na(.), 0) 

### Prepare season by report classification table ------------------------------
# make a cross table from the starting data set using the variables SEASON

# and report classification
season_columns <- WA_bigfoot_df %>%
  dplyr::group_by(classification, season, .drop = FALSE) %>%
  dplyr::summarise(n = dplyr::n()) %>%
  tidyr::pivot_wider(names_from = classification,
              values_from = n)


### shape file------------------------------------------------------------------
# This binds the county aggregations onto the shape file
# we need this for the map

wa_counties <- wa_counties %>% 
  
  # JURISDICT_NM is the county name in the shape file
  dplyr::left_join(Bigfoot_county_aggregations, 
            by = c( "JURISDICT_NM" = "county" )) %>% 
  
  # This replaces na's with zeros because I'm assuming that in this context
  # any combination of date and county that is blank, is blank because there 
  # weren't any sightings in that county on that date.
  replace(is.na(.), 0)  


# Save final data --------------------------------------------------------------
save(bigfoot_county_date_aggregations, file = "./data/bigfoot_county_date_aggregations.rda")
save( bigfoot_points, file = "./data/bigfoot_points.rda")
save( season_columns, file = "./data/season_columns.rda")
save(statewide_date_aggregations, file = "./data/statewide_date_aggregations.rda")
save(wa_counties, file = "./data/wa_counties.rda")
save(Bigfoot_county_aggregations, file = "./data/Bigfoot_county_aggregations.rda")

