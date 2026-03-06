# Load modules
module_files <- list.files("R/modules", pattern = "\\.R$", recursive = TRUE, full.names = TRUE)
sapply(module_files, source)


server <- function(input, output, session) {

# Page 1 -----------------------------------------------------------------------
county_sightings_map <- county_sightings_map_server("county_sightings_map")
county_sightings_table <- county_sightings_table_server("county_sightings_table")

sighting_counts_plot_server("sighting_counts_plot")
missing_counties_note <- missing_counties_note_server("missing_counties_note")

sighting_counts_plot_server(
  "sighting_counts_plot",
  county_choices = reactive(input$county_choices),
  startdate = reactive(input$startdate)
)

sighting_counts_plot_toolTip <- sighting_counts_plot_toolTip_server("sighting_counts_plot_toolTip",
                                                                    county_choices = reactive(input$county_choices),
                                                                    plot_hover    = reactive({
                                                                      input[["sighting_counts_plot-plot_hover"]]  
                                                                    })
                                                                    )

# Page 2 -----------------------------------------------------------------------
report_class_plot <- report_class_plot_server("report_class_plot")
report_class_plot_toolTip <- report_class_plot_toolTip_server("report_class_plot_toolTip",
                                                              plot_hover    = reactive({
                                                                input[["report_class_plot-plot_hover"]]  
                                                              }))


season_table <- season_table_server("season_table")


weekday_plot <- weekday_plot_server("weekday_plot")
weekday_plot_toolTip <- weekday_plot_toolTip_server("weekday_plot_toolTip",
                                                    plot_hover    = reactive({
                                                      input[["weekday_plot-plot_hover"]]  
                                                    }))



# Page 3 -----------------------------------------------------------------------


filtered_feet <- filtering_criteria_server("filtering_criteria")
reactive_labels <- reactive_labels_server("reactive_labels", filtered_feet)

bigfoots_maps <- bigfoots_maps_server("bigfoots_maps", 
                                      color_var = reactive(input$color_var),
                                      size_var = reactive(input$size_var),
                                      filtered_feet, 
                                      reactive_labels)

## contact form part of the server -----------------------------------------------
contact_form <- contact_form_server("contact")


## Missing text part of the server---------------------------------------------
# render the text displayed below graphics that tells the viewer how many
# values are missing

output$report_missing <- renderText({ report_missing })
output$time_missing <- renderText({ season_missing })
output$weekday_missing <- renderText({  weekday_missing })

}


