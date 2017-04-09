library(leaflet)
library(RColorBrewer)
library(shiny)
library(geojsonio)
library(stringr)
library(RSQLite)
library(data.table)

#geojson <- readLines("data/sample-wards.geojson")
wardShapes <- geojson_read("data/wards.geojson", what = "sp")
wardShapes$ward_code <- str_match(pattern = '"MDB"\\: "(.*?)"', 
                                  as.character(wardShapes$codes))[,2]

sqliteCon <- dbConnect(SQLite(), dbname='data/za-census.sqlite')
clusters <- data.table(dbGetQuery(sqliteCon, "SELECT * FROM ward_clusters;"))
setkey(clusters, geo_code)

wardShapes$cluster <- clusters[wardShapes$ward_code]$cluster_id

shinyServer(function(input, output) {
  # Create the map
  output$map <- renderLeaflet({
    pal <- colorFactor(topo.colors(15), 1:15)

    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = 18.42, lat = -33.92, zoom = 11) %>% 
      addPolygons(data = wardShapes, weight = 1, fillColor = ~pal(cluster))
      #addGeoJSON(geojson, weight = 1)
      #addGeoJSON(geojson, weight = 1, fillColor = xpal(geojson$features[1]$properties$cluster))
  })
  
  observe({
    #leafletProxy("map") %>% clearPopups()
    event <- input$map_shape_click
    if (is.null(event))
      return()
    
    print(str(event$ward_code))
  })
})
