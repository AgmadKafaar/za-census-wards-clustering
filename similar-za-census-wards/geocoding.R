library(httr)
library(jsonlite)

getWard <- function(lon, lat) {
  response <- GET(sprintf("http://mapit.code4sa.org/point/4326/%s,%s?type=WD&generation=1", lon, lat)) %>% content(as = "text")
  jsonResponse <- fromJSON(response)[[1]]
  list(geocode = jsonResponse$codes$MDB, name = jsonResponse$name)
}

getGeojsonForWards <- function(wardCodes) {
  joinedWardCodes <- paste(sprintf("MDB:%s", wardCodes), collapse = ",")
  GET(sprintf("http://mapit.code4sa.org/areas/%s.geojson?generation=1", joinedWardCodes)) %>% content(as = "text")
}