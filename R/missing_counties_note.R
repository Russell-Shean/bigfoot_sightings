## Missing county values------------------------------------------------------

# This adds an explanatory note to the bottom of the sighting my county map and table
# telling the user how many sightings are missing location data

missing_counties_note_UI <- function(id) {
  ns <- NS(id)
  tagList(
    

tags$span(class = "missing-text",
          textOutput(ns("missing_counties_note")))

)
  
}


missing_counties_note_server <- function(id) {
  moduleServer(id, function(input, output, session) {

output$missing_counties_note <- renderText({
  paste0("0 out of ",
         round_add_commas(
           sum(wa_counties$sightings_count,
               na.rm = TRUE)),
         " sightings are missing location data")
  
  
})


  })
}