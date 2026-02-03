

county_sightings_map_UI <- function(id) {
  ns <- NS(id)
  tagList(
    conditionalPanel(
      condition = "input.map_or_table_button == 'Map View'",
      leafletOutput(ns("county_sightings_map"))
      
    )
  )
}




county_sightings_map_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    

    output$county_sightings_map <- renderLeaflet({
  # notice the {} inside the parenthesis?
  # that's what tell R to dynamically update the variable
  # without it you'll just render a static map
  
  
  
  # this is fairly straightforward leaflet calls
  # it's how the commands would look if you we're making a leaflet within Rstudio
  
  #this is the shapefile we made in the preprocesing step
  # it's got county shapes with sightings count data
  wa_counties %>%
    
    #pipes the shape files into a leaflet map
    # more info about leaflet:  https://rstudio.github.io/leaflet/
    
    leaflet() %>%
    
    # this adds the county shape files onto the map
    addPolygons(
      # this tells leaflet to make a cloropleth based
      # on sightings count values, the palette and breaks
      # were defined in pre-processing steps
      fillColor = ~pal(sightings_count),
      
      # this is an internal id that will be useful for getting
      # mouse hover and click data back to the server
      layerId = wa_counties$JURISDICT_LABEL_NM,
      
      #line border thickness
      weight = 2,
      
      # transperency of the border lines
      opacity = 1,
      
      # border lines color
      color = "#595959",
      
      # make the border lines dashed with size three dashes
      dashArray = "1",
      
      # transparency of the shape
      fillOpacity = 0.7,
      
      # What happens when the mouse is over a shape:
      highlightOptions = highlightOptions(
        weight = 5,
        fillColor = "green",
        color = "#666",
        dashArray = "",
        fillOpacity = 0.7,
        bringToFront = TRUE),
      
      # this is the label the map uses
      # we defined the label pattern in the pre-processing steps
      # note: labels are not dynamically rendered through shiny
      # each county's label's asociated html is pre-defined in a column
      # in the sf dataframe
      
      label = map_labels,
      
      # this defines the css for the label
      labelOptions = labelOptions(
        style = list("font-weight" = "normal",
                     padding = "3px 8px",
                     "margin-left" = "auto",
                     "margin-right" = "auto"),
        textsize = "15px",
        direction = "auto"))%>%
    
    # This adds something fun to the map, bonus points for whoever find it!
    addMarkers(lat = 5.890866683908991 ,
               lng = 148.41355743126306,
               icon = BigFootIcon,
               popup = '<strong>Shiny!</strong><br><img src= "https://media.tenor.com/HUMNK0H3OB0AAAAC/tamatoa-as-a-diversion.gif" width = 300><br>') %>%
    
    # This sets the background tile (base map)
    # available options: https://leaflet-extras.github.io/leaflet-providers/preview/
    
    addProviderTiles("Esri.WorldGrayCanvas") %>%
    
    # this defines the legend
    addLegend(pal = pal,
              
              values = ~sightings_count,
              opacity = 0.7,
              title = NULL,
              position = "bottomright",
              
              
              # This is a function that changes the label title
              # see: https://stackoverflow.com/questions/47410833/how-to-customize-legend-labels-in-r-leaflet
              
              labFormat = function(type, cuts, p) {  # Here's the trick
                paste0(legend_labels)
              })%>%
    setView(-120.161, 47.2, zoom = 6)
  
})  # end of first reactive element output } is very important!

    
  })
}
