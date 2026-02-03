server <- function(input, output, session) {
  gpx_file <- gpx_upload_server("gpx_upload")
  activity_tracks <- tracks_server("tracks_process", gpx_file)
  activity_track_points <- track_points_server("track_points_process", gpx_file)
  activity_header_server("activity_header", activity_tracks, activity_track_points)
  summary_map_server("summary_map", activity_tracks)
  stats_table_server("stats_table", activity_tracks, activity_track_points)
  elevation_plot_server("elevation_plot", gpx_file)
  aknowledgements_server("aknowledgements", gpx_file)
  
  
}

# Page 1 -----------------------------------------------------------------------
county_sightings_map <- county_sightings_map_server("county_sightings_map")
county_sightings_table <- county_sightings_table_server("county_sightings_table")
sighting_counts_plot_server("sighting_counts_plot")
missing_counties_note <- missing_counties_note_server("missing_counties_note")
report_class_plot <- report_class_plot_server("report_class_plot")


season_table <- season_table_server("season_table")
weekday_plot <- weekday_plot_server("weekday_plot")

sighting_counts_plot_toolTip <- sighting_counts_plot_toolTip_server("sighting_counts_plot_toolTip")
report_class_plot_toolTip <- report_class_plot_toolTip_server("report_class_plot_toolTip")
weekday_plot_toolTip <- weekday_plot_toolTip_server("weekday_plot_toolTip")



# Page 2 -----------------------------------------------------------------------