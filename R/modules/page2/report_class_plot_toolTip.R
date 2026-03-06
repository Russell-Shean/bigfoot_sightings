### Sightings count by Report Classification Bar Chart tooltip--------------------------------------------


report_class_plot_toolTip_UI <- function(id) {
  ns <- NS(id)
  tagList(
    
    uiOutput(ns("report_class_plot_toolTip"))
    
  )
}





report_class_plot_toolTip_server<- function(id, plot_hover) {
  moduleServer(id, function(input, output, session) {


output$report_class_plot_toolTip <- renderUI({
  
  
  req(plot_hover())
  hover <- plot_hover()
  
  
  # If the mouse isn't over the plot, the tool tip shouldn't be rendered
  if (is.null(hover$x)) return(NULL)
  
  
  tool_tip_data <-  bigfoot_points %>%
    filter(!is.na(classification))
  
  
  
  # this returns one of three report
  # classifications depending on which third of the graph it's on
  # because we made this variable a factor
  # so after we round the mouse's x position to either 0, 1, 2 , 3
  # we can use levels to return the correct report classification
  classification_name <- levels(bigfoot_points$classification)[round(hover$x)]
  
  
  # This is the sightings count for only the report classification that we rounded to above
  count_by_classification <- bigfoot_points %>%
    filter(!is.na(classification)) %>%
    filter(classification == classification_name)  %>%
    nrow()
  
  # percent of total for only the report classificationwe choose by plot hovering
  percent_by_classification <- round(count_by_classification / nrow(bigfoot_points) * 100, digits = 1)
  
  # 🦩 See first tool tip for more details about all this:
  
  # calculate point position INSIDE the image as percent of total dimensions
  # from left (horizontal) and from top (vertical)
  left_pct <- (hover$x - hover$domain$left) / (hover$domain$right - hover$domain$left)
  top_pct <- (hover$domain$top - hover$y) / (hover$domain$top - hover$domain$bottom)
  
  # calculate distance from left and bottom side of the picture in pixels
  left_px <- hover$range$left + left_pct * (hover$range$right - hover$range$left)
  top_px <- hover$range$top + top_pct * (hover$range$bottom - hover$range$top)
  
  # create style property fot tooltip
  # background color is set so tooltip is a bit transparent
  # z-index is set so we are sure are tooltip will be on top
  # Here's where we can use css to change the tool tip:
  
  location_adjustment <- ifelse(left_pct > .5, -350, 200)
  left_position <- left_px + location_adjustment
  
  style <- paste0("position:absolute; z-index:9999; background-color:white;border: 1px solid black;",
                  "left:", left_position, "px; top:", top_px + 2, "px;")
  
  # actual tooltip created as wellPanel
  wellPanel(
    style = style,
    p(HTML(paste0("<b> Report Classification: </b>", classification_name, "<br/>",
                  "<b> Total Number of sightings: </b>", count_by_classification, "<br/>",
                  "<b> Percent of Total sightings: </b>", paste0(percent_by_classification, "%") )))
  )
  
  # 🦩
  
})

  })
}
