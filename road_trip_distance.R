library(dplyr)

#load city distance data
city_matrix = read.csv("city_distance.csv", stringsAsFactors=FALSE)
rownames(city_matrix) = colnames(city_matrix)[2:length(colnames(city_matrix))]

all_schedules = read.csv(paste0("schedules/allNBA_gameresults_", 
                                min(YEARS-1), "-", max(YEARS), ".csv"),
                         stringsAsFactors=FALSE)

all_schedules$Opp_Abbr = substring(all_schedules$Opp_link, 8, 10)

#initialize temp distance travelled
Dist_Travel = c()

#teams
teams = unique(paste(all_schedules$Team, all_schedules$Season))
for(each in teams){
  print(each)
  #team
  t = substring(each, 1, 3)
  #season
  s = substring(each, 5, 13)
  temp = all_schedules %>% 
    filter(Team==t, Season==s)
  for(i in 1:max(temp$G)){
    if(temp$H_A[i]=="Home"){
      Dist_Travel = c(Dist_Travel, 0)
    } else{
      start = t
      if(i>1 && temp$H_A[i-1]=="Away"){
        start = temp$Opp_Abbr[i-1]
      }
      cities = sort(c(start, temp$Opp_Abbr[i]))
      Dist_Travel = c(Dist_Travel, city_matrix[cities[1],cities[2]])
    }
  }
}

all_schedules$Dist_Travel = Dist_Travel
#cumsum of distance travelled
all_schedules = all_schedules %>% group_by(Team, Season) %>%
  mutate(Cum_Trip_Distance=ave(Dist_Travel,
                               cumsum(Dist_Travel == 0), 
                               FUN=cumsum))

write.csv(all_schedules, 
          paste0("schedules/allNBA_gameresults_", 
                 min(YEARS-1), "-", max(YEARS), ".csv"),
          row.names=FALSE)
