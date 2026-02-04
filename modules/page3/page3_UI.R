page3_UI <- function() {
 
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
                       

                     )))
}