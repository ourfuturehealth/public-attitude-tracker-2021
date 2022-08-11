# Function to create a formula for regressions and set this as a global variable
# Assesses what type of regression to do based on outcome characteristics
# binary = binary logistic
# categorical = multinomial
# continuous = linear

do.univariable.regression<- function(dataframe, outcome, independent.variable) {
  
  # create the formula
  glm.formula <- paste(set.largest.ref(outcome), paste(set.largest.ref(independent.variable), collapse=" + "), sep=" ~ ")

  
  if (class(dataframe[[outcome]])[1] == "factor" & length(levels(dataframe[[outcome]])) == 2 & class(dataframe[[independent.variable]])[1] == "factor"){

    model <- glm(glm.formula, data = dataframe, family="binomial"(link="logit"))
    

    # create table
    df <- as.data.frame(coef(summary(model)),row.names = F)
    df$outcome <- outcome
    df$outcome.reference <- levels(dataframe[[outcome]])[1]
    df$predictor <- independent.variable
    df$predictor.reference <- levels(dataframe[[independent.variable]])[1]
    
    # add row labels for outcomes
    df$level.tested <- str_remove(row.names(coef(summary(model))),independent.variable)
    
    # calculate upper and lower confidence intervals
    df <- df %>%
      mutate(LowerBoundEstimate = Estimate - (1.96*`Std. Error`),
             UpperBoundEstimate = Estimate + (1.96*`Std. Error`))
    
    ## convert estimate to odds ratios (for logistic regression) and flag significant values at 0.05 )
    ## riund these and p value estimates
    
    df <- df %>%
      mutate(LowerBoundOR = round(exp(LowerBoundEstimate),2),
             OR = round(exp(Estimate),2),
             UpperBoundOR = round(exp(UpperBoundEstimate),2),
             var.diag = diag(vcov(model)),
             `Pr(>|z|)` = round(`Pr(>|z|)`,3),
             OR.StdError = round(sqrt(OR^2 * var.diag),2),
             Sig = case_when(`Pr(>|z|)` <= 0.05 & `Pr(>|z|)` > 0.01 ~ "x",
                             `Pr(>|z|)` <= 0.01 & `Pr(>|z|)` > 0.005 ~ "xx",
                             `Pr(>|z|)` <= 0.005 & `Pr(>|z|)` > 0.001 ~ "xxx",
                             `Pr(>|z|)` <= 0.005 ~ "xxxx",
                             TRUE ~ ""
             ))

    ## rearrange data frame
    df <- df %>%
      select(outcome,outcome.reference,predictor, predictor.reference,level.tested,LowerBoundOR,OR, UpperBoundOR,OR.StdError,"z value","Pr(>|z|)","Sig") 

    ## print to screen as html kable
    df %>%
      kbl(align='cccclcccccc',
          caption=paste("<b>Binomial logistic regression of",label(dataframe[[independent.variable]]),"predicting",label(dataframe[[outcome]]),"</b>",sep=" ")) %>%
      kable_styling(bootstrap_options = c("striped", "hover")) %>%
      print()

  }
  
  if (class(dataframe[[outcome]])[1] == "factor" & length(levels(dataframe[[outcome]])) == 2 & class(dataframe[[independent.variable]])[1] != "factor"){
    
    model <- glm(glm.formula, data = dataframe, family="binomial"(link="logit"))
    
    
    # create table
    df <- as.data.frame(coef(summary(model)),row.names = F)
    df$outcome <- outcome
    df$outcome.reference <- levels(dataframe[[outcome]])[1]
    df$predictor <- independent.variable
    
    # add row labels for outcomes
    df$level.tested <- str_remove(row.names(coef(summary(model))),independent.variable)
    
    # calculate upper and lower confidence intervals
    df <- df %>%
      mutate(LowerBoundEstimate = Estimate - (1.96*`Std. Error`),
             UpperBoundEstimate = Estimate + (1.96*`Std. Error`))
    
    ## convert estimate to odds ratios (for logistic regression) and flag significant values at 0.05 )
    ## riund these and p value estimates
    
    df <- df %>%
      mutate(LowerBoundOR = round(exp(LowerBoundEstimate),2),
             OR = round(exp(Estimate),2),
             UpperBoundOR = round(exp(UpperBoundEstimate),2),
             var.diag = diag(vcov(model)),
             `Pr(>|z|)` = round(`Pr(>|z|)`,3),
             OR.StdError = round(sqrt(OR^2 * var.diag),2),
             Sig = case_when(`Pr(>|z|)` <= 0.05 & `Pr(>|z|)` > 0.01 ~ "x",
                             `Pr(>|z|)` <= 0.01 & `Pr(>|z|)` > 0.005 ~ "xx",
                             `Pr(>|z|)` <= 0.005 & `Pr(>|z|)` > 0.001 ~ "xxx",
                             `Pr(>|z|)` <= 0.005 ~ "xxxx",
                             TRUE ~ ""
             ))
    
    ## rearrange data frame
    df <- df %>%
      select(outcome,outcome.reference,predictor, level.tested,LowerBoundOR,OR, UpperBoundOR,OR.StdError,"z value","Pr(>|z|)","Sig") 
    
    ## print to screen as html kable
    df %>%
      kbl(align='cccclcccccc',
          caption=paste("<b>Binomial logistic regression of",label(dataframe[[independent.variable]]),"predicting",label(dataframe[[outcome]]),"</b>",sep=" ")) %>%
      kable_styling(bootstrap_options = c("striped", "hover")) %>%
      print()
    
  }
  
  if (class(dataframe[[outcome]])[1] == "factor" & length(levels(dataframe[[outcome]])) > 2 & class(dataframe[[independent.variable]])[1] == "factor"){
    
    model <- multinom(formula=glm.formula, data=dataframe)

    # create table
    df <- tidy(model)
    df$outcome <- outcome
    df$outcome.reference <- levels(dataframe[[outcome]])[1]
    df$predictor <- independent.variable
    df$predictor.reference <- levels(dataframe[[independent.variable]])[1]

    # add row labels for outcomes and predictors
    df <- df %>%
      rename(outcome.level.tested = y.level,
             Estimate = estimate) %>%
    mutate(predictor.level.tested = str_remove(term, independent.variable))
    
    
    # calculate upper and lower confidence intervals
    df <- df %>%
      mutate(LowerBoundEstimate = Estimate - (1.96*std.error ),
             UpperBoundEstimate = Estimate + (1.96*std.error ))
    
    ## convert estimate to odds ratios (for logistic regression) and flag significant values at 0.05 )
    ## round these and p value estimates
    
    df <- df %>%
      mutate(LowerBoundOR = round(exp(LowerBoundEstimate),2),
             OR = round(exp(Estimate),2),
             UpperBoundOR = round(exp(UpperBoundEstimate),2),
             Sig = case_when(p.value <= 0.05 & p.value > 0.01 ~ "x",
                             p.value <= 0.01 & p.value > 0.005 ~ "xx",
                             p.value <= 0.005 & p.value > 0.001 ~ "xxx",
                             p.value <= 0.005 ~ "xxxx",
                             TRUE ~ ""
             ))
    
    ## rearrange data frame
    df <- df %>%
      filter(!predictor.level.tested == "(Intercept)") %>%
      select(outcome,outcome.reference,predictor, predictor.reference,outcome.level.tested, predictor.level.tested, LowerBoundOR,OR, UpperBoundOR,std.error,p.value,Sig) 
    
    ## print to screen as html kable
    df %>%
      kbl(align='cccclcccccc',
          caption=paste("<b>Multinomial regression of",label(dataframe[[independent.variable]]),"predicting",label(dataframe[[outcome]]),"</b>",sep=" ")) %>%
      kable_styling(bootstrap_options = c("striped", "hover")) %>%
      print()
    
  }
  
  if (class(dataframe[[outcome]])[1] == "factor" & length(levels(dataframe[[outcome]])) > 2 & class(dataframe[[independent.variable]])[1] != "factor"){
    
    model <- multinom(paste(outcome, "~", independent.variable,sep=" "), data = dataframe)
    
    # create table
    
    df <- tidy(model)
    df$outcome <- outcome
    df$outcome.reference <- levels(dataframe[[outcome]])[1]
    df$predictor <- independent.variable

   
    # add row labels for outcomes and predictors
    df <- df %>%
      rename(outcome.level.tested = y.level,
             predictor.level.tested = term,
             Estimate = estimate)

    
    # calculate upper and lower confidence intervals
    df <- df %>%
      mutate(LowerBoundEstimate = Estimate - (1.96*std.error ),
             UpperBoundEstimate = Estimate + (1.96*std.error ))
    
    ## convert estimate to odds ratios (for logistic regression) and flag significant values at 0.05 )
    ## round these and p value estimates
    
    df <- df %>%
      mutate(LowerBoundOR = round(exp(LowerBoundEstimate),2),
             OR = round(exp(Estimate),2),
             UpperBoundOR = round(exp(UpperBoundEstimate),2),
             Sig = case_when(p.value <= 0.05 & p.value > 0.01 ~ "x",
                             p.value <= 0.01 & p.value > 0.005 ~ "xx",
                             p.value <= 0.005 & p.value > 0.001 ~ "xxx",
                             p.value <= 0.005 ~ "xxxx",
                             TRUE ~ ""
             ),
             predictor = predictor.level.tested)
    
    ## rearrange data frame
    df <- df %>%
      filter(!predictor == "(Intercept)") %>%
      select(outcome,outcome.reference,predictor, outcome.level.tested, predictor, LowerBoundOR,OR, UpperBoundOR,std.error,p.value,Sig) 
    
    ## print to screen as html kable
    df %>%
      kbl(align='cccclcccccc',
          caption=paste("<b>Multinomial regression of",label(dataframe[[independent.variable]]),"predicting",label(dataframe[[outcome]]),"</b>",sep=" ")) %>%
      kable_styling(bootstrap_options = c("striped", "hover")) %>%
      print()
    
  }
}

