normaliseCounts <- function(wardData) {
  wardData[, WardTotal := sum(total), by = .(geo_code)]
  wardData[, Percentage := total/WardTotal]
  wardData
}

flattenValues <- function(wardData, columnName, prefix) {
  wardData[, variable := paste(prefix, gsub(" |\\-", "_", get(columnName)), sep = "_")]
  dcast(wardData, formula = geo_code ~ variable, value.var = "Percentage")
}

mergeAll <- function(x, dataFrames, by) {
  result <- x
  for (df in dataFrames) {
    result <- merge(result, df, by = by)
  }
  
  result
}

accessToInternetFlattened <- flattenValues(normaliseCounts(accessToInternet), 
                                           columnName = "access_to_internet",
                                           prefix = "internet")
ageGroupsFlattened <- flattenValues(normaliseCounts(ageGroups),
                                    columnName = "age_groups_in_5_years",
                                    prefix = "age")
monthlyIncomeFlattened <- flattenValues(normaliseCounts(employedMonthlyIncome),
                                        columnName = "employed_individual_monthly_income",
                                        prefix = "income")
languageFlattened <- flattenValues(normaliseCounts(language),
                                   columnName = "language",
                                   prefix = "language")
population[, scaledPopulation := scale(population)]
populationGroupFlattened <- flattenValues(normaliseCounts(populationGroup),
                                          columnName = "population_group",
                                          prefix = "population_group")
employmentStatusFlattened <- flattenValues(normaliseCounts(employmentStatus),
                                           columnName = "official_employment_status",
                                           prefix = "employment_status")

wards <- mergeAll(population, 
                  list(accessToInternetFlattened,
                       ageGroupsFlattened,
                       monthlyIncomeFlattened,
                       languageFlattened,
                       populationGroupFlattened,
                       employmentStatusFlattened),
                  by = "geo_code")