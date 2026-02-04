page2_UI <- function() {
  
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
  )
  
}