## Sightings count by county table----------------------------------------------




county_sightings_table_UI <- function(id) {
  ns <- NS(id)
  tagList(
    
    conditionalPanel(
      condition = "input.map_or_table_button == 'Table View'",
      
      # this uses R's wrapper to the data.table package in javascript
      # a lot of the appearance is defined in the server using the wrapper
      DTOutput(ns("county_sightings_table"))
    )

  )
}



county_sightings_table_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    
    # this selects just the columns we want to display in the data.table
    Bigfoot_county_table <- Bigfoot_county_aggregations %>%
      select(county,sightings_count,percent_of_total)
    
    
    

# name space is important because Shiny has a renderDT function too
output$county_sightings_table <- DT::renderDT( Bigfoot_county_table,
                                               options = list( pageLength = 8,
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



  })
}