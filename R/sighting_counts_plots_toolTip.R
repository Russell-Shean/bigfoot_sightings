
sighting_counts_plot_toolTip_UI <- function(id) {
  ns <- NS(id)
  tagList(
    
    uiOutput(ns("sighting_counts_plot_toolTip"))
    
  )
}


sighting_counts_plot_toolTip_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    
    


output$sighting_counts_plot_toolTip <- renderUI({
  
  # this has information about the mouse's location! speed! distance! velocity!
  # The who what when where of the mouse and where it's going
  hover <- input$plot_hover
  
  # if the mouse isn't over the plot the tool tip shouldn't appear
  if (is.null(hover$x)) return(NULL)
  
  # the tool tip returns a plot x value as a number instead of a date
  # so for comparison we need a vector of dates as numbers
  date_as_number <- as.numeric(sightings_date_range)
  
  #This is the x position on the plot where the tooltip is located
  tooltip_x_position <- hover$x
  
  # This if else logic is because I want statewide counts to display in the tooltip
  # if "Statwide is chosen from the drop down menus
  # and county specific values to appear in the
  # tooltip after they select  a county
  
  if( input$county_choices == "Statewide" ){
    
    # this filters the data based on the mouse's x axis location
    tool_tip_data <- bigfoot_points %>%
      #I'm not sure how to do this in the tidyverse....
      # which(abs(x-y)==min(abs(x-y)))
      # is a way of finding which element in the vector x
      # is closest (in any 2d direction) to the single value y
      # which returns the position in the vector which we then use to index the vector
      # All that returns a specific date that we use to filter the data to get Sightings count
      # for only the date we're hovering over
      # https://stackoverflow.com/questions/43472234/fastest-way-to-find-nearest-value-in-vector
      dplyr::filter(year_as_date == date_as_number[which(
        abs(date_as_number - tooltip_x_position)==
          min(abs(date_as_number - tooltip_x_position),
              na.rm = TRUE))])%>%
      count(year_as_date) %>%
      rename(sightings_count = n)
    
    
  } else {
    tool_tip_data <- bigfoot_county_date_aggregations %>%
      # this further filters what we did above based on the county that's been
      # clicked on
      filter(county == input$county_choices ) %>%
      filter(year_as_date == date_as_number[which(
        abs(date_as_number - tooltip_x_position)==
          min(abs(date_as_number - tooltip_x_position),
              na.rm = TRUE))])
    
  }
  
  
  
  # This tells shiny to not return anything if there's no data to display
  # (ie if your mouse is closer to the edge of the plot than the closest column on the graph)
  if (nrow(tool_tip_data) == 0) return(NULL)
  
  
  # This for dynamically calculating the tooltip's position, between the
  # flamingos is all someone else's code:
  # https://gitlab.com/-/snippets/16220
  
  # 🦩
  # calculate point position INSIDE the image as percent of total dimensions
  # from left (horizontal) and from top (vertical)
  left_pct <- (hover$x - hover$domain$left) / (hover$domain$right - hover$domain$left)
  top_pct <- (hover$domain$top - hover$y) / (hover$domain$top - hover$domain$bottom)
  
  # calculate distance from left and bottom side of the picture in pixels
  left_px <- hover$range$left + left_pct * (hover$range$right - hover$range$left)
  
  
  top_px <- hover$range$top + top_pct * (hover$range$bottom - hover$range$top)
  
  # This is a measure of how much we want to shift the popup
  # away from the location of the mouse/tooltip
  # In this case we use the left_pct to say if if the mouse is in the
  # right half of the plot (more than 50%) we want to shift the left position
  # more to the left (by subtracting from the left position)
  # and if the mouse is inthe left half of the plot we shift the popup slightly
  # more right by adding 2 to the left position
  
  left_adjustment <- ifelse(left_pct > .5, -600, 200)
  
  left_position <- left_px + left_adjustment
  
  # and now we do the same conditional adjustment for the vertical direction
  vertical_adjustment <- ifelse(top_pct > .5, 150 ,150)
  top_position <- top_px + vertical_adjustment
  
  # create style property for tooltip
  # background color is set so tooltip is a bit transparent
  # z-index is set so we are sure are tooltip will be on top
  # Setting it to 9999 means that it overlays other things like other plots
  style <- paste0("position:absolute; z-index:9999; background-color:white; ",
                  "left:", left_position, "px; top:", vertical_adjustment, "px;")
  
  # 🦩
  
  # actual tooltip created as wellPanel
  # This uses a wellPanel element to create the tool tip
  # the hmtl is dynamically rendered depending on where on the graph the mouse is
  wellPanel(
    style = style,
    p(HTML( paste0("<b> Year: </b>", year(tool_tip_data$year_as_date), "<br/>",
                   "<b> County: </b>", input$county_choices, "<br/>",
                   "<b> Number of Sightings: </b>", tool_tip_data$sightings_count, "<br/>",
                   "<br>","Counts that are below 10 are suppressed for<br> privacy and represented with an '*'")))
  )
})


  })
}
