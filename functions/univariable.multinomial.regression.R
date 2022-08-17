# Function to run and tabulate the results from multinomial logistic regression
# for categorical outcomes with either factor or linear predictors
# estimates are converted to odds ratios 

do.univariable.multinomial.regression<- function(dataframe, outcome, independent.variable) {
  
  # create the formula
  glm.formula <<- paste(set.largest.ref(outcome), paste(set.largest.ref(independent.variable), collapse=" + "), sep=" ~ ")
  dataframe <<- dataframe
  
  if (class(dataframe[[independent.variable]])[1] == "factor"){
    
    model <<- multinom(formula=glm.formula, data=dataframe,trace=FALSE)
    # create table

    df <- tidy(nnet::multinom(model))

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
  
  if (class(dataframe[[independent.variable]])[1] != "factor"){
    
    model <<- multinom(formula=glm.formula, data=dataframe,trace=FALSE)
    
    # create table
    
    df <- tidy(nnet::multinom(model))
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
