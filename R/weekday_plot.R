## Sightings count by day of the week plot--------------------------------------------------

weekday_plot_UI <- function(id) {
  ns <- NS(id)
  tagList(
    
    plotOutput(ns("weekday_plot"),
               
               # info about the user's mouse hoverings
               hover = hoverOpts("plot_hover3",
                                 delay = 100,
                                 delayType = "debounce"))
  )
}


  
weekday_plot_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
  
output$weekday_plot <- renderPlot({
  
  #intial data source
  bigfoot_points %>%
    
    # create blank ggplot
    ggplot() +
    
    #create bar chart
    geom_bar(aes(x = report_weekday), fill = "#0D6ABF") +
    
    # This adds the explanatory directly to the plot
    annotate("text",
             x = 5.70,
             y = 110,
             size = 6,
             label = "paste(bold(Hover), \" over a bar to see details\")",
             parse = TRUE) +
    
    ggplot_standard_theme +
    
    theme(axis.text.x = element_text(size = 12, angle = 45, hjust = 1),
          axis.text.y = element_text(size = 12)) +
    
    
    #define labels
    labs(y = element_blank(),
         x = element_blank())    })


  })
}