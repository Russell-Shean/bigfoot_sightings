
### Sightings count by day of the week plot tooltip---------------------------------------------






weekday_plot_toolTip_UI <- function(id) {
  ns <- NS(id)
  tagList(
    
    uiOutput(ns("weekday_plot_toolTip"))
    
  )
}



weekday_plot_toolTip_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    

output$weekday_plot_toolTip <- renderUI({
  hover <- input$plot_hover3
  
  if (is.null(hover$x)) return(NULL)
  
  
  
  # This rounds x to the nearest whole number which corresponds to a factor level
  weekday_classification <- levels(bigfoot_points$report_weekday)[round(hover$x)]
  
  # if we're closer to the plot edge than the nearest column in the chart, no tool tip is generated
  if (length(weekday_classification) == 0) return(NULL)
  
  
  #county by weekday
  count_by_weekday <- bigfoot_points %>%
    filter(!is.na(report_weekday)) %>%
    filter(report_weekday  == weekday_classification )  %>%
    nrow()
  
  # this is the percent of total for only the weekday that we choose by plot hovering
  percent_by_classification <- round(count_by_weekday / nrow(bigfoot_points) * 100, digits = 1)
  
  
  # 🦩 See first tool tip for more details:
  
  # calculate point position INSIDE the image as percent of total dimensions
  # from left (horizontal) and from top (vertical)
  left_pct <- (hover$x - hover$domain$left) / (hover$domain$right - hover$domain$left)
  top_pct <- (hover$domain$top - hover$y) / (hover$domain$top - hover$domain$bottom)
  
  # calculate distance from left and bottom side of the picture in pixels
  left_px <- hover$range$left + left_pct * (hover$range$right - hover$range$left)
  top_px <- hover$range$top + top_pct * (hover$range$bottom - hover$range$top)
  
  # conditionally show the tooltip either to the right or the left depending on
  # position
  location_adjustment <- ifelse(left_pct > .5, -550, 100)
  left_position <- left_px + location_adjustment
  
  
  # create style property fot tooltip
  # background color is set so tooltip is a bit transparent
  # z-index is set so we are sure are tooltip will be on top
  style_tt <- paste0("position:absolute; z-index:9999; background-color: rgba(245, 245, 245, 0.99); ",  # the original alpha was 0.85
                     "left:", left_position, "px; top:", top_px + 2, "px;")
  
  # actual tooltip created as wellPanel
  wellPanel(
    style = style_tt,
    p(HTML(paste0("<b> Day of the Week: </b>", weekday_classification, "<br/>",
                  "<b> Total Number of Sightings: </b>", count_by_weekday, "<br/>",
                  "<b> Percent of Total sightings: </b>", paste0(percent_by_classification, "%"), "<br/>",
                  "<br>","These are counts by the day of the week the report was submitted,<br> not the day of the week the sighting occured.")))
  )
  
  # 🦩
})


  })
}

