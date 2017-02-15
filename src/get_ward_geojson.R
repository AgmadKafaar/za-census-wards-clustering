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
  paste('{"features": [', paste(geojson, collapse = ","), '], "type": "FeatureCollection"}')
}

# Annoyingly mapit doesn't resolve geojson for all the ward codes in the census, so we need to extract the available ward codes
wardSummaries <- GET("https://mapit.code4sa.org/areas/WD") %>% content(as = "text")
wardCodes <- str_match_all(pattern = '"MDB"\\: "(.*?)"', wardSummaries)[[1]][,2]

# GET geojson 300 wards at time so as not to produce URLs that are too long
wardGeojsonRequests <- lapply(chunk(wardCodes, 300), function(wardCodes) {
  joinedWardCodes <- paste(sprintf("MDB:%s", wardCodes), collapse = ",")
  GET(sprintf("https://mapit.code4sa.org/areas/%s.geojson", joinedWardCodes))
})

for (i in seq_along(wardGeojsonRequests)) {
  request <- wardGeojsonRequests[[i]]
  write(content(request, as = "text"), file = sprintf("data/wards-%s.geojson", i))
}

geojson <- mergeGeojson(sapply(wardGeojsonRequests, function(x) content(x, as = "text")))
