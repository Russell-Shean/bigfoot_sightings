

reactive_labels_server <- function(id, filtered_feet) {
  moduleServer(id, function(input, output, session) {
    
    ### Define reactive labels---------------------------------------------------
    # This uses the re actively filtered data
    # to make labels for only the data points in the filtered dataset
    # reactive_labels are a reactive object that listen to another reactive job
    
    reactive_labels <- reactive({
      
      
      req(filtered_feet())
      
      
      paste0(
        "<p id='popup-title'><strong>",filtered_feet()$summary, "</strong></p>",
        "<div id='first-popbox'>",
        "<strong>Report Date: </strong>", format(as.Date(filtered_feet()$report_date2), "%B %d, %Y"),
        "<br><strong>Report Classification: </strong>", filtered_feet()$classification,
        "<br><strong>Length of Report: </strong>", filtered_feet()$report_length, " characters",
        "<br><strong>Report Season: </strong>", filtered_feet()$season,
        "<br><br><strong>County: </strong>", filtered_feet()$county,
        "<br><strong>Nearest Town: </strong>", filtered_feet()$nearest_town,
        "<br><strong>Environment: </strong>", filtered_feet()$environment,
        "</div>",
        "<div id='second-popbox'>",
        "<p id='popbox-report-text'><strong>Report text</strong></p><br>",
        substr(filtered_feet()$observed, 1, 400), "... ",
        "<br><a href='", filtered_feet()$url, "'>click to see full report</a></div>"
      ) %>%
        lapply(htmltools::HTML)
      
      
    })
    
    
    
    
    
    
  })
}



