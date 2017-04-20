require(RSQLite)

getWardsInSameCluster <- function(con, wardCode) {
  results <- dbGetQuery(con, sprintf("SELECT geo_code FROM ward_clusters 
                          WHERE cluster_id in 
                          (SELECT cluster_id FROM ward_clusters WHERE geo_code = '%s')", wardCode))
  results$geo_code
}

getWardIncome <- function(con, wardCode) {
  result <- dbGetQuery(con, sprintf("SELECT employed_individual_monthly_income as bin, total FROM employedindividualmonthlyincome 
                           WHERE geo_code = '%s'", wardCode))
  result$bin <- factor(result$bin, ordered=TRUE)
  result
}