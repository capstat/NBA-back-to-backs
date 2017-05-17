the_model = read.csv("the_model.csv")

#check for significant relationships with the categorical variables
cvs = c("Day.", "Month.","BB_Type.","year.",
        "Result_GB4.","OT_GB4.","BB.Opp",
        "Result_GB4.Opp","OT_GB4.Opp")
cvs_keep = c()
for(each in cvs){
  chi2 = chisq.test(the_model$Result., the_model[,each])$p.value
  if(chi2 < 0.1) cvs_keep=c(cvs_keep, each)
}
cvs_keep

#check relationships with the numeric variables
temp.Result. = ifelse(the_model$Result.=="W",1,0)
nvs = c("G.","Trip_Stand_Length_Games.",
        "Days_On_Road.","Games_Left_Trip_Stand.",
        "Dist_Travel.","Cum_Trip_Distance.",
        "real_team_age.","Point_Diff_GB4.",
        "Last10_GB4.","A_pytWpct_GB4.","Days_Off.Opp",
        "Trip_Stand_Length_Games.Opp",
        "Games_Left_Trip_Stand.Opp",
        "real_team_age.Opp","Point_Diff_GB4.Opp",
        "Last10_GB4.Opp","H_pytWpct_GB4.Opp",
        "pytWpct_GB4_Diff")
nvs_keep = c()
for(each in nvs){
  t = summary(lm(temp.Result. ~ 
                   the_model[,each]))$coefficients[2,4]
  if(t < 0.1) nvs_keep=c(nvs_keep, each)
}
nvs_keep

#odd double check cumaltive distance
plot(the_model$Result., the_model$Cum_Trip_Distance.)

vs = c(cvs_keep, nvs_keep)

#use a generalized linear model
#logit fit 
fit1 = glm(data=the_model,
           paste("Result. ~ ", paste0(vs, collapse="+")),
           family=binomial("logit"))
summary(fit1)

#trim variables whose z value > 0.1
fit2 = glm(data=the_model, 
           Result. ~ OT_GB4.+BB.Opp+OT_GB4.Opp+
             real_team_age.+Last10_GB4.+
             A_pytWpct_GB4.+real_team_age.Opp+
             Last10_GB4.Opp+H_pytWpct_GB4.Opp+
             pytWpct_GB4_Diff,
           family=binomial("logit"))
summary(fit2)

#trim variables whose z value > 0.1
fit3 = glm(data=the_model, 
           Result. ~ OT_GB4.+BB.Opp+OT_GB4.Opp+
             real_team_age.+Last10_GB4.+
             real_team_age.Opp+
             Last10_GB4.Opp+
             pytWpct_GB4_Diff,
           family=binomial("logit"))
summary(fit3, correlation=TRUE)

save(file="modelfile", fit3)