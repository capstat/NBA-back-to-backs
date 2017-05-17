library(rvest)
library(dplyr)

#all stats come from basketball-reference.com
NBA = "http://www.basketball-reference.com"
#scraping bball ref with rvest not as straight forward as you would imagine
#http://stackoverflow.com/questions/40616357/how-to-scrape-tables-inside-a-comment-tag-in-html-with-r

teams_df = read.csv("NBA_team_info.csv")
#initialize team age
teams_df$avg_age = teams_df$real_team_age = 0
for(i in 1:nrow(teams_df)){
  print(paste(i, nrow(teams_df)))
  temp_table = read_html(paste0(NBA, teams_df$link[i])) %>% 
    #must select all comment nodes first
    html_nodes(xpath = '//comment()') %>% 
    #extract the text
    html_text() %>%
    #create a single string and parse again
    paste(collapse = '') %>%    
    read_html() %>%    
    html_node('table#totals') %>%
    html_table() 
  #average age
  teams_df$avg_age[i] = mean(temp_table$Age, na.rm=TRUE)
  #use players age for each minute played 
  sum_age = sum(mapply(
    sum, mapply(
      rep, temp_table$Age, temp_table$MP)), 
    na.rm=TRUE)
  teams_df$real_team_age[i] = sum_age/max(temp_table$MP)
}
#save the df
write.csv(teams_df, "NBA_team_info.csv", row.names=FALSE) 

#t.test(teams_df$real_team_age, teams_df$avg_age)
