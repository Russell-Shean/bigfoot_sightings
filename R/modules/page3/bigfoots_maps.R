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
  
    
    ## 1️⃣ Render static map
    output$bigfoots_maps <- renderLeaflet({
      leaflet() %>%
        addPolylines(data = wa_counties, color = "#595959") %>%
        addProviderTiles("Esri.WorldImagery") %>%
        addMarkers(
          data = bigfoot_points,
          label = ~summary,
          popup = popup,
          icon = BigFootIcon,
          group = "default_feets"
        )
    })
    
    ## 2️⃣ Helper functions
    clear_map <- function(map_proxy) {
      map_proxy %>%
        clearMarkers() %>%
        clearControls() %>%
        clearPopups() %>%
        clearGroup("colors") %>%
        clearGroup("default_size") %>%
        clearGroup("default_feets") %>%
        clearGroup("legends")
    }
    
    get_palette <- function(var_name) {
      switch(var_name,
             "Season" = colorFactor(
               palette = c(large_pal[1:(length(levels(bigfoot_points$season)) - 1)], "#F3F2F1"),
               domain = bigfoot_points$season
             ),
             "Day of the Week" = colorFactor(
               palette = c(large_pal[1:(length(levels(bigfoot_points$report_weekday)) - 1)], "#F3F2F1"),
               domain = bigfoot_points$report_weekday
             ),
             "Report Classification" = colorFactor(
               palette = c(large_pal[1:(length(levels(bigfoot_points$classification)) - 1)], "#F3F2F1"),
               domain = bigfoot_points$classification
             ),
             NULL
      )
    }
    
    add_circle_markers <- function(map_proxy, data, radius, fillColor, group = "default_size") {
      map_proxy %>%
        addCircleMarkers(
          data = data,
          radius = radius,
          stroke = FALSE,
          fillOpacity = 0.5,
          label = ~summary,
          popup = reactive_labels(),
          fillColor = fillColor,
          group = group
        )
    }
    
    ## 3️⃣ Observe changes and update map
observe({
  req(filtered_feet(), reactive_labels(), color_var(), size_var())
  map <- leafletProxy(session$ns("bigfoots_maps"))

  # Determine if we should show "no sightings"
  no_data <-  nrow(filtered_feet()) < 1 || is.null(filtered_feet())
  

  if (no_data) {
    map %>%
      clearMarkers() %>%
      clearControls() %>%
      clearPopups() %>%
      clearGroup("colors") %>%
      clearGroup("default_size") %>%
      clearGroup("default_feets") %>%
      clearGroup("legends") %>%
      addPopups(
        lat = 47.3093, lng = -119.8506,
        popup = "<strong>No sightings found!</strong><br><img style='border-radius:15px;margin-top:10px;max-width:100%;' src='https://i.makeagif.com/media/3-22-2016/XRMuTn.gif'><br><br><span style='font-size:15px;'>Add some more filtering criteria to find some bigfeets!</span>",
        options = popupOptions(closeButton = FALSE, closeOnClick = FALSE)
      )
    return()  # Stop here, don't add any markers
  }

  # --- Normal data case ---
  radius <- if (size_var() == "Length of the Report") filtered_feet()$report_length / 500 else 10

  pal <- switch(color_var(),
                "Season" = colorFactor(palette = large_pal[1:length(levels(bigfoot_points$season))], domain = bigfoot_points$season),
                "Day of the Week" = colorFactor(palette = large_pal[1:length(levels(bigfoot_points$report_weekday))], domain = bigfoot_points$report_weekday),
                "Report Classification" = colorFactor(palette = large_pal[1:length(levels(bigfoot_points$classification))], domain = bigfoot_points$classification),
                NULL)

  map %>%
    clearMarkers() %>%
    clearControls() %>%
    clearPopups() %>%
    clearGroup("colors") %>%
    clearGroup("default_size") %>%
    clearGroup("default_feets") %>%
    clearGroup("legends")

  if (is.null(pal)) {
    if (size_var() == "Length of the Report") {
      map %>%
        addCircleMarkers(
          data = filtered_feet(),
          radius = radius,
          stroke = FALSE,
          fillOpacity = 0.5,
          label = ~summary,
          popup = reactive_labels(),
          fillColor = "red",
          group = "default_size"
        )
    } else {
      map %>%
        addMarkers(
          data = filtered_feet(),
          label = ~summary,
          popup = reactive_labels(),
          icon = BigFootIcon,
          group = "default_feets"
        )
    }
  } else {
    fillCol <- switch(color_var(),
                      "Season" = ~pal(season),
                      "Day of the Week" = ~pal(report_weekday),
                      "Report Classification" = ~pal(classification))
    map %>%
      addCircleMarkers(
        data = filtered_feet(),
        radius = radius,
        stroke = FALSE,
        fillOpacity = 0.5,
        label = ~summary,
        popup = reactive_labels(),
        fillColor = fillCol,
        group = "colors"
      ) %>%
      addLegend(
        title = color_var(),
        pal = pal,
        values = filtered_feet()[[tolower(gsub(" ", "_", color_var()))]],
        position = "bottomleft"
      )
  }
})

    
  })
}
