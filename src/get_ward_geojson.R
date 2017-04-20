require(stringr)
require(httr)

chunk <- function(x, chunkSize) {
  split(x, cut(seq_along(x), 
               seq(from = 0, to = length(x) + chunkSize, by = chunkSize), 
               labels=FALSE))
}

mergeGeojson <- function(geojson) {
  features <- gsub('(^\\{"features"\\: \\[)|(\\], "type"\\: "FeatureCollection"\\}$)', # 
                   ' ',
                   geojson)
  paste('{"features": [', paste(features, collapse = ","), '], "type": "FeatureCollection"}')
}

# Annoyingly mapit doesn't resolve geojson for all the ward codes in the census, so we need to extract the available ward codes
wardSummaries <- GET("https://mapit.code4sa.org/areas/WD") %>% content(as = "text")
wardCodes <- str_match_all(pattern = '"MDB"\\: "(.*?)"', wardSummaries)[[1]][,2]

sqliteCon <- dbConnect(SQLite(), dbname='similar-za-census-wards/data/za-census.sqlite')
geographies <- geographies <- data.table(dbGetQuery(sqliteCon, "SELECT * FROM wazimap_geography"))
metros <- geographies[geo_level == "municipality" & parent_level == "province"]
metroWards <- geographies[parent_code %in% metros$geo_code]

metroWardCodes <- intersect(wardCodes, metroWards$geo_code)

# GET geojson 300 wards at time so as not to produce URLs that are too long
wardGeojsonRequests <- lapply(chunk(metroWardCodes, 300), function(wardCodes) {
  joinedWardCodes <- paste(sprintf("MDB:%s", wardCodes), collapse = ",")
  GET(sprintf("https://mapit.code4sa.org/areas/%s.geojson?generation=1", joinedWardCodes))
})

for (i in seq_along(wardGeojsonRequests)) {
  request <- wardGeojsonx <- Requests[[i]]
  write(content(request, as = "text"), file = sprintf("data/wards-%s.geojson", i))
}

geojson <- mergeGeojson(sapply(wardGeojsonRequests, function(x) content(x, as = "text")))
write(geojson, file = "similar-za-census-wards/data/wards.geojson")
