sighting_counts_plot_toolTip_UI <- function(id) {
  ns <- NS(id)
  uiOutput(ns("sighting_counts_plot_toolTip"))
}


sighting_counts_plot_toolTip_server <- function(id, county_choices, plot_hover) {
  moduleServer(id, function(input, output, session) {
    
    output$sighting_counts_plot_toolTip <- renderUI({
      
      req(county_choices(), plot_hover())
      hover <- plot_hover()
      
      if (is.null(hover$x)) return(NULL)
      
      # Convert dates to numeric for comparison
      date_nums <- as.numeric(sightings_date_range)
      closest_index <- which.min(abs(date_nums - hover$x))
      closest_date <- date_nums[closest_index]
      
      # Filter data based on county choice
      tool_tip_data <- if (county_choices() == "Statewide") {
        bigfoot_points %>%
          filter(year_as_date == closest_date) %>%
          count(year_as_date) %>%
          rename(sightings_count = n)
      } else {
        bigfoot_county_date_aggregations %>%
          filter(county == county_choices(),
                 year_as_date == closest_date)
      }
      
      if (nrow(tool_tip_data) == 0) return(NULL)
      
      # Function to calculate tooltip position and keep it inside the plot
      calc_smart_position <- function(hover, tooltip_width = 200, tooltip_height = 100, margin = 10) {
        # Percent position of mouse in plot
        left_pct <- (hover$x - hover$domain$left) / (hover$domain$right - hover$domain$left)
        top_pct  <- (hover$domain$top - hover$y) / (hover$domain$top - hover$domain$bottom)
        
        # Convert to pixels
        left_px <- hover$range$left + left_pct * (hover$range$right - hover$range$left)
        top_px  <- hover$range$top + top_pct * (hover$range$bottom - hover$range$top)
        
        # Determine horizontal position
        if (left_px + tooltip_width + margin > hover$range$right) {
          left_px <- left_px - tooltip_width - margin  # move left if it overflows
        } else {
          left_px <- left_px + margin  # normal right offset
        }
        
        # Determine vertical position
        if (top_px + tooltip_height + margin > hover$range$bottom) {
          top_px <- top_px - tooltip_height - margin  # move up if it overflows
        } else {
          top_px <- top_px + margin  # normal downward offset
        }
        
        list(left = left_px, top = top_px)
      }
      
      pos <- calc_smart_position(hover)
      
      style <- paste0(
        "position:absolute; z-index:9999; background-color:white; ",
        "left:", pos$left, "px; top:", pos$top, "px; padding: 10px; border-radius: 5px; box-shadow: 2px 2px 5px rgba(0,0,0,0.3); width: 200px;"
      )
      
      wellPanel(
        style = style,
        p(HTML(paste0(
          "<b>Year:</b> ", year(tool_tip_data$year_as_date), "<br/>",
          "<b>County:</b> ", county_choices(), "<br/>",
          "<b>Number of Sightings:</b> ", tool_tip_data$sightings_count
        )))
      )
    })
    
  })
}
