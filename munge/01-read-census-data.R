require(data.table)
require(RSQLite)
# Example preprocessing script.

# "accesstointernet", 
# "agegroupsin5years",
# "annualhouseholdincomeunder18",
# "employedindividualmonthlyincome",
# "language",
# "population",
# "populationgroup",
# "officialemploymentstatus"

sqliteCon <- dbConnect(SQLite(), dbname='similar-za-census-wards/data/za-census.sqlite')

accessToInternet <- readTable(sqliteCon, "accesstointernet")
ageGroups <- readTable(sqliteCon, "agegroupsin5years")
employedMonthlyIncome <- readTable(sqliteCon, "employedindividualmonthlyincome")
language <- readTable(sqliteCon, "language")
population <- readTable(sqliteCon, "population")
populationGroup <- readTable(sqliteCon, "populationgroup")
employmentStatus <- readTable(sqliteCon, "officialemploymentstatus")