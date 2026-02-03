


county_sightings_table_UI <- function(id) {
  ns <- NS(id)
  
tagList(

tags$div(
  id = "sighting_counts_plot_column",
  # here's the sightings by year curve chart
  plotOutput(ns("sighting_counts_plot"),
             
             # this tells shiny to listen to and store information
             # about where over the chart the user's mouse is hovering
             # this is how we tell the tool tip which column to display
             # info for
             hover = hoverOpts("plot_hover",
                               
                               # this (I think) puts a delay on how often
                               # hover info is recorded and sent to
                               # the server
                               delay = 100,
                               delayType = "debounce")))



)}



sighting_counts_plot_server <- function(id) {
  moduleServer(id, function(input, output, session) {

output$sighting_counts_plot <- renderPlot({
  
  # this is what the plot looks like if the user hasn't clicked on a county on the map
  
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


  })
}