# ======================================================================= 

# Description: This shiny dashboard contains data about REAL Bigfoot sightings. 
#              We're using this project to test out the technology and didn't 
#              want to use a real health condition while we're testing.  ~end~ 

# Authors: Russ (Dashboard team)  ~end~ 

# ======================================================================= 


# 
#🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖
#🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖🦖
#



# Notes about how this shiny is organized:--------------------------------------
# 
#  Shinies have two basic parts that have to be defined separately: 
#  A user interface (ui) and a server, this somewhat restricts where in the script
#  some code has to be run. 
# 
# Therefore the code will have the following sections:
#
#     1. Pre-processing 
#            ( this is where libraries, data and functions are loaded
#                + some pre-processing of the data )
#
#     2. User interface (ui)
#            ( this is where the webpage that the user sees is defined )
#            ( The first section loads external CSS and javascript files )
#            ( Next, each page of the shiny is defined using R code)
#            ( The R code generates HTML, using shiny methods + tags$  )
#            ( to see the page in HTML call the UI object )
#            ( The footer is written entire in HTML and loads from an external file )
#            ( 😱 )

#    3. Server
#            ( this is where re-activity is defined and implemented)
#            ( because a lot of the data processing decisions change with user)
#            ( input, a lot of the data processing steps are run in the server)
#            ( instead of in the pre-processing section )
#            ( this is also where graphs and tables are defined.)
#            ( Within the server, the re-activity for each html element has to )
#            ( defined separately within a reactive variable)
#            ( I will try to work on defining things outside the reactive variables)
#            ( and instead call an intermediate variable from within the reactive variable)
#            ( I'm not sure that last sentence made sense lol)
#            ( within the server, reactive variables can be defined in any order,)
#            ( so I will define them in the same order as the UI)
#
# 
#  Within each section I try to arrange things in the order recommended by the style guide
#
#
#🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙
#🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙🦙
#



# Section 1: Pre-processing!---------------------------------------------------
#



## Load libraries -------------------------------------------------------------      

pacman::p_load(#"blastula",
               #"data.table",
               "dplyr",
               "DT",
               #"forcats",
               "ggplot2",
               #"ggrepel",
               #"keyring",
               "leaflet",
               "lubridate",
               #"lwgeom",
               #"mapview",
               "RColorBrewer",
              #"readr",
               "sf",
               "shiny",
               "shinycssloaders",
               "shinyjs",
            #   "shinythemes",
            #   "stringr",
            #   "tidyr",
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
load("./data/wa_counties2.rda")
load("./data/Bigfoot_county_aggregations.rda")


## Magic Numbers ------------------------------------------------------------------------------------------- 

### discover VPN's IP address--------------------------------------------------
# This function returns the VPN's IP address
# we need to do this every time because the vpn's
# ip address changes every time we reconnect to it. 

# VPN_ip_address <- get_VPN_ip()



### set default Shiny port----------------------------------------------------
# Paths to outputs 
options(shiny.port = 6599)
#options(shiny.host = VPN_ip_address)


# This creates a sequence of dates from the earliest sigthing to the last sighting
# the sequence is every year, we use it for factor levels


sightings_date_range <- seq.Date(from = min(bigfoot_points$year_as_date),
                                 to = max(bigfoot_points$year_as_date),
                                 by = "years") # %>% # as.character()





### Make missing values  for under chart labels---------------------------
# see shiny_common_functions.R for details 

report_missing <- make_missing_values_labels("report_clasification", df = bigfoot_points)
weekday_missing <- make_missing_values_labels("report_weekday", df = bigfoot_points)
season_missing <- make_missing_values_labels("SEASON", df = bigfoot_points)




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
# it creats a vector of text strings
# that we then lapply into html
# it defines the labels in html


map_labels <- paste0("<strong>County: </strong>",  # <strong> create bold text
                     wa_counties2$JURISDICT_LABEL_NM,  
                     "<br>",                      # br creates a line break                                  
                     "<strong>Total Number of Bigfoot Sightings: </strong>",
                     wa_counties2$sightings_count,
                     "<br>",
                     "<strong>Percent of Total sightings: </strong>",
                     round(wa_counties2$percent_of_total,digits = 2),
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
# same colors as PowerBI
# There's one fewer color than bin, because the bins vector defines
# the start and end point of each range

pal <- colorBin(c("#E6E6E6", "#C5E2FE", "#6EA6D9", 
                  "#3D88CC", "#0A508F", "#073560", "#062E53"), 
                #                # This must be how the function maps variable values 
                #                # to the color ranges:
                domain = wa_counties2$sightings_count,     
                bins = bins)

# the color pallete 
large_pal <- c("#e60049", "#0bb4ff", "#50e991",
               "#e6d800", "#9b19f5", "#ffa300",
               "#dc0ab4", "#b3d4ff", "#00bfa0") #%>% 
 # str_to_upper()


# map legend labels
legend_labels <-  c("Zero", "> 0 - 5", "> 5 - 20", 
                    "> 20 - 35", "> 35 - 50" ,
                    "> 50 - 65","  65+")





### Point map labels -----------------------------------------------------------
# This defines the popup for the point map

popup <- paste0(
  "<p id='popup-title'><strong>", bigfoot_points$subtitle, "</strong></p>",
  "<div id='first-popbox'>",
  "<strong>Report Date: </strong>", format(as.Date(bigfoot_points$report_date2), "%B %d, %Y"),
  "<br><strong>Report Classification: </strong>", bigfoot_points$report_clasification,
  "<br><strong>Length of Report: </strong>", bigfoot_points$report_length, " characters",
  "<br><strong>Report Season: </strong>", bigfoot_points$SEASON,
  "<br><br><strong>County: </strong>", bigfoot_points$COUNTY,
  "<br><strong>Nearest Town: </strong>", bigfoot_points$NEAREST_TOWN,
  "<br><strong>Environment: </strong>", bigfoot_points$ENVIRONMENT,
  "</div>",
  "<div id='second-popbox'>",
  "<p id='popbox-report-text'><strong>Report text</strong></p><br>", 
  substr(bigfoot_points$OBSERVED, 1, 400),"... ",
  "<br><a href='",bigfoot_points$report_links, "'>click to see full report</a></div>"
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
ui <- navbarPage( # This is the title of the overall webpage:
  "Bigfoot Sightings in Washington State",   
  
  
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
  tags$script(src="/JavaScript/add_header_image.js"),
  

  
  
  
  ## First page------------------------------------------------------------------- 
  
  # tabpanel defines an individual tab within the larger page
  tabPanel(
    
    # This is the title that's displayed on tab:    
    "Summary",    
    
    tags$div(class = "below-header",
      # This defines the first tab's page
      fluidPage(id = "page-one",
                

                       
            # this defines a row
        fluidRow(
          
          
          
                         
  ### First page intro text -------------------------------------------------------
  
          # this defines a block of text within in a "code" html element
          tags$div(class="intro-text",
          "Bigfoot surveillance data are updated on the second tuesday after every full moon in February, or when we feel like it 😅. We make every effort to guarentee the accuracy of all the data that is entered into our data systems, but because we rely on the public to report sightings, we can't guarantee that every reported sighting wasn't actually a yeti or an abominable snowman. To report a sighting please send us an email!",
          tags$br(),
          tags$p(class="time-stamp", 
                 tags$strong("Last Updated: March 8th, 2023 10:00 AM")))
                         
                       ),  # end of first row
                       
     tags$div(id="dashboard-content-page-one",
 
                                # third row
                                
            fluidRow(
                                  
            # this is the column where the map/table goes
            # giving columns and rows their own html id helps a ton later
            # when targeting css styles
          

              column(
                                    
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
                           HTML("<span>
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
                     conditionalPanel(
                        condition = "input.map_or_table_button == 'Table View'",
                                           
            # this uses R's wrapper to the data.table package in javascript
            # a lot of the appearance is defined in the server using the wrapper
                        DTOutput("county_sightings_table")
                                      ),
                                         
                     # If the user selects the map:
                     conditionalPanel(
                        condition = "input.map_or_table_button == 'Map View'",
                        leafletOutput("county_sightings_map"), 
                                           
                                      )
                          ),
  
  
  
  
  ### First page map/table missing values text ---------------------------------
                                         
                 tags$span(class = "missing-text",
                 textOutput("missing_counties_note"))
                                         
                                         
                                         
                                  ),
                                  
              # the is the column that the epi curve chart will go inside
              column(width = 7, 
                     

                                         
                 tags$span(class = "graphic-title",
                 "Sightings by Year"),
                                         
                                         
                 tags$div(id = "epi-well",
                          class = "background-panel",
          
                          
                          
                                                                  
    ### Epi curve choices ------------------------------------------------------              
                                                  
                   selectInput(inputId = "county_choices",
                               label = "Select a County",
                               choices = c("Statewide", 
                                            sort(wa_counties2$JURISDICT_NM)),
                               selected = "Statewide"),


                   tags$html(
                     HTML("<span>
                            <strong>Select</strong> 
                          a county to see sightings per week for that county
                             <br>
                            <strong>Hover</strong> 
                          over a bar to see more info for that week
                            </span>"))
                                                  
                                         ),
    
    
    
    
    ### Epi curve -----------------------------------------------------------
                                         
                   tags$div(
                        id = "sighting_counts_plot_column",
                        # here's the epi curve chart
                        plotOutput("sighting_counts_plot",
                                                    
         # this tells shiny to listen to and store information
         # about where over the chart the user's mouse is hovering
        # this is how we tell the tool tip which column to display
                                                    # info for
                                    hover = hoverOpts("plot_hover", 
                                                                      
                                    # this (I think) puts a delay on how often
                                    # hover info is recorded and sent to 
                                    # the server 
                                   delay = 100, 
                                   delayType = "debounce"))),
    
    
    
    
    ### Epi curve date slider--------------------------------------------------
                                         
                        tags$span(id = "slider-container",
                          tags$span(id = "date-slider2",
                            sliderInput("startdate",
                                                               
                  # I set the maximum range, to the range of dates in the data
                              min = min(bigfoot_points$year_as_date, na.rm = TRUE),
                  # min = levels(bigfoot_points$year_as_date)[1],
                              max = max(bigfoot_points$year_as_date, na.rm = TRUE),
                  #max = levels(bigfoot_points$year_as_date)[length(levels(bigfoot_points$year_as_date))],                              
                            # this makes the slider take up 100% of the column
                              width = '100%',
                                                               
                              # Remove axis ticks
                              ticks = FALSE,
                                                               
            # this sets the starting date range as the min and max of the slider
                             value = c(min(min = min(bigfoot_points$year_as_date, 
                                                     na.rm = TRUE)),
                                     max(max = max(bigfoot_points$year_as_date, 
                                                     na.rm = TRUE))),
    # value = c(min = levels(bigfoot_points$year_as_date)[1],
    #        max = levels(bigfoot_points$year_as_date)[length(levels(bigfoot_points$year_as_date))]),
            
                                                               
                        # this is so the slider doesn't have a title above it
                              label = NULL))),
                                         
               # This tells shiny to output to the uI information collected from 
               # mouse hovers, How that information is actually displayed is 
               # is defined below in the server
                        uiOutput("sighting_counts_plot_toolTip"))),
                                
                             
                            )
                       
             )  # end of fluidpage
             
    )   # end of div
    
    
    
    
    
    
    
  ),   # end of first tab 
  
  
  
  ## Second page -----------------------------------------------------------------
  tabPanel("Bigfeets Characteristics",
    fluidPage(id = "page-two",
                     
                     # this defines the text ribbon at the top of the second page:
                     # html class is the same as first page's text ribbon
                     
                     # first row
        
              
              
                    
  ### Second page intro text --------------------------------------------------
  
      fluidRow(
        tags$div(class = "intro-text",
           HTML("The Bigfoot Field Researchers Organization assigns reports to one of three categories. For more information on the report classification system, please refer to their <a href='https://www.bfro.net/gdb/classify.asp#classification'>website</a>.<p id='classification-descriptions'><strong>Class A</strong>: A direct report where alternative explanations can be eliminated with high certainty<br><strong>Class B</strong>: A direct report where alternative explanations are more difficult to eliminate<br><strong>Class C</strong>: A secondhand report of a sighting.</p>"),
           tags$p(class = "time-stamp",
           tags$strong("Last Updated: March 8th, 2023 10:00 AM")))),
                       
        tags$div(id = "three-plots-container",
           
          # second row
          fluidRow(id = "second-page-second-row",
                   
        
                   
                   
                              
  ### report classification chart -----------------------------------
                                         
             column(id = "report_class_plot_column",
                    class = "second-page-column",
                     width = 4,
                    
                    tags$span(class = "graphic-title",
                    "Sightings by Report Classification"),
                    
                     plotOutput("report_class_plot",
                                                           
                     # records mouse hover data for Report Classification Bar Chart
                     hover = hoverOpts("report_class_plot_hover", 
                     delay = 100, 
                     delayType = "debounce")),
                                                
                    # This is the text under the chart that tells us
                    # how many values are missing
                    
                     tags$span(class = "missing-text",
                               width = 4,
                            textOutput(outputId = "report_missing")),
                                                
      # tells shiny that information from the user's mouse hoverings
      # will be returned to the user
      # which types of info and how they're displayed defined in server
                     uiOutput("report_class_plot_toolTip")),
                                         
      
  
  
      ### Sightings vs classification table ------------------------------------
  
             column(id = "season_table_column",
                    class = "second-page-column",
                    width = 4,
                    
                 tags$span(class = "graphic-title",
                          "Sightings by Season and Report Classification"),
                                                
              # this uses R's wrapper to the data.table package in javascript
              # a lot of the appearance is defined in the server using the wrapper
                 DT::dataTableOutput("season_table"),
                                                
                 tags$span( class = "missing-text",
                          width = 4,
                          
                     textOutput(outputId =  "time_missing"))),
          
  
                                 
  ### Sightings by day of the week chart ------------------------------------
  
              column(id = "weekday_plot_column",
              class = "second-page-column",
              width = 4,
              
                 tags$span(class = "graphic-title",
                           "Total Number of Sightings by Day of the Week"),
              
                 plotOutput("weekday_plot",
                                                           
                            # info about the user's mouse hoverings
                            hover = hoverOpts("plot_hover3", 
                            delay = 100, 
                            delayType = "debounce")),
                                                
                 tags$span(class = "missing-text",
                           width = 4,
                           textOutput(outputId = "weekday_missing")),
                                                
                 #info to be return about user's mouse hoverings
                 uiOutput("weekday_plot_toolTip")))
                                

                       ),
                       

                       
                       ) 
           ),
  
  
  
  ## Third page: Point map -----------------------------------------------------------------
  
  tabPanel("Sightings Point Map",
           
           
    fluidPage(id = "page-3",

       
                     
  ### Third page chart selectors ----------------------------------------------
  
      fluidRow(
         column(width = 12,
                id = "choice_selector",
         
                
                       
  #### Size variable choices --------------------------------------------------
                              
            tags$span(id = "size_choice-container",
               selectizeInput("size_var", "Select a Size Variable",
                              choices = c("Length of the Report",
                                          "None"),
                              selected ="None")), 
  
  
  
  #### Color variable choices --------------------------------------------------
                              
            tags$span(id = "color_choice-container",
               selectizeInput("color_var", "Select a Color Variable",
                              choices = c("Report Classification",
                                           "Season",
                                           "Day of the Week",
                                           "None"),
                              selected = "None")), 
  
  
  
  #### filtering variable choices --------------------------------------------------
            tags$span(id = "filter_choice-container",
                pickerInput(
                  inputId = "filtering_criteria",
                  label = "Choose Filtering Criteria", 
                  choices = list(
                    `Report Classification` = levels(bigfoot_points$report_clasification),
                    Season = levels(bigfoot_points$SEASON),
                    `Day of the week` = levels(bigfoot_points$report_weekday),
                    County = unique(bigfoot_points$COUNTY)),
                                          
                  selected = c(  levels(bigfoot_points$report_clasification),
                                 levels(bigfoot_points$SEASON),
                                 unique(bigfoot_points$COUNTY),
                                 levels(bigfoot_points$report_weekday)),
                                          
                   options = list(`selected-text-format`= "static",
                                  title = "Filters",
                                  `actions-box` = TRUE), 
                                          
                                  multiple = TRUE)),
            
            
  
    ### point map explanatory notes --------------------------------------------
            
            tags$html(
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
                         
                         <strong>Have fun!!!</strong>")))),
                     
      fluidRow(
        column(12,
           
               
                   
  ### point map --------------------------------------------------------------
                                     
          leafletOutput("bigfoots_maps", 
                        height = "700px") %>%
    
    
    
  ### loading page bigfoot gif---------------------------------------------------
            
          withSpinner(
            id = "loading-gif",
            image.height = "650px",
            # image source needs to be checked for copyright
             image = "https://raw.githubusercontent.com/Russell-Shean/bigfoot-dashboard-demo/main/www/resources/output-onlinegiftools3.gif"
                      )
                                    
                                     
                     )))),
  
  
  
  ## Fourth page -----------------------------------------------------------------
  
  # This page is entirely text and links (ie standard html sort of things
  # without any r objects), for simplicity of css formating, the section is 
  # written entirely in html using Html tags created by r
  # It is stored in the app's www/ directory
  
  tabPanel("Notes About Our Data",
           
           # <!-- HTML comments look like this -->
           includeHTML("www/html/page4.html")

        ),
  
  
  
  ## Fifth page -----------------------------------------------------------------
  
  tabPanel("Iframes!",
      fluidPage(id = "page-five",
  
                
                
 ### Fifth page intro text -----------------------------------------------------                        
        tags$div(
          tags$p(id = "shiny-page-intro",
                 class = "intro-text",
            HTML('This page shows an example of how iframes can be used to embed 
                 documents, PowerBI apps, even other shiny apps')
                                     ),
          
          
          
 ### iframe selection radio buttons -------------------------------------------
                              
        tags$div(
                                
          wellPanel(id = "radio-button-well2",
                                          
          # This creates a set of radiobuttons
            radioButtons(
              # this is the html id attribute
              inputId = "iframe_selection",   
              # this is a title for the button
              label = NULL,                      
              choices = c("Research Paper",
                           "Power BI App",
                           "A Different Shiny App"),  
              selected = "Research Paper", 
              # this makes the button horizontal
              inline = TRUE)                     
                                )
                                
                                
                                
                              )
                            ),
  
 
 
 ### First iframe ------------------------------------------------------------
 
         tags$div(id = "iframe_panel",

            # A conditional panel is an html element that only appears if 
            # a condition is met
                              
           # if the user selects the table:
            conditionalPanel(
               condition = "input.iframe_selection == 'Research Paper'",
                                

               HTML('<iframe 
                      id="research-pdf"
                      class="external-iframe" 
                      src="https://www.biorxiv.org/content/10.1101/2023.01.14.524058v2.full.pdf#toolbar=0&navpanes=0&scrollbar=0" 
                      title="Bigfoots or Black Bears">
                      </iframe>'),
                                
                              ),
  
           
           
  ### second iframe -----------------------------------------------------------                            

            conditionalPanel(
                condition = "input.iframe_selection == 'Power BI App'",
                HTML('<iframe 
                     id="powerBI-app" 
                     class="external-iframe" 
                     src="https://app.powerbigov.us/view?r=eyJrIjoiNDMyMTdkMTktNmE1My00MDMzLTk0ZDctNTcxMDU5NWI3MWVkIiwidCI6IjExZDBlMjE3LTI2NGUtNDAwYS04YmEwLTU3ZGNjMTI3ZDcyZCJ9" 
                     title="Washington State Covid Wastewater Dashboard">
                     </iframe>')
                                
                                
                              ),
  
  
  
  ### Third iframe ----------------------------------------------------------
  
            conditionalPanel(
                condition = "input.iframe_selection == 'A Different Shiny App'",
                HTML(
                  '<iframe 
                  id="external-shiny" 
                  class="external-iframe" 
                  src="https://russellshean.shinyapps.io/twitter_shiny/" 
                  title="Twitter Shiny"></iframe>'),
                                
                                
                              ),

                              
                              ))),


 
 ## Website footer -------------------------------------------------------------

footer = includeHTML("www/html/DOH_site_footer.html")

)




# Section 3: Server-------------------------------------------------------------

# this is where all the backend data processing for the website is defined
# it is both closer to traditional r than the UI but also tricky because
# objects have to be programmed for reactivity
# Here's a good intro book: https://mastering-shiny.org/

server <- function(input, output, session) {
  
  # inside the server, outputs can be defined in any order
  # I've tried to stick to the order that they appear in the ui which can't be
  # randomly ordered
  
  
  
  ## Sightings by county map -----------------------------------------------------------
  
  # this output is linked to it's html element in the ui using the 
  # html id "county_sightings_map"     
  
  output$county_sightings_map <- renderLeaflet({
    # notice the {} inside the parenthesis?
    # that's what tell R to dynamically update the variable
    # without it you'll just render a static map
    
    
    
    # this is fairly straightforward leaflet calls
    # it's how the commands would look if you we're making a leaflet within Rstudio
    
    #this is the shapefile we made in the preprocesing step
    # it's got county shapes with sightings count data
    wa_counties2 %>%
      
      #pipes the shape files into a leaflet map
      # more info about leaflet:  https://rstudio.github.io/leaflet/
      
      leaflet() %>%
      
      # this adds the county shape files onto the map
      addPolygons(
        # this tells leaflet to make a cloropleth based
        # on sightings count values, the palette and breaks
        # were defined in pre-processing steps
        fillColor = ~pal(sightings_count),
        
        # this is an internal id that will be useful for getting 
        # mouse hover and click data back to the server
        layerId = wa_counties2$JURISDICT_LABEL_NM,
        
        #line border thickness
        weight = 2,
        
        # transperency of the border lines
        opacity = 1,
        
        # border lines color
        color = "white",
        
        # make the border lines dashed with size three dashes
        dashArray = "1",
        
        # transparency of the shape
        fillOpacity = 0.7,
        
        # What happens when the mouse is over a shape: 
        highlightOptions = highlightOptions(
          weight = 5,
          fillColor = "green",
          color = "#666",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE),
        
        # this is the label the map uses
        # we defined the label pattern in the pre-processing steps
        # note: labels are not dynamically rendered through shiny
        # each county's label's asociated html is pre-defined in a column
        # in the sf dataframe
        
        label = map_labels,
        
        # this defines the css for the label
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", 
                       padding = "3px 8px",
                       "margin-left" = "auto",
                       "margin-right" = "auto"),
          textsize = "15px",
          direction = "auto"))%>%
      
      # This adds something fun to the map, bonus points for whoever find it!
      addMarkers(lat = 5.890866683908991 , 
                 lng = 148.41355743126306, 
                 icon = BigFootIcon,
                 popup = '<strong>Shiny!</strong><br><img src= "https://media.tenor.com/HUMNK0H3OB0AAAAC/tamatoa-as-a-diversion.gif" width = 300><br>') %>%
      
      # This sets the background tile (base map)
      # available options: https://leaflet-extras.github.io/leaflet-providers/preview/
      
      addProviderTiles("Esri.WorldGrayCanvas") %>% 
      
      # this defines the legend
      addLegend(pal = pal, 
                
                values = ~sightings_count, 
                opacity = 0.7, 
                title = NULL,
                position = "bottomright",
                
                
                # This is a function that changes the label title
                # see: https://stackoverflow.com/questions/47410833/how-to-customize-legend-labels-in-r-leaflet
                
                labFormat = function(type, cuts, p) {  # Here's the trick
                  paste0(legend_labels)
                })%>%
      setView(-120.161, 47.2, zoom = 6)
    
  })  # end of first reactive element output } is very important!
  
  
  
  
  ## Sightings count by county table----------------------------------------------
  
  # this selects just the columns we want to display in the data.table
  Bigfoot_county_table <- Bigfoot_county_aggregations %>%
    select(county,sightings_count,percent_of_total)
  
  # name space is important because Shiny has a renderDT function too
  output$county_sightings_table <- DT::renderDT( Bigfoot_county_table, 
                                                 options = list( pageLength = 9,
                                                                 searching = FALSE,
                                                                 # this tells data.table which extra things
                                                                 # like search bars and stuff we want
                                                                 # I only want the table and a next page button
                                                                 dom = 'tp',
                                                                 #DT is *esentially* a wrapper api sort of thing
                                                                 # to a javascript package so that may be why 
                                                                 # changing the table' header's background color
                                                                 # has to be done in javascript 
                                                                 initComplete = JS(
                                                                   "function(settings, json) {",
                                                                   "$(this.api().table()).css({'background-color': 'white', 'color': 'black'});",
                                                                   "}")),
                                                 rownames = FALSE,
                                                 colnames = c('County', 'Total Number of Sightings', 'Percent of Total Sightings'))
  
  
  
  
  
  
  ## Sightings count  epi curve -------------------------------------------
  
  # this is the sightings count plot
  # its appearance depends on if the user clicks on a county on the map
  # and if the user has slid the date slider around
  # so it's a bit more complicated
  
  output$sighting_counts_plot <- renderPlot({
    
    # this is what the plot looks like if the user hasn't clicked on a county on the map
    # if(is.null(clicked_on_county$clickedShape)){
    if(input$county_choices == "Statewide"){
      
      bigfoot_points %>% 
        
        
        # this filters the date range based on what the user has set as the date
        # range with the slider
        dplyr::filter(year_as_date %in% seq.Date(from = input$startdate[1], 
                                                 to = input$startdate[2], 
                                                 by = 1)) %>%
        
        count(year_as_date) %>%
        mutate(percent_of_total = round(n / nrow(bigfoot_points) * 100, digits = 1)) %>%
        rename(sightings_count = n) %>%
        
        
        # This pipes the filtered dataset into a ggplot
        ggplot() +
        
        # create bar chart
        geom_col(aes(x = year_as_date, y = sightings_count), fill = "#0D6ABF") +
        
        
        ggplot_standard_theme +
        
        # define plot aesthetics unique to this plot
        
        theme(axis.text.x = element_text(size = 12, angle = 45, hjust = 1),
              axis.text.y = element_text(size = 15)) +
        
        #define plot labels
        labs( title = "TOTAL ANNUAL SIGHTINGS COUNT",
              y = element_blank(),
              x = "\nYear of Sighting")  
      
      # this is is what happens if the user has clicked on a county on the map
    }else{
      
      
      
      bigfoot_county_date_aggregations %>% 
        
        
        # this filters the date range based on what the user has set as the date
        # range with the slider
        dplyr::filter(year_as_date %in% seq.Date( from = input$startdate[1], 
                                                  to = input$startdate[2], 
                                                  by = 1)) %>%
        
        dplyr::filter(county == input$county_choices ) %>%
        
        ggplot() +          
        
        geom_col(aes(x = year_as_date, y = sightings_count), fill = "#0D6ABF") +
        
        
        
        # it overlays a new county specific graph over the original graph
        
        geom_col( data = dplyr::filter(statewide_date_aggregations, 
                                       year_as_date %in% seq.Date(from = input$startdate[1], 
                                                                  to = input$startdate[2], 
                                                                  by = 1)),
                  
                  aes(x = year_as_date, y = sightings_count), fill = "#0D6ABF", 
                  
                  
                  # this filters the date range based on what the user has set as the date
                  # range with the slider
                  
                  # alpha controls transparency
                  alpha = 0.2) +
        
        ggplot_standard_theme +
        
        theme(axis.text.x = element_text(size = 12, angle = 45, hjust = 1),
              axis.text.y = element_text(size = 12)) +
        
        
        labs(title = paste0("TOTAL ANNUAL SIGHTINGS COUNT (", input$county_choices, ")"),
             y = element_blank(),
             x = "\nYear of Sighting")  
      
      
      
      
      # this overlays the state total on top of the county specific map
      # the transparency is set to be super transparent so that you can see
      # the county specific bars through the state totals
      
      
    }
    
  })
  
  
  
  
  ## Missing county values------------------------------------------------------
  
  # This adds an explanatory note to the bottom of the sighting my county map and table
  # telling the user how many sightings are missing location data
  output$missing_counties_note <- renderText({
    paste0("0 out of ",
           round_add_commas(
             sum(wa_counties2$sightings_count, 
                 na.rm = TRUE)),
           " sightings are missing location data")
    
    
  })
  
  
  
  
  ## sightings counts by Report Classification Bar Chart---------------------------------------------------
  
  output$report_class_plot <- renderPlot({
    
    # starting dataset
    bigfoot_points %>%
      
      
      # initiate blank ggplot
      ggplot() +
      
      # create bar chart
      geom_bar(aes(x = report_clasification),
               
               #color of bars
               fill = "#0D6ABF") +
      annotate("text", 
               x = 2.8,
               y = 400, 
               size = 6,
               label = "paste(bold(Hover), \" over a bar to see details\")",
               parse = TRUE) +
      
      # change plot aestetics
      # element blank gets rid of something
      # more info: ?ggplot2::theme
      
      ggplot_standard_theme +
      
      theme(axis.text.x = element_text(size = 15),
            axis.text.y = element_text(size = 12)) +
      
      # define plot labels
      labs(y = element_blank(),
           x = element_blank()) 
    
  })
  
  
  
  
  ## sightings by season and classification table --------------------------
  
  # name space is important because shiny also has a
  # renderDataTable command
  output$season_table <- DT::renderDataTable(
    
    
    
    # this does grouping by rows so that we can get a total
    # number of sightings for each Season  (ie row)
    season_columns,  
    
    #these are data.table display options
    options = list(dom = "p",
                   ordering = FALSE,
                   paging = FALSE,
                   searching = FALSE,
                   scrollX = TRUE,
                   autoWidth = TRUE, 
                   bAutoWidth = FALSE,
                   columnDefs = list(list(className = 'dt-body-center', targets = 1:3),
                                     list(className = 'dt-head-center', targets = 1:3))),
    rownames = FALSE 
    
  ) 
  
  
  
  
  ## Sightings count by day of the week plot--------------------------------------------------                                         
  
  output$weekday_plot <- renderPlot({
    
    #intial data source
    bigfoot_points %>%
      
      # create blank ggplot
      ggplot() +
      
      #create bar chart
      geom_bar(aes(x = report_weekday), fill = "#0D6ABF") +
      
      # This adds the explanatory directly to the plot
      annotate("text", 
               x = 5.70,
               y = 110, 
               size = 6,
               label = "paste(bold(Hover), \" over a bar to see details\")",
               parse = TRUE) +
      
      ggplot_standard_theme + 
      
      theme(axis.text.x = element_text(size = 12, angle = 45, hjust = 1),
            axis.text.y = element_text(size = 12)) +
      
      
      #define labels
      labs(y = element_blank(),
           x = element_blank())    })
  
  
  
  
  
  
  ## tool tips ----------------------------------------------------------------
  
  
  
  
  ### sightings count plot tool tips------------------------------------------------
  
  # a tool tip is something appears when a mouse hovers over a certain part of the 
  # ui
  
  output$sighting_counts_plot_toolTip <- renderUI({
    
    # this has information about the mouse's location! speed! distance! velocity!
    # The who what when where of the mouse and where it's going
    hover <- input$plot_hover
    
    # if the mouse isn't over the plot the tool tip shouldn't appear
    if (is.null(hover$x)) return(NULL)
    
    # the tool tip returns a plot x value as a number instead of a date
    # so for comparison we need a vector of dates as numbers
    date_as_number <- as.numeric(sightings_date_range)
    
    #This is the x position on the plot where the tooltip is located
    tooltip_x_position <- hover$x
    
    # This if else logic is because I want statewide counts to display in the tooltip
    # if "Statwide is chosen from the drop down menus
    # and county specific values to appear in the 
    # tooltip after they select  a county 
    
    if( input$county_choices == "Statewide" ){
      
      # this filters the data based on the mouse's x axis location
      tool_tip_data <- bigfoot_points %>%
        #I'm not sure how to do this in the tidyverse....
        # which(abs(x-y)==min(abs(x-y))) 
        # is a way of finding which element in the vector x
        # is closest (in any 2d direction) to the single value y
        # which returns the position in the vector which we then use to index the vector
        # All that returns a specific date that we use to filter the data to get Sightings count 
        # for only the date we're hovering over
        # https://stackoverflow.com/questions/43472234/fastest-way-to-find-nearest-value-in-vector
        dplyr::filter(year_as_date == date_as_number[which(
          abs(date_as_number - tooltip_x_position)==
            min(abs(date_as_number - tooltip_x_position),
                na.rm = TRUE))])%>%
        count(year_as_date) %>%
        rename(sightings_count = n)
      
      
    } else {
      tool_tip_data <- bigfoot_county_date_aggregations %>%
        # this further filters what we did above based on the county that's been 
        # clicked on
        filter(county == input$county_choices ) %>%
        filter(year_as_date == date_as_number[which(
          abs(date_as_number - tooltip_x_position)==
            min(abs(date_as_number - tooltip_x_position),
                na.rm = TRUE))]) 
      
    }
    
    
    
    # This tells shiny to not return anything if there's no data to display
    # (ie if your mouse is closer to the edge of the plot than the closest column on the graph)
    if (nrow(tool_tip_data) == 0) return(NULL)
    
    
    # This for dynamically calculating the tooltip's position, between the 
    # flamingos is all someelse's code:
    # https://gitlab.com/-/snippets/16220
    
    # 🦩
    # calculate point position INSIDE the image as percent of total dimensions
    # from left (horizontal) and from top (vertical)
    left_pct <- (hover$x - hover$domain$left) / (hover$domain$right - hover$domain$left)
    top_pct <- (hover$domain$top - hover$y) / (hover$domain$top - hover$domain$bottom)
    
    # calculate distance from left and bottom side of the picture in pixels
    left_px <- hover$range$left + left_pct * (hover$range$right - hover$range$left)
    
    
    top_px <- hover$range$top + top_pct * (hover$range$bottom - hover$range$top)
    
    # This is a measure of how much we want to shift the popup
    # away from the location of the mouse/tooltip
    # In this case we use the left_pct to say if if the mouse is in the 
    # right half of the plot (more than 50%) we want to shift the left position
    # more to the left (by subtracting from the left position)
    # and if the mouse is inthe left half of the plot we shift the popup slightly
    # more right by adding 2 to the left position
    
    left_adjustment <- ifelse(left_pct > .5, -600, 200)
    
    left_position <- left_px + left_adjustment
    
    # and now we do the same conditional adjustment for the vertical direction
    vertical_adjustment <- ifelse(top_pct > .5, 150 ,150)
    top_position <- top_px + vertical_adjustment
    
    # create style property for tooltip
    # background color is set so tooltip is a bit transparent
    # z-index is set so we are sure are tooltip will be on top
    # Setting it to 9999 means that it overlays other things like other plots
    style <- paste0("position:absolute; z-index:9999; background-color:white; ",
                    "left:", left_position, "px; top:", vertical_adjustment, "px;")
    
    # 🦩
    
    # actual tooltip created as wellPanel
    # This uses a wellPanel element to create the tool tip
    # the hmtl is dynamically rendered depending on where on the graph the mouse is
    wellPanel(
      style = style,
      p(HTML( paste0("<b> Year: </b>", year(tool_tip_data$year_as_date), "<br/>",
                     "<b> County: </b>", input$county_choices, "<br/>",
                     "<b> Number of Sightings: </b>", tool_tip_data$sightings_count, "<br/>",
                     "<br>","Counts that are below 10 are suppressed for<br> privacy and represented with an '*'")))
    )
  })
  
  
  
  
  ### Sightings count by Report Classification Bar Chart tooltip--------------------------------------------
  
  
  output$report_class_plot_toolTip <- renderUI({
    
    # This data about the mouse's location over the plot
    hover <- input$report_class_plot_hover
    
    # If the mouse isn't over the plot, the tool tip shouldn't be rendered
    if (is.null(hover$x)) return(NULL)
    
    
    tool_tip_data <-  bigfoot_points %>%
      filter(!is.na(report_clasification))
    
    
    
    # this returns one of three report 
    # classifications depending on which third of the graph it's on
    # because we made this variable a factor
    # so after we round the mouse's x position to either 0, 1, 2 , 3
    # we can use levels to return the correct report classification
    classification_name <- levels(bigfoot_points$report_clasification)[round(hover$x)]
    
    
    # This is the sightings count for only the report classification that we rounded to above
    count_by_classification <- bigfoot_points %>%
      filter(!is.na(report_clasification)) %>%
      filter(report_clasification == classification_name)  %>%
      nrow()
    
    # percent of total for only the report classificationwe choose by plot hovering
    percent_by_classification <- round(count_by_classification / nrow(bigfoot_points) * 100, digits = 1)
    
    # 🦩 See first tool tip for more details about all this: 
    
    # calculate point position INSIDE the image as percent of total dimensions
    # from left (horizontal) and from top (vertical)
    left_pct <- (hover$x - hover$domain$left) / (hover$domain$right - hover$domain$left)
    top_pct <- (hover$domain$top - hover$y) / (hover$domain$top - hover$domain$bottom)
    
    # calculate distance from left and bottom side of the picture in pixels
    left_px <- hover$range$left + left_pct * (hover$range$right - hover$range$left)
    top_px <- hover$range$top + top_pct * (hover$range$bottom - hover$range$top)
    
    # create style property fot tooltip
    # background color is set so tooltip is a bit transparent
    # z-index is set so we are sure are tooltip will be on top
    # Here's where we can use css to change the tool tip: 
    
    location_adjustment <- ifelse(left_pct > .5, -350, 200)
    left_position <- left_px + location_adjustment
    
    style <- paste0("position:absolute; z-index:9999; background-color:white;border: 1px solid black;",
                    "left:", left_position, "px; top:", top_px + 2, "px;")
    
    # actual tooltip created as wellPanel
    wellPanel(
      style = style,
      p(HTML(paste0("<b> Report Classification: </b>", classification_name, "<br/>",
                    "<b> Total Number of sightings: </b>", count_by_classification, "<br/>",
                    "<b> Percent of Total sightings: </b>", paste0(percent_by_classification, "%"), "<br/>",
                    "<br>","Counts that are below 10 are suppressed for<br> privacy and represented with an '*'" )))
    )
    
    # 🦩
    
  })
  
  
  
  ### Sightings count by day of the week plot tooltip---------------------------------------------
  
  output$weekday_plot_toolTip <- renderUI({
    hover <- input$plot_hover3
    
    if (is.null(hover$x)) return(NULL)
    
    
    
    # This rounds x to the nearest whole number which corresponds to a factor level
    weekday_classification <- levels(bigfoot_points$report_weekday)[round(hover$x)]
    
    # if we're closer to the plot edge than the nearest column in the chart, no tool tip is generated
    if (length(weekday_classification) == 0) return(NULL)
    
    
    #county by weekday
    count_by_weekday <- bigfoot_points %>%
      filter(!is.na(report_weekday)) %>%
      filter(report_weekday  == weekday_classification )  %>%
      nrow()
    
    # this is the percent of total for only the weekday that we choose by plot hovering
    percent_by_classification <- round(count_by_weekday / nrow(bigfoot_points) * 100, digits = 1)
    
    
    # 🦩 See first tool tip for more details: 
    
    # calculate point position INSIDE the image as percent of total dimensions
    # from left (horizontal) and from top (vertical)
    left_pct <- (hover$x - hover$domain$left) / (hover$domain$right - hover$domain$left)
    top_pct <- (hover$domain$top - hover$y) / (hover$domain$top - hover$domain$bottom)
    
    # calculate distance from left and bottom side of the picture in pixels
    left_px <- hover$range$left + left_pct * (hover$range$right - hover$range$left)
    top_px <- hover$range$top + top_pct * (hover$range$bottom - hover$range$top)
    
    # conditionally show the tooltip either to the right or the left depending on
    # position
    location_adjustment <- ifelse(left_pct > .5, -550, 100)
    left_position <- left_px + location_adjustment
    
    
    # create style property fot tooltip
    # background color is set so tooltip is a bit transparent
    # z-index is set so we are sure are tooltip will be on top
    style_tt <- paste0("position:absolute; z-index:9999; background-color: rgba(245, 245, 245, 0.99); ",  # the original alpha was 0.85
                       "left:", left_position, "px; top:", top_px + 2, "px;")
    
    # actual tooltip created as wellPanel
    wellPanel(
      style = style_tt,
      p(HTML(paste0("<b> Day of the Week: </b>", weekday_classification, "<br/>",
                    "<b> Total Number of Sightings: </b>", count_by_weekday, "<br/>",
                    "<b> Percent of Total sightings: </b>", paste0(percent_by_classification, "%"), "<br/>",
                    "<br>","These are counts by the day of the week the report was submitted,<br> not the day of the week the sighting occured.")))
    )
    
    # 🦩    
  })
  
  
  
  
  ## Point map part of the server-------------------------------------------------------
  
  
  
  
  ### Define the filtered data---------------------------------------------------
  # This is a reactive object that changes dynamically with user input
  
  filtered_feet <- reactive({
    
    # This filters bigfoot points by the filtering criteria selected
    # in the dropdown list
    bigfoot_points %>% 
      dplyr::filter(SEASON %in% input$filtering_criteria,
                    report_weekday %in% input$filtering_criteria,
                    #report_month %in% input$filtering_criteria,
                    COUNTY %in% input$filtering_criteria,
                    report_clasification %in% input$filtering_criteria)   
    
    
  })
  
  
  
  
  ### Define reactive labels---------------------------------------------------
  # This uses the re actively filtered data
  # to make labels for only the data points in the filtered dataset
  # reactive_labels are a reactive object that listen to another reactive job
  
  reactive_labels <- reactive({
    
    
    paste0(
      "<p id='popup-title'><strong>",filtered_feet()$subtitle, "</strong></p>",
      "<div id='first-popbox'>",
      "<strong>Report Date: </strong>", format(as.Date(filtered_feet()$report_date2), "%B %d, %Y"),
      "<br><strong>Report Classification: </strong>", filtered_feet()$report_clasification,
      "<br><strong>Length of Report: </strong>", filtered_feet()$report_length, " characters",
      "<br><strong>Report Season: </strong>", filtered_feet()$SEASON,
      "<br><br><strong>County: </strong>", filtered_feet()$COUNTY,
      "<br><strong>Nearest Town: </strong>", filtered_feet()$NEAREST_TOWN,
      "<br><strong>Environment: </strong>", filtered_feet()$ENVIRONMENT,
      "</div>",
      "<div id='second-popbox'>",
      "<p id='popbox-report-text'><strong>Report text</strong></p><br>", 
      substr(filtered_feet()$OBSERVED, 1, 400), "... ",
      "<br><a href='", filtered_feet()$report_links, "'>click to see full report</a></div>"
    ) %>% 
      lapply(htmltools::HTML)
    
    
  })
  
  
  
  
  ### define static parts of the map --------------------------------------------
  output$bigfoots_maps <- renderLeaflet({
    leaflet()  %>%
      
      # This adds a counties outline
      addPolylines(data = wa_counties2) %>% 
      addProviderTiles("Stamen.Terrain")   %>% 
      addMarkers( data = bigfoot_points,
                  label = ~subtitle,
                  popup = popup,
                  icon = BigFootIcon,
                  group = "default_feets"
      ) 
  })
  
  
  
  ### Define IF/ELSE conditions for point map markers --------------------------
  # This section observes various combinations of selections from the three
  # dropdown menus and modifies the markers on the plot in response
  
  # After going back through this and trying to document it, I'm thinking
  # that it may be easier to follow if I do separate if statements with AND
  # to show all the conditions that are being met for a particular map instead
  # of these giant if else chains... Or.... somehow make this a function....
  # eg. if(nrow( filtered_feet() ) < 1 & input$color_var=="None" & input$size_var=="Length of the Report")
  
  # it works! So for now I'll leave it alone, but this probably needs some reworking
  
  observe({
    
    # If the filtering criteria are too restrictive and there are no
    # sighting left in the data, return an error message with a marker
    
    if( nrow( filtered_feet() ) < 1 ){
      
      # This proxy contains the static parts of the map
      leafletProxy("bigfoots_maps") %>%
        
        # This clears markers and other dynamic parts of the map off
        # so that we can draw new ones
        clearMarkers() %>%
        clearGroup("default_feets") %>%
        clearPopups() %>%
        clearControls() %>%
        
        # Add popup in the middle of the state with a message
        addPopups(lat = 47.30933454298483, 
                  lng = -119.85063332639612,
                  # icon = BigFootIcon,
                  popup = "<strong>No sightings found!</strong><br><img style='border-radius:15px;margin-right:100px;margin-top:10px;max-width:100%;' src='https://i.makeagif.com/media/3-22-2016/XRMuTn.gif'><br><br><span style='font-size:15px;' >Add some more filtering criteria to find some bigfeets!</span>",
                  options = popupOptions( closeButton = FALSE, 
                                          closeOnClick = FALSE))
      
      
      # If none is selected as a color variable.... 
      
    } else if(input$color_var == "None"){ 
      
      # If none is selected as a color variable....AND the size variable is set to "Length of Report"
      
      if(input$size_var == "Length of the Report"){
        
        leafletProxy("bigfoots_maps", data = filtered_feet()) %>%
          
          # clear markers, popups and other dynamic parts of the map
          clearMarkers() %>%
          clearControls() %>%
          clearGroup("colors") %>%
          clearPopups() %>%
          clearGroup("legends") %>%
          clearGroup("default_size") %>%
          clearGroup("default_feets")  %>%
          
          # Add circle markers where the radius corresponds to the length of the report
          addCircleMarkers(
            radius = ~ (report_length / 500),
            stroke = FALSE, 
            fillOpacity = 0.5,
            # the label is the thing that appears on hover
            label = ~subtitle,
            # The popup is the thing that appears on click
            popup = reactive_labels(),
            fillColor = "red",
            group = "default_size"
          ) 
        
        
        # If none is selected as a color variable....AND none is selected as
        # a size variable, return a bigfoot icon as the marker
      } else{
        
        leafletProxy("bigfoots_maps", data = filtered_feet()) %>%
          clearControls() %>%
          clearMarkers() %>% 
          clearPopups() %>%
          addMarkers(
            label = ~subtitle,
            popup = reactive_labels(),
            icon = BigFootIcon,
            group = "default_feets"
          ) 
      } 
      
      
      # If color variable is not "None" ....
      
      
    } else {
      
      
      
      
      # If color variable is not "None" 
      # and the size variable is set to the length of report....
      
      if(input$size_var == "Length of the Report"){
        
        
        # If color variable is not "None" 
        # and the size variable is set to the length of report....
        # And the color variable is selected as season
        
        if( input$color_var == "Season" ){
          
          # Here we define a color palete and color mapping strategy
          # specifically for the season variable
          
          pal2 <- colorFactor(
            palette = c(large_pal[1:(length(levels(bigfoot_points$SEASON)) - 1)], "#F3F2F1"),
            domain = bigfoot_points$SEASON
          )
          
          leafletProxy("bigfoots_maps", data = filtered_feet()) %>%
            clearMarkers() %>%
            clearControls() %>%
            clearPopups() %>%
            
            addCircleMarkers(
              radius = ~ (report_length / 500),
              stroke = FALSE, 
              label = ~subtitle,
              popup = reactive_labels(),
              
              # This colors the circle to correspond to the pal2 function
              # we made above
              fillColor = ~pal2(SEASON),
              fillOpacity = 0.5,
              group = "colors") %>%
            
            # This adds a legend that tracks to the pal2 function
            addLegend( title = "Season",
                       pal = pal2, 
                       values = ~SEASON, 
                       
                       position = "bottomleft")
          
          
          # If color variable is not "None" 
          # and the size variable is set to the length of report....
          # And the color variable is selected as Day of the Week
          
          
        }else if( input$color_var == "Day of the Week" ){
          
          pal2 <- colorFactor(
            palette = c(large_pal[1:(length(levels(bigfoot_points$report_weekday)) - 1)], "#F3F2F1"),
            domain = bigfoot_points$report_weekday
          )
          
          leafletProxy("bigfoots_maps", data = filtered_feet()) %>%
            #  clearMarkers() %>%
            clearControls() %>%
            clearGroup("legends") %>%
            clearGroup("colors") %>%
            clearGroup("default_size") %>%
            clearGroup("default_feets") %>%
            clearPopups() %>%
            
            addCircleMarkers(
              radius = ~ (report_length / 500),
              stroke = FALSE, 
              label = ~subtitle,
              popup = reactive_labels(),
              fillColor = ~pal2(report_weekday),
              fillOpacity = 0.5,
              group = "colors") %>%
            
            addLegend( title = "Day of the week",
                       pal = pal2, 
                       values = ~report_weekday, 
                       #   group = "legends", 
                       #  className = "point-map-legend",
                       position = "bottomleft")
          
          
          # If color variable is not "None" 
          # and the size variable is set to the length of report....
          # And the color variable is selected as Report Classification
          
          
        } else if ( input$color_var == "Report Classification") {
          
          pal2 <- colorFactor(
            palette = c(large_pal[1:(length(levels(bigfoot_points$report_clasification)) - 1)], "#F3F2F1"),
            domain = bigfoot_points$report_clasification
          )
          
          leafletProxy("bigfoots_maps", data = filtered_feet()) %>%
            #  clearMarkers() %>%
            clearControls() %>%
            clearGroup("legends") %>%
            clearGroup("colors") %>%
            clearGroup("default_size") %>%
            clearGroup("default_feets") %>%
            clearPopups() %>%
            
            addCircleMarkers(
              radius = ~ (report_length / 500),
              stroke = FALSE, 
              label = ~subtitle,
              popup = reactive_labels(),
              fillColor = ~pal2(report_clasification),
              fillOpacity = 0.5,
              group = "colors") %>%
            
            addLegend( title = "Report Classification",
                       pal = pal2, 
                       values = ~report_clasification, 
                       
                       position = "bottomleft")
          
          
          # If color variable is not "None" 
          # and the size variable is set to the length of report....
          # And the color variable is selected as season
          
        } else{
          
          leafletProxy("bigfoots_maps", data = filtered_feet()) %>%
            #  clearMarkers() %>%
            clearControls() %>%
            clearGroup("legends") %>%
            clearGroup("colors") %>%
            clearGroup("default_size") %>%
            clearGroup("default_feets") %>%
            clearPopups() %>%
            
            addCircleMarkers(
              radius = ~ (report_length / 500),
              stroke = FALSE, 
              label = ~subtitle,
              popup = reactive_labels(),
              fillColor = "red",
              fillOpacity = 0.5,
              group = "default_size")
        }
        
      } else{
        
        if( input$color_var == "Season" ){
          
          pal2 <- colorFactor(
            palette = c(large_pal[1:(length(levels(bigfoot_points$SEASON)) - 1)],"#F3F2F1"),
            domain = bigfoot_points$SEASON
          )
          
          leafletProxy("bigfoots_maps", data = filtered_feet()) %>%
            clearMarkers() %>%
            clearControls() %>%
            clearPopups() %>%
            
            addCircleMarkers(
              radius = 10,
              stroke = FALSE, 
              label = ~subtitle,
              popup = reactive_labels(),
              fillColor = ~pal2(SEASON),
              fillOpacity = 0.5,
              group = "colors") %>%
            
            addLegend( title = "Season",
                       pal = pal2, 
                       values = ~SEASON, 
                       position = "bottomleft")
          
          
        } else if( input$color_var == "Day of the Week" ){
          
          pal2 <- colorFactor(
            palette = c(large_pal[1:(length(levels(bigfoot_points$report_weekday)) - 1)], "#F3F2F1"),
            domain = bigfoot_points$report_weekday
          )
          
          
          leafletProxy("bigfoots_maps",data = filtered_feet()) %>%
            clearMarkers() %>%
            clearControls() %>%
            clearPopups() %>%
            
            addCircleMarkers(
              radius = 10,
              stroke = FALSE, 
              label = ~subtitle,
              popup = reactive_labels(),
              fillColor = ~pal2(report_weekday),
              fillOpacity = 0.5,
              group = "colors") %>%
            
            addLegend( title = "Day of the Week",
                       pal = pal2, 
                       values = ~report_weekday, 
                       position = "bottomleft")
          
          
        } else if ( input$color_var == "Report Classification") {
          
          pal2 <- colorFactor(
            palette = c(large_pal[1:(length(levels(bigfoot_points$report_clasification)) - 1)], "#F3F2F1"),
            domain = bigfoot_points$report_clasification
          )
          
          leafletProxy("bigfoots_maps", data = filtered_feet()) %>%
            clearControls() %>%
            clearMarkers() %>%
            clearPopups() %>%
            
            addCircleMarkers(
              radius = 10,
              stroke = FALSE, 
              label = ~subtitle,
              popup = reactive_labels(),
              fillColor = ~pal2(report_clasification),
              fillOpacity = 0.5)  %>%
            
            addLegend( title = "Report Classification",
                       pal = pal2, 
                       values = ~report_clasification, 
                       position = "bottomleft")
          
        } else{
          
          leafletProxy("bigfoots_maps", data = filtered_feet()) %>%
            clearControls() %>%
            clearMarkers() %>% 
            clearPopups() %>%
            
            addCircleMarkers(
              radius = 10,
              stroke = FALSE, 
              label = ~subtitle,
              popup = reactive_labels(),
              fillColor = "red",
              fillOpacity = 0.5,
              group = "default_size")
        }
        
      }
    } 
  })
  
  
  
  
  ## contact form part of the server -----------------------------------------------
  # This was adapted from this stack overflow answer:
  # https://stackoverflow.com/a/59895346
  
  disable("send")
  
  
  
  ### Popup Dialouge box ---------------------------------------------------------------
  # create a function to display a popup modal box
  
  make_email_sent_modal <-function(failed = FALSE) {
    
    modalDialog(
      title="",
      
      fluidRow(column(width = 12, 
                      align = "left",
                      "Thanks for contacting us!")),
      br(),
      easyClose = FALSE,
      footer = fluidRow(column = 12, align="left",
                        modalButton("OK", icon = icon("fas fa-check-circle"))
      )
    )
  } 
  
  
  # this uses the shinyjs disable function, to disable the send button, 
  # the message the user submits and the users email untl some condition is met
  
  observeEvent( input$send, {
    
    shinyjs::disable("send")
    
    shinyjs::disable("users_message")
    shinyjs::disable("users_email")
    
    
    # get a time
   # date_time <- add_readable_time() # => "Thursday, November 28, 2019 at 4:34 PM (CET)"
    
    # compose an email using markdown (which then uses html)
    
    
    
    ### email to server admin ---------------------------------------------------
  #  email <-
    #  compose_email(
     #   body = md(
      #    c(paste0('<html>Hello,<br>We got feedback on the bigfoot shiny dashboard.<br><br>',
       #            input$users_email,
        #           ' said: <br>"',
         #          input$users_message,
          #         '"</html>')
     #     )
      #  ),
       # footer = md(
       #   c(
        #    "Email received at: ", date_time, "."
      #    )
  #      )
   #   )
    
    
    
    ### email to user ------------------------------------------------------------
 #   email2 <-
  #    compose_email(
   #     body = md(
    #      c(paste0('<html>Hello,<br>Thank you for submitting feedback to us. We will get back to you soon!<br>Here is a copy of what you told us:<br><br>"',
     #              input$users_message,
      #             '"</html>')
       #   )
    #    ),
  #      footer = md(
   #       c(
    #        "Email sent at: ", date_time, "."
     #     )
  #      )
   #   )
    
    # This is how you send the email
    # it will use the stored credentials and not ask for the password a second time
    
    # Send email to the server administrator (Me! )
   # smtp_send(
    #  email = email,
     # subject = "Someone gave us feedback on the Bigfoot Dashboard",
    #  from = "russell.shean@doh.wa.gov",
    #  to = c("russell.shean@doh.wa.gov", "russshean@gmail.com"),
    #  credentials = creds_key("RUSS_CRED")
  #  )
    
    # send email to user thanking them for their feedback
  #  smtp_send(
   #   email = email2,
  #    subject = "Thanks for submitting feedback about our Bigfoot Dashboard!",
  #    from = "russell.shean@doh.wa.gov",
  #    to = input$users_email,
  #    credentials = creds_key("RUSS_CRED")
  #  )
    
    
    
    ### write feedback to log --------------------------------------------------
    
    # write the message to a log file on the Y drive
 #   message_received <- data.frame(date = date_time,
  #                                 message = input$users_message,
   #                                from = input$users_email)
    
    
    
    # check to see if a log file exsits
   # if(exists(user_feedback_file)){
      
      # if file exists 
      # read in log, append message to log, write updated log to file  
      
    #  all_messages <- read.csv(user_feedback_file)
      
      
      
     # all_messages <- rbind(all_messages, message_received)
      
    #  write.csv(all_messages, 
   #             file = user_feedback_file,
  #              row.names = FALSE)
      
 #   } else{
  #    write.csv(message_received, 
   #             file = user_feedback_file,
    #            row.names = FALSE)
      
#    }
    
    
    
    # This uses shinyjs to enable the send button, the input boxes and the popup
    shinyjs::enable("send")
    
    shinyjs::enable("users_message")
    shinyjs::enable("users_email")
    showModal(make_email_sent_modal())
    
    # This specifies placeholder values to put in input boxes
    updateTextInput(session, 
                    "users_message", 
                    value="", 
                    placeholder = "Tell us what you think!")
    
    
    updateTextInput(session, 
                    "users_email", 
                    value="", 
                    placeholder = "")
    
    
  })
  
  
  
  ##### enable the option to click to send
  
  # These are two reactive values flags 
  # used to determine when to enable parts of the email sned function
  
  message_okay <- reactiveValues(sendable = FALSE)
  email_okay <- reactiveValues(sendable2 = FALSE)
  
  
  # If something has been put in the message box
  # change first flag to true
  observeEvent(input$users_message,{
    
    if(input$users_message != ""){
      isolate(message_okay$sendable <- TRUE)
    }
    else{
      isolate(message_okay$sendable <- FALSE)
    }
  })
  
  ## If the text put in the email box
  ## contains a little mouse set the second flag to true
  
  observeEvent(input$users_email, {
    
    if(grepl("@", input$users_email) ){
      isolate(email_okay$sendable2 <- TRUE)
    }
    else{
      isolate(email_okay$sendable2 <- FALSE)
    }
  })
  
  # If both the message and the email are okay
  # enable the send button
  observe({
    
    if(email_okay$sendable2 & message_okay$sendable){
      shinyjs::enable("send")
    }
    else{
      shinyjs::disable("send")
    }
  })
  
  
  
  
  ## Missing text part of the server---------------------------------------------
  # render the text displayed below graphics that tells the viewer how many
  # values are missing
  
  output$report_missing <- renderText({ report_missing })
  
  output$time_missing <- renderText({ season_missing })
  
  output$weekday_missing <- renderText({  weekday_missing })
  
  
  
}



# Run the application----------------------------------------------------------- 
shinyApp(ui = ui, server = server)

