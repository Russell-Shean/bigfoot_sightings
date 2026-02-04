### Define the filtered data---------------------------------------------------
# This is a reactive object that changes dynamically with user input






filtering_criteria_UI <- function(id) {
  ns <- NS(id)
  tagList(
    
    #### filtering variable choices --------------------------------------------------
    tags$span(id = "map_choice-container",
              pickerInput(
                inputId = ns("filtering_criteria"),
                label = "Choose Filtering Criteria",
                choices = list(
                  `Report Classification` = levels(bigfoot_points$classification),
                  Season = levels(bigfoot_points$season),
                  `Day of the week` = levels(bigfoot_points$report_weekday),
                  County = unique(bigfoot_points$county)),
                
                selected = c(  levels(bigfoot_points$classification),
                               levels(bigfoot_points$season),
                               unique(bigfoot_points$county),
                               levels(bigfoot_points$report_weekday)),
                
                options = list(`selected-text-format`= "static",
                               title = "Filters",
                               `actions-box` = TRUE),
                
                multiple = TRUE))
    
  )
}



filtering_criteria_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    
    filtered_feet <- reactive({
      
      req(input$filtering_criteria)
      
      # This filters bigfoot points by the filtering criteria selected
      # in the dropdown list
      bigfoot_points %>%
        dplyr::filter(season %in% input$filtering_criteria,
                      report_weekday %in% input$filtering_criteria,
                      county %in% input$filtering_criteria,
                      classification %in% input$filtering_criteria)
      
      
    })
    
    
    return(filtered_feet)
    
    
    
  })
}