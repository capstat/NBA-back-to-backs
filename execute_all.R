#file to execute all files

#get team links for every year since 3 pointer was introduced
YEARS = c(1980:2017)
#################
######TEST#######
#YEARS = c(2014:2015)
#################

source("get_team_info.R", local=TRUE)
#basic info for all teams that playing during years
#produces this data frame -> teams_df
print("saved here -> NBA_team_info.csv")

source("get_team_age.R", local=TRUE)
#adds team age
#produces this data frame -> teams_df
print("saved here -> NBA_team_info.csv")

source("get_game_info.R", local=TRUE)
#data frame of every game played during years
#produces this data frame -> all_schedules
print("saved here -> schedules/allNBA_gameresults_#-#.csv")

source("get_distance_info.R", local=TRUE)
#this script doesn't always run correctly
#the city distances are saved as a csv file
#matrix of distances between cities -> city_matrix
print("saved -> here city_distance.csv")

source("road_trip_distance.R", local=TRUE)
#adds the road trip distance to the data frame -> all_schedules
print("saved here -> schedules/allNBA_gameresults_#-#.csv")

source("add_opp_info.R", local=TRUE)
#adds team info and opponent team info to the data frame -> all_schedules
print("saved here -> schedules/allNBA_gameresults_#-#.csv")

source("save_the_model_data.R", local=TRUE)
#creates model data from the game results
print("saved here -> the_model.csv")

source("create_the_model.R", local=TRUE)
#creates a model from the data
print("saved here -> modelfile")

source("model_tester.R", local=TRUE)
source("pres_helper.R", local=TRUE)
