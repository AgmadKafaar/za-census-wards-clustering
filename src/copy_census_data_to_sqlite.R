require(RPostgreSQL)
require(RSQLite)

readFullTable <- function(connection, tableName) {
  dbGetQuery(connection, sprintf("select * from %s;", tableName))
}

readWardTable <- function(connection, tableName) {
  result <- dbGetQuery(connection, sprintf("select * from %s where geo_level = 'ward';", tableName))
  names(result) <- gsub(" ", "_", names(result)) # Wazimap favours table names with spaces.
  result
}

drv <- dbDriver("PostgreSQL")
wazimapConnection <- dbConnect(drv, dbname = "wazimap",
                               host = "localhost", port = 5432,
                               user = "wazimap", password = "wazimap")

sqliteCon <- dbConnect(SQLite(), dbname='similar-za-census-wards/data/za-census.sqlite')

wardTables <- c("accesstointernet", 
                "agegroupsin5years",
                "annualhouseholdincomeunder18",
                "employedindividualmonthlyincome",
                "language",
                "population",
                "populationgroup",
                "officialemploymentstatus")

fullTables <- c("wazimap_geography")

for (tableName in wardTables) {
  dbWriteTable(sqliteCon, 
               name = tableName, 
               value = readWardTable(wazimapConnection, tableName), 
               row.names = FALSE)
}

for (tableName in fullTables) {
  dbWriteTable(sqliteCon, 
               name = tableName, 
               value = readFullTable(wazimapConnection, tableName), 
               row.names = FALSE)
}