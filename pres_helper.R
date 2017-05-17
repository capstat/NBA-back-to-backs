library(dplyr)
library(ggplot2)
library(ggthemes)
library(scales)

#load all the games
all = read.csv("schedules/allNBA_gameresults_1979-2017.csv")
#load the model
load("modelfile")

#find home and away win %s for each team
tttest = all %>% group_by(Team, year.) %>%
  mutate(HWpct=sum(Result.[H_A.=="Home"]=="W")/length(Result.[H_A.=="Home"]),
         AWpct=sum(Result.[H_A.=="Away" & BB.==FALSE & !is.na(BB.)]=="W")/
           length(Result.[H_A.=="Away" & H_A.=="Away" & BB.==FALSE & !is.na(BB.)]),
         BAWpct=sum(Result.[BB.==TRUE & !is.na(BB.) & H_A.=="Away"]=="W")/
           length(Result.[BB.==TRUE & !is.na(BB.)& H_A.=="Away"])) %>%
  distinct(Team, year., HWpct, AWpct, BAWpct) 

#run some ttests (H-A, A-bb) and save them
tt_HA = t.test(tttest$HWpct, tttest$AWpct)
tt_ABB = t.test(tttest$AWpct, tttest$BAWpct)
save(tt_HA, file="tt_HA")
save(tt_HA, file="tt_ABB")

#extract bb games (train and test data)
ms = c("Nov", "Dec", "Jan", "Feb", "Mar")
bbs = all[all$BB.==TRUE & all$H_A.=="Away" & 
            all$Month. %in% ms & all$G.<70 & all$G.>10,]
write.csv(bbs, "NBA_BBs.csv", row.names=FALSE)

#set up bins for cumaltive distance
bbs$cuts_cum_dist = as.numeric(
  cut_number(bbs$Cum_Trip_Distance., 7))
#check for significance
t = ifelse(bbs$Result.=="W",1,0)
x = lm(t~as.character(bbs$cuts_cum_dist))
anova(x)

#check distance each game
bbs$cuts_dist = as.numeric(
  cut_number(bbs$Dist_Travel., 7))
pd1 = data.frame(table(bbs$Result., bbs$cuts_dist))
pd1 = pd1 %>% group_by(Var2) %>%
  mutate(prop=Freq[Var1=="W"]/sum(Freq)) %>%
  filter(Var1=="W")
x = lm(t~as.character(bbs$cuts_dist))
anova(x)

#plot data
pd = data.frame(table(bbs$Result., bbs$cuts_cum_dist))
pd = pd %>% group_by(Var2) %>%
  mutate(prop=Freq[Var1=="W"]/sum(Freq)) %>%
  filter(Var1=="W")
p =ggplot(pd) + 
  geom_bar(aes(x=Var2, y=prop), fill="steelblue", stat="identity") +
  scale_y_continuous(label=percent) + 
  ggtitle("Win % vs Cumaltive Distance Travelled",
          subtitle="2nd Game of Back-to-Back on the Road") +
  xlab("Shortest to Longest Cumaltive Distance Travelled") + ylab("") + 
  theme_few() + theme(axis.text.x = element_blank())
ggsave(filename="dPlot1.jpg", plot=p)

p = ggplot(sample_n(bbs,1000)) +
  geom_point(aes(Cum_Trip_Distance./1000, Point_Diff.)) +
  theme_few() + xlab("Cumaltive Road Trip Distance (km)") +
  ylab("Point Differential") + scale_x_continuous(labels=comma) +
  ggtitle("Sample of 1,000 Games", 
          subtitle="2nd Game of Back-to-Back on the Road")
ggsave(filename="dPlot2.jpg", plot=p)

#take a look at the last day of the trip
bbs$Last_Day = ifelse(bbs$Games_Left_Trip_Stand.==0 &
                        bbs$Trip_Stand_Length_Games.>3,
                      TRUE, FALSE)
prop.table(table(bbs$Result., bbs$Last_Day))

#load the test data
test = read.csv("test.csv")
p = ggplot(test) + 
  geom_histogram(aes(x=ExpW_prop, 
                     fill=as.character(Cuts_ExpW)),
  binwidth=.075, alpha=.5, position="identity") +
  theme_few() + xlab("") +
  ylab("") + theme(legend.position="none") +
  ggtitle("Predicted Win Proportion NBA 2014-2015, 2015-2016, 2016-2017", 
          subtitle="2nd Game of Back-to-Back on the Road") 
ggsave(filename="dPlot3.jpg", plot=p)
 
#compare model with pyt difference
exp_data = test
pdP = data.frame(table(exp_data$Result., exp_data$Cuts_ExpW))
pdP$Var3 = "Model"
#cut the pyt diff
exp_data$cuts_diff = as.numeric(cut_number(exp_data$pytWpct_GB4_Diff, 5))
pdD = data.frame(table(exp_data$Result., exp_data$cuts_diff))
pdD$Var3 = "Pyt Diff"
#combine - get correct % - and plot
pd = rbind(pdP, pdD)
pd = pd %>% group_by(Var2, Var3) %>%
  mutate(prop=Freq[Var1=="W"]/sum(Freq)) %>%
  filter(Var1=="W")
p = ggplot(pd) + 
  geom_bar(aes(x=Var2, y=prop, fill=Var3),
           stat="identity", position="dodge") +
  theme_few() + xlab("") + ylab("% Right") + 
  scale_y_continuous(label=percent) +
  scale_fill_discrete(name="") +
    theme(legend.position="bottom",
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank()) +
  ggtitle("Model Results vs Pythagorean Win % Difference", 
          subtitle="2nd Game of Back-to-Back on the Road") 
ggsave(filename="dPlot4.jpg", plot=p)








 
  
  
  
  
  #XXXXXXXX

  the_model$cut_dist = as.numeric(
    cut_number(the_model$Cum_Trip_Distance., 7))
  #trim variables whose z value > 0.1
  fit3 = glm(data=the_model, 
             Result. ~ OT_GB4.+BB.Opp+OT_GB4.Opp+cut_dist+
               real_team_age.+Last10_GB4.+BB_Type.+
               real_team_age.Opp+
               Last10_GB4.Opp+
               pytWpct_GB4_Diff,
             family=binomial("logit"))
  summary(fit3, correlation=TRUE)










###NOT SURE
bbs_month = bbs %>% group_by(Month.) %>%
  mutate(prop=sum(Result.=="W")/length(Result.)) %>%
  distinct(prop) %>% filter(!is.na(prop))

bbs_y = bbs %>% group_by(year.) %>%
  mutate(prop=sum(Result.=="W")/length(Result.)) %>%
  distinct(prop) %>% filter(!is.na(prop))


mean(all$avg_age.)
mean(all$real_team_age.)

ttest(all$avg_age., all$real_team_age.)




