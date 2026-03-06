## sightings counts by Report Classification Bar Chart---------------------------------------------------


report_class_plot_UI <- function(id) {
  ns <- NS(id)
  tagList(
    
    plotOutput(ns("report_class_plot"),
               
               # records mouse hover data for Report Classification Bar Chart
               hover = hoverOpts(ns("plot_hover"),
                                 delay = 100,
                                 delayType = "debounce"))
    
  )
  
}


report_class_plot_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    

output$report_class_plot <- renderPlot({
  
  # starting dataset
  bigfoot_points %>%
    
    # initiate blank ggplot
    ggplot() +
    
    # create bar chart
    geom_bar(aes(x = classification),
             
             #color of bars
             fill = "#0D6ABF") +
    annotate("text",
             x = 2.8,
             y = 400,
             size = 6,
             label = "paste(bold(Hover), \" over a bar to see details\")",
             parse = TRUE) +
    
    # change plot aestetics
    # element blank gets rid of something
    # more info: ?ggplot2::theme
    
    ggplot_standard_theme +
    
    theme(axis.text.x = element_text(size = 15),
          axis.text.y = element_text(size = 12)) +
    
    # define plot labels
    labs(y = element_blank(),
         x = element_blank())
  
})

  })
}