## First page-------------------------------------------------------------------
page1_UI <- function(id) {

    

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
                                       'This dashboard shows an example of how R shiny can be used to visualize data. Data was scraped from an online database of bigfoot sightings. This dashboard does not include new reports made since the last updated date in the top right corner. To remove this header click the "condense dashboard" button below.',
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
  
)
  


}
