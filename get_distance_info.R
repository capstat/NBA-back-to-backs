library(stringr)
library(gmapsdistance)

nba_cities = read.csv("nba_team_cities.csv", stringsAsFactors=FALSE)
#replace white space with + for all cities
nba_cities$city = str_replace_all(nba_cities$city, " ", "+")

#create a matrix
city_matrix = matrix(0, nrow(nba_cities), nrow(nba_cities))
colnames(city_matrix) = sort(nba_cities$abbreviation)
rownames(city_matrix) = sort(nba_cities$abbreviation)

#input team abbreviations
#substitutes city names and returns driving distance in meters
get_distance = function(origin, destination){
  o = nba_cities[nba_cities$abbreviation==origin,c("city")]
  d = nba_cities[nba_cities$abbreviation==destination,c("city")]
  gmapsdistance(o, d, mode="driving")$Distance
}

#cycle through matrix and find distance between cities
for(c in 1:length(colnames(city_matrix))){
  for(r in c:length(rownames(city_matrix))){
    print(paste(c,r))
    if(city_matrix[c,r] == 0){
      city_matrix[c,r] = get_distance(colnames(city_matrix)[c],
                                      rownames(city_matrix)[r])
    }
  }
}

write.csv(city_matrix, "city_distance.csv")
