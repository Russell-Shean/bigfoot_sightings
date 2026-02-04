# load data and settings
source("R/settings.R")

# Load modules
module_files <- list.files("modules", pattern = "\\.R$", recursive = TRUE, full.names = TRUE)
sapply(module_files, source)




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



