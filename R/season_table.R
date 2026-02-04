## sightings by season and classification table --------------------------

# name space is important because shiny also has a
# renderDataTable command

season_table_UI <- function(id) {
  ns <- NS(id)
  tagList(
    

    DT::dataTableOutput(ns("season_table"))
    
    
    
    )
    

}


season_table_server <- function(id) {
  moduleServer(id, function(input, output, session) {


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


  })
}