

## Load libraries -------------------------------------------------------------
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

## define file paths

# path to where we store user feedback that they submit to us
# using the contact form
#user_feedback_path <- "C:/R_projects/russ_stuff/demo_shiny2/data/"
#user_feedback_file <- paste0(user_feedback_path,"bigfoot_dashboard_public_feedback.csv" )



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



#🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄
#🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄🐄
#



# Section 2: User interface (UI)-----------------------------------------------
#
# This defines the User interface (UI)
# This is what defines the look of the webpage, it defines inputs, things to display
# etc and where they appear on the page
# raw HTML and CSS can be integrated into the user interface to customize the look of the webpage
# beyond the defaults that Shiny has implemented


#🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒
#🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒🦒

# Navbarpage defines a page with multiple tabs
ui <- navbarPage(
  "BIGFOOT SIGHTINGS IN WASHINGTON STATE DASHBOARD",
  
  # This is the title of the overall webpage:
  #"Bigfoot Sightings in Washington State",
  
  
  # This enables the shinyjs library inside the app
  # I used this for the email server
  useShinyjs(),
  
  
  
  
  ## CSS style tags---------------------------------------------------------------
  # here are a bunch of Cascading Style Sheets (CSS) style for different elements
  
  # Here's how to load an external css style sheet
  # it needs to be stored in a sub-directory named www/
  # https://shiny.rstudio.com/articles/css.html
  
  # /* CSS comments look like this */
  
  tags$link(rel = "stylesheet", type = "text/css", href = "css/bigfoot_dashboard_styles.css"),
  
  ## Javascript scripts ----------------------------------------------------------
  
  # Create Right Side Logo/Image with Link
  # this defines a javascript code chunk
  # to add a image to the
  # right side of the navigation bar
  # // Javascript comments look like this or like CSS comments
  # tags$script(src="/JavaScript/add_header_image.js"),
  # tags$script(src="/JavaScript/remove_dots.js"),
  
  
  ## First page-------------------------------------------------------------------
  
  # tabpanel defines an individual tab within the larger page
  tabPanel(
    
    # This is the title that's displayed on tab:
    "Summary",
    
    tags$div(class = "below-header",
             # This defines the first tab's page
             fluidPage(id = "page-one",
                       
                       
                       
                       # this defines a row
                       fluidRow(id="surveillance-notes-box",
                                
                                
                                
                                
                                ### First page intro text -------------------------------------------------------
                                
                                # this defines a block of text within in a "code" html element
                                tags$div(class="intro-text",
                                         "Bigfoot surveillance data are updated on the second tuesday after every full moon in February, or when we feel like it 😅. We make every effort to guarentee the accuracy of all the data that is entered into our data systems, but because we rely on the public to report sightings, we can't guarantee that every reported sighting wasn't actually a yeti or an abominable snowman. To report a sighting please send us an email!",
                                         tags$br(),
                                         tags$p(class="time-stamp",
                                                tags$strong("Last Updated: March 6th, 2024 10:00 AM")))
                                
                       ),
                       # end of first row
                       
                       tags$div(id="dashboard-content-page-one",
                                
                                # third row
                                
                                fluidRow(
                                  
                                  # this is the column where the map/table goes
                                  # giving columns and rows their own html id helps a ton later
                                  # when targeting css styles
                                  
                                  
                                  column(
                                    
                                    id = "map-column",
                                    
                                    # this is the width of the fluid column
                                    # width = 5/12 of the page's width
                                    width = 5,
                                    tags$span(class="graphic-title",
                                              "Sightings by County"),
                                    
                                    tags$div(id="map-well",
                                             class="background-panel",
                                             
                                             
                                             
                                             
                                             
                                             ### First page map/table radio buttons---------------------------------------
                                             
                                             # this creates a background well element to put the radio buttons inside
                                             wellPanel(id= "radio-button-well",
                                                       
                                                       # This creates a set of radiobuttons
                                                       radioButtons(
                                                         # this is the html id attribute
                                                         inputId = "map_or_table_button",
                                                         # this is a title for the button
                                                         label = NULL,
                                                         choices = c("Map View", "Table View"),
                                                         selected = "Map View",
                                                         # this makes the button horizontal
                                                         inline = TRUE)
                                             ),
                                             
                                             # This defines part of the UI in raw HTML
                                             
                                             tags$html(
                                               HTML("<span class='user-notes'>
                                   <strong>Hover</strong>
                                   over a county to see more info
                                </span>"))
                                    ),
                                    
                                    
                                    
                                    
                                    ### First page map/table------------------------------------------------------
                                    
                                    # A conditional panel is an html element that only appears if
                                    # a condition is met, in this case the user choosing to view
                                    # the map or the table with the radio buttons
                                    tags$div(id = "map_or_table_column",
                                             
                                             # if the user selects the table:
                                             county_sightings_table_UI("county_sightings_table"),
                                             
                                             # If the user selects the map:
                                             county_sightings_map_UI("county_sightings_map")

                                    ),
                                    
                                    
                                    
                                    
                                    ### First page map/table missing values text ---------------------------------
                                    
                                    missing_counties_note_UI("missing_counties_note")
                                    
                                    
                                    
                                  ),
                                  
                                  # the is the column that the sightings by year curve chart will go inside
                                  column(id= "sightings-column",
                                         width = 7,
                                         
                                         
                                         
                                         tags$span(class = "graphic-title",
                                                   "Sightings by Year"),
                                         
                                         
                                         tags$div(id = "epi-well",
                                                  class = "background-panel",
                                                  
                                                  
                                                  
                                                  
                                                  ### sightings by year curve choices ------------------------------------------------------
                                                  
                                                  selectInput(inputId = "county_choices",
                                                              label = "Select a County",
                                                              choices = c("Statewide",
                                                                          sort(wa_counties$JURISDICT_NM)),
                                                              selected = "Statewide"),
                                                  
                                                  
                                                  tags$html(
                                                    HTML("<span class='user-notes'>
                            <strong>Select</strong>
                          a county to see sightings per week for that county
                             <br>
                            <strong>Hover</strong>
                          over a bar to see more info for that week
                            </span>"))
                                                  
                                         ),
                                         
                                         
                                         
                                         
                                         ### sightings by year curve -----------------------------------------------------------
                                         sighting_counts_plot_UI("sighting_counts_plot"),
                                         
                                         
                                         
                                         
                                         ### sightings by year curve date slider--------------------------------------------------
                                         
                                         tags$span(id = "slider-container",
                                                   tags$span(id = "date-slider2",
                                                             sliderInput("startdate",
                                                                         
                                                                         # I set the maximum range, to the range of dates in the data
                                                                         min = min(bigfoot_points$year_as_date, na.rm = TRUE),
                                                                         
                                                                         max = max(bigfoot_points$year_as_date, na.rm = TRUE),
                                                                         
                                                                         # this makes the slider take up 100% of the column
                                                                         width = '100%',
                                                                         
                                                                         # Remove axis ticks
                                                                         ticks = FALSE,
                                                                         
                                                                         # this sets the starting date range as the min and max of the slider
                                                                         value = c(min(min = min(bigfoot_points$year_as_date,
                                                                                                 na.rm = TRUE)),
                                                                                   max(max = max(bigfoot_points$year_as_date,
                                                                                                 na.rm = TRUE))),
                                                                         
                                                                         # this is so the slider doesn't have a title above it
                                                                         label = NULL))),
                                         
                                         # This tells shiny to output to the uI information collected from
                                         # mouse hovers, How that information is actually displayed is
                                         # is defined below in the server
                                         sighting_counts_plot_toolTip_UI("sighting_counts_plot_toolTip")
                                         
                                         )),
                                
                                
                       )
                       
             )  # end of fluidpage
             
    )   # end of div
    
    
    
    
    
    
    
  ),   # end of first tab
  
  
  
  ## Second page -----------------------------------------------------------------
  tabPanel("Report Details",
           fluidPage(id = "page-two",
                     
                     # this defines the text ribbon at the top of the second page:
                     # html class is the same as first page's text ribbon
                     
                     # first row
                     
                     
                     
                     
                     ### Second page intro text --------------------------------------------------
                     
                     fluidRow(
                       tags$div(class = "intro-text",
                                HTML("The Bigfoot Field Researchers Organization assigns reports to one of three categories. For more information on the report classification system, please refer to their <a href='https://www.bfro.net/gdb/classify.asp#classification'>website</a>.<p id='classification-descriptions'><strong>Class A</strong>: A direct report where alternative explanations can be eliminated with high certainty<br><strong>Class B</strong>: A direct report where alternative explanations are more difficult to eliminate<br><strong>Class C</strong>: A secondhand report of a sighting.</p>"),
                                # tags$p(class = "time-stamp",
                                # tags$strong("Last Updated: December 23, 2023 10:00 AM"))
                                
                       )),
                     
                     tags$div(id = "three-plots-container",
                              
                              # second row
                              fluidRow(id = "second-page-second-row",
                                       
                                       
                                       
                                       
                                       
                                       ### report classification chart -----------------------------------
                                       
                                       column(id = "report_class_plot_column",
                                              class = "second-page-column",
                                              width = 4,
                                              
                                              tags$span(class = "graphic-title",
                                                        "Sightings by Report Classification"),
                                              
                                              report_class_plot_UI("report_class_plot"),
                                              
                                              # This is the text under the chart that tells us
                                              # how many values are missing
                                              
                                              tags$span(class = "missing-text",
                                                        width = 4,
                                                        textOutput(outputId = "report_missing")),
                                              
                                              # tells shiny that information from the user's mouse hoverings
                                              # will be returned to the user
                                              # which types of info and how they're displayed defined in server
                                              report_class_plot_toolTip_UI("report_class_plot_toolTip")),
                                       
                                       
                                       
                                       
                                       ### Sightings vs classification table ------------------------------------
                                       
                                       column(id = "season_table_column",
                                              class = "second-page-column",
                                              width = 4,
                                              
                                              tags$span(class = "graphic-title",
                                                        "Sightings by Season and Report Classification"),
                                              
                                              # this uses R's wrapper to the data.table package in javascript
                                              # a lot of the appearance is defined in the server using the wrapper
                                              season_table_UI("season_table"),
                                              
                                              tags$span( class = "missing-text",
                                                         width = 4,
                                                         
                                                         textOutput(outputId =  "time_missing"))),
                                       
                                       
                                       
                                       ### Sightings by day of the week chart ------------------------------------
                                       
                                       column(id = "weekday_plot_column",
                                              class = "second-page-column",
                                              width = 4,
                                              
                                              tags$span(class = "graphic-title",
                                                        "Total Number of Sightings by Day of the Week"),
                                              
                                              weekday_plot_UI("weekday_plot"),
                                              
                                              tags$span(class = "missing-text",
                                                        width = 4,
                                                        textOutput(outputId = "weekday_missing")),
                                              
                                              #info to be return about user's mouse hoverings
                                              weekday_plot_toolTip_UI("weekday_plot_toolTip")))
                              
                              
                     ),
                     
                     
                     
           )
  ),
  
  
  
  ## Third page: Point map -----------------------------------------------------------------
  
  tabPanel("Sightings Map",
           
           
           fluidPage(id = "page-3",
                     
                     
                     
                     ### Third page chart selectors ----------------------------------------------
                     
                     fluidRow(
                       column(width = 12,
                              id = "choice_selector",tags$html(
                                HTML("<span
                      id='point-map-notes'
                      class='user-notes'
                      style='float:right;'>

                         <strong>Click</strong>
                           on a sighting for more info
                         <br>

                         <strong>Choose</strong>
                   which variables you want to represent dot size and color
                         <br>

                         <strong>Select</strong>
          how you want to filter the sightings (at least one per subcategory!)
                         <br>

                         <strong>Have fun!!!</strong></span>")))),
                     
                     fluidRow(
                       column(id= "map-dropdowns",
                              2,
                              
                              tags$span(class = "map_choice-container",
                                        selectizeInput("size_var", "Select a Size Variable",
                                                       choices = c("Length of the Report",
                                                                   "None"),
                                                       selected ="None")),
                              
                              
                              
                              #### Color variable choices --------------------------------------------------
                              
                              tags$span(class = "map_choice-container",
                                        selectizeInput("color_var", "Select a Color Variable",
                                                       choices = c("Report Classification",
                                                                   "Season",
                                                                   "Day of the Week",
                                                                   "None"),
                                                       selected = "None")),
                              
                              
                              
                              filtering_criteria_UI("filtering_criteria")
                            
                       ),
                       bigfoots_maps_UI("bigfoots_maps")
                       
                       
                       
                       ))),
  
  
  
  ## Fourth page -----------------------------------------------------------------
  
  # This page is entirely text and links (ie standard html sort of things
  # without any r objects), for simplicity of css formating, the section is
  # written entirely in html using Html tags created by r
  # It is stored in the app's www/ directory
  
  tabPanel("Data Notes",
           
           # <!-- HTML comments look like this -->
           includeHTML("www/html/page4.html")
           
  ),
  
  
  
  ## Website footer -------------------------------------------------------------
  
  footer = includeHTML("www/html/site_footer.html"),
  
  # these scripts are run at the end
  # bc they need to run AFTER the page has finished rendered
  # one script removes weird random dots that appear
  # and the other moves the locaiton of the time stamp
  
  tags$script(src="move_remove_functions.js"),
  #tags$script(src="/JavaScript/remove_dots.js")
  #tags$script(src="/JavaScript/remove_dot5.js")
  
  
)



