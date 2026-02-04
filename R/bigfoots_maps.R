bigfoots_maps_UI <- function(id) {
  ns <- NS(id)
  tagList(
    
    column(9,
           
           
           
           ### point map --------------------------------------------------------------
           
           leafletOutput(ns("bigfoots_maps"),
                         height = "700px") %>%
             
             ### loading page bigfoot gif---------------------------------------------------
           
           withSpinner(
             id = "loading-gif",
             image.height = "650px",
             # image source needs to be checked for copyright
             image = "https://github.com/Russell-Shean/bigfoot_sightings/blob/main/www/resources/output-onlinegiftools3.gif?raw=true"
           )
           
           
    )
    
  )
}



bigfoots_maps_server <- function(id, size_var, color_var, filtered_feet, reactive_labels) {
  moduleServer(id, function(input, output, session) {
    
    
    
    ## Point map part of the server-------------------------------------------------------
    
    
    
    ### define static parts of the map --------------------------------------------
    output$bigfoots_maps <- renderLeaflet({
      #req(filtered_feet())
      
      leaflet()  %>%
        
        # This adds a counties outline
        addPolylines(data = wa_counties,
                     color = "#595959") %>%
        
        # this is the style guide recommended grey
        addProviderTiles("Esri.WorldImagery") %>%
        
        # this was the fun trees and stuff version
        # addProviderTiles(providers$Stadia.StamenTerrain)   %>%
        addMarkers( data = bigfoot_points,
                    label = ~summary,
                    popup = popup,
                    icon = BigFootIcon,
                    group = "default_feets"
        )
    })
    
    
    ### Define IF/ELSE conditions for point map markers --------------------------
    # This section observes various combinations of selections from the three
    # dropdown menus and modifies the markers on the plot in response
    
    # After going back through this and trying to document it, I'm thinking
    # that it may be easier to follow if I do separate if statements with AND
    # to show all the conditions that are being met for a particular map instead
    # of these giant if else chains... Or.... somehow make this a function....
    # eg. if(nrow( filtered_feet() ) < 1 & color_var()=="None" & size_var()=="Length of the Report")
    
    # it works! So for now I'll leave it alone, but this probably needs some reworking
    
    observe({
      
      # If the filtering criteria are too restrictive and there are no
      # sighting left in the data, return an error message with a marker
      req(
        filtered_feet(),
        reactive_labels(),
        color_var(),
        size_var()
      )
      
      if( nrow( filtered_feet() ) < 1 ){
        
        # This proxy contains the static parts of the map
        leafletProxy(session$ns("bigfoots_maps")) %>%
          
          # This clears markers and other dynamic parts of the map off
          # so that we can draw new ones
          clearMarkers() %>%
          clearGroup("default_feets") %>%
          clearPopups() %>%
          clearControls() %>%
          
          # Add popup in the middle of the state with a message
          addPopups(lat = 47.30933454298483,
                    lng = -119.85063332639612,
                    # icon = BigFootIcon,
                    popup = "<strong>No sightings found!</strong><br><img style='border-radius:15px;margin-right:100px;margin-top:10px;max-width:100%;' src='https://i.makeagif.com/media/3-22-2016/XRMuTn.gif'><br><br><span style='font-size:15px;' >Add some more filtering criteria to find some bigfeets!</span>",
                    options = popupOptions( closeButton = FALSE,
                                            closeOnClick = FALSE))
        
        
        # If none is selected as a color variable....
        
      } else if(color_var() == "None"){
        
        # If none is selected as a color variable....AND the size variable is set to "Length of Report"
        
        if(size_var() == "Length of the Report"){
          
          leafletProxy(session$ns("bigfoots_maps"), data = filtered_feet()) %>%
            
            # clear markers, popups and other dynamic parts of the map
            clearMarkers() %>%
            clearControls() %>%
            clearGroup("colors") %>%
            clearPopups() %>%
            clearGroup("legends") %>%
            clearGroup("default_size") %>%
            clearGroup("default_feets")  %>%
            
            # Add circle markers where the radius corresponds to the length of the report
            addCircleMarkers(
              radius = ~ (report_length / 500),
              stroke = FALSE,
              fillOpacity = 0.5,
              # the label is the thing that appears on hover
              label = ~summary,
              # The popup is the thing that appears on click
              popup = reactive_labels(),
              fillColor = "red",
              group = "default_size"
            )
          
          
          # If none is selected as a color variable....AND none is selected as
          # a size variable, return a bigfoot icon as the marker
        } else{
          
          leafletProxy(session$ns("bigfoots_maps"), data = filtered_feet()) %>%
            clearControls() %>%
            clearMarkers() %>%
            clearPopups() %>%
            addMarkers(
              label = ~summary,
              popup = reactive_labels(),
              icon = BigFootIcon,
              group = "default_feets"
            )
        }
        
        
        # If color variable is not "None" ....
        
        
      } else {
        
        
        
        
        # If color variable is not "None"
        # and the size variable is set to the length of report....
        
        if(size_var() == "Length of the Report"){
          
          
          # If color variable is not "None"
          # and the size variable is set to the length of report....
          # And the color variable is selected as season
          
          if( color_var() == "Season" ){
            
            # Here we define a color palete and color mapping strategy
            # specifically for the season variable
            
            pal2 <- colorFactor(
              palette = c(large_pal[1:(length(levels(bigfoot_points$season)) - 1)], "#F3F2F1"),
              domain = bigfoot_points$season
            )
            
            leafletProxy(session$ns("bigfoots_maps"), data = filtered_feet()) %>%
              clearMarkers() %>%
              clearControls() %>%
              clearPopups() %>%
              
              addCircleMarkers(
                radius = ~ (report_length / 500),
                stroke = FALSE,
                label = ~summary,
                popup = reactive_labels(),
                
                # This colors the circle to correspond to the pal2 function
                # we made above
                fillColor = ~pal2(season),
                fillOpacity = 0.5,
                group = "colors") %>%
              
              # This adds a legend that tracks to the pal2 function
              addLegend( title = "Season",
                         pal = pal2,
                         values = ~season,
                         
                         position = "bottomleft")
            
            
            # If color variable is not "None"
            # and the size variable is set to the length of report....
            # And the color variable is selected as Day of the Week
            
            
          }else if( color_var() == "Day of the Week" ){
            
            pal2 <- colorFactor(
              palette = c(large_pal[1:(length(levels(bigfoot_points$report_weekday)) - 1)], "#F3F2F1"),
              domain = bigfoot_points$report_weekday
            )
            
            leafletProxy(session$ns("bigfoots_maps"), data = filtered_feet()) %>%
              #  clearMarkers() %>%
              clearControls() %>%
              clearGroup("legends") %>%
              clearGroup("colors") %>%
              clearGroup("default_size") %>%
              clearGroup("default_feets") %>%
              clearPopups() %>%
              
              addCircleMarkers(
                radius = ~ (report_length / 500),
                stroke = FALSE,
                label = ~summary,
                popup = reactive_labels(),
                fillColor = ~pal2(report_weekday),
                fillOpacity = 0.5,
                group = "colors") %>%
              
              addLegend( title = "Day of the week",
                         pal = pal2,
                         values = ~report_weekday,
                         #   group = "legends",
                         #  className = "point-map-legend",
                         position = "bottomleft")
            
            
            # If color variable is not "None"
            # and the size variable is set to the length of report....
            # And the color variable is selected as Report Classification
            
            
          } else if ( color_var() == "Report Classification") {
            
            pal2 <- colorFactor(
              palette = c(large_pal[1:(length(levels(bigfoot_points$classification)) - 1)], "#F3F2F1"),
              domain = bigfoot_points$classification
            )
            
            leafletProxy(session$ns("bigfoots_maps"), data = filtered_feet()) %>%
              #  clearMarkers() %>%
              clearControls() %>%
              clearGroup("legends") %>%
              clearGroup("colors") %>%
              clearGroup("default_size") %>%
              clearGroup("default_feets") %>%
              clearPopups() %>%
              
              addCircleMarkers(
                radius = ~ (report_length / 500),
                stroke = FALSE,
                label = ~summary,
                popup = reactive_labels(),
                fillColor = ~pal2(classification),
                fillOpacity = 0.5,
                group = "colors") %>%
              
              addLegend( title = "Report Classification",
                         pal = pal2,
                         values = ~classification,
                         
                         position = "bottomleft")
            
            
            # If color variable is not "None"
            # and the size variable is set to the length of report....
            # And the color variable is selected as season
            
          } else{
            
            leafletProxy(session$ns("bigfoots_maps"), data = filtered_feet()) %>%
              #  clearMarkers() %>%
              clearControls() %>%
              clearGroup("legends") %>%
              clearGroup("colors") %>%
              clearGroup("default_size") %>%
              clearGroup("default_feets") %>%
              clearPopups() %>%
              
              addCircleMarkers(
                radius = ~ (report_length / 500),
                stroke = FALSE,
                label = ~summary,
                popup = reactive_labels(),
                fillColor = "red",
                fillOpacity = 0.5,
                group = "default_size")
          }
          
        } else{
          
          if( color_var() == "Season" ){
            
            pal2 <- colorFactor(
              palette = c(large_pal[1:(length(levels(bigfoot_points$season)) - 1)],"#F3F2F1"),
              domain = bigfoot_points$season
            )
            
            leafletProxy(session$ns("bigfoots_maps"), data = filtered_feet()) %>%
              clearMarkers() %>%
              clearControls() %>%
              clearPopups() %>%
              
              addCircleMarkers(
                radius = 10,
                stroke = FALSE,
                label = ~summary,
                popup = reactive_labels(),
                fillColor = ~pal2(season),
                fillOpacity = 0.5,
                group = "colors") %>%
              
              addLegend( title = "Season",
                         pal = pal2,
                         values = ~season,
                         position = "bottomleft")
            
            
          } else if( color_var() == "Day of the Week" ){
            
            pal2 <- colorFactor(
              palette = c(large_pal[1:(length(levels(bigfoot_points$report_weekday)) - 1)], "#F3F2F1"),
              domain = bigfoot_points$report_weekday
            )
            
            
            leafletProxy(session$ns("bigfoots_maps"),data = filtered_feet()) %>%
              clearMarkers() %>%
              clearControls() %>%
              clearPopups() %>%
              
              addCircleMarkers(
                radius = 10,
                stroke = FALSE,
                label = ~summary,
                popup = reactive_labels(),
                fillColor = ~pal2(report_weekday),
                fillOpacity = 0.5,
                group = "colors") %>%
              
              addLegend( title = "Day of the Week",
                         pal = pal2,
                         values = ~report_weekday,
                         position = "bottomleft")
            
            
          } else if ( color_var() == "Report Classification") {
            
            pal2 <- colorFactor(
              palette = c(large_pal[1:(length(levels(bigfoot_points$classification)) - 1)], "#F3F2F1"),
              domain = bigfoot_points$classification
            )
            
            leafletProxy(session$ns("bigfoots_maps"), data = filtered_feet()) %>%
              clearControls() %>%
              clearMarkers() %>%
              clearPopups() %>%
              
              addCircleMarkers(
                radius = 10,
                stroke = FALSE,
                label = ~summary,
                popup = reactive_labels(),
                fillColor = ~pal2(classification),
                fillOpacity = 0.5)  %>%
              
              addLegend( title = "Report Classification",
                         pal = pal2,
                         values = ~classification,
                         position = "bottomleft")
            
          } else{
            
            leafletProxy(session$ns("bigfoots_maps"), data = filtered_feet()) %>%
              clearControls() %>%
              clearMarkers() %>%
              clearPopups() %>%
              
              addCircleMarkers(
                radius = 10,
                stroke = FALSE,
                label = ~summary,
                popup = reactive_labels(),
                fillColor = "red",
                fillOpacity = 0.5,
                group = "default_size")
          }
          
        }
      }
    })
    
    

  })
}