readTable <- function(connection, tableName) {
  data.table(dbGetQuery(connection, sprintf("SELECT * FROM %s;", tableName)))
}
