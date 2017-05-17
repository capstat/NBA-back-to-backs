library(rvest)
library(stringr)

#create empty vector to store links
teams = c()
#cycle through each year
for(year in YEARS){
  print(year)
  #read the html page for that year's summary
  temp_html = read_html(sprintf(
    "http://www.basketball-reference.com/leagues/NBA_%s.html", 
    year))
  #extract the links for the team stats page
  temp_teams = temp_html %>% 
    html_nodes("td a") %>% 
    html_attr("href")
  #add links to the list
  teams = c(teams,
            temp_teams[
              str_detect(temp_teams, 
                         sprintf("teams.....%s.html", year))])
}
teams_df = data.frame(
  "abbr" = substr(teams, 8, 10),
  "year" = substr(teams, 12, 15),
  "link" = teams
)
teams_df = teams_df[!duplicated(teams_df),]
#save the df
write.csv(teams_df, "NBA_team_info.csv", row.names=FALSE)