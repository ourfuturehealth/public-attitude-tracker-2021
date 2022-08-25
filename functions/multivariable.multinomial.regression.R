# Function to run and tabulate the results from multivariabel 
# multinomial logistic regression
# for catergorical outcomes with either factor or linear predictors
# estimates are converted to odds ratios 

do.multivariable.multinomial.regression<- function(dataframe, outcome, independent.variable.list ) {
  
  # create the formula
  glm.formula <<- paste(set.largest.ref(outcome), paste(set.largest.ref(independent.variable.list), collapse=" + "), sep=" ~ ")
  dataframe <<- dataframe
  
  print("#####")
  model <<- multinom(formula=glm.formula, data=dataframe,trace=FALSE)
  
  # create table
  df <- tidy(nnet::multinom(model))
  df$outcome <- outcome
  df$outcome.reference <- levels(dataframe[[outcome]])[1]
  
  predictor.levels <- sapply(dataframe[independent.variable.list],levels)
  predictor.largest.level <- stack(sapply(predictor.levels,"[[",1))
  predictor.largest.level <-  predictor.largest.level %>%
    rename(predictor=ind,
           predictor.reference.level = values)
  
  # add row labels for outcomes and predictors
  df <- df %>%
    rename(outcome.level.tested = y.level,
           Estimate = estimate) %>%
    mutate(predictor.level.tested = str_remove(term, paste(independent.variable.list,collapse = "|")),
           predictor=str_extract(term, paste(independent.variable.list,collapse = "|"))) %>%
    left_join(predictor.largest.level)
  
  
  # calculate upper and lower confidence intervals
  df <- df %>%
    mutate(LowerBoundEstimate = Estimate - (1.96*std.error),
           UpperBoundEstimate = Estimate + (1.96*std.error))
  
  ## convert estimate to odds ratios (for logistic regression) and flag significant values at 0.05 )
  ## riund these and p value estimates
  
  df <- df %>%
    mutate(LowerBoundOR = round(exp(LowerBoundEstimate),2),
           OR = round(exp(Estimate),2),
           UpperBoundOR = round(exp(UpperBoundEstimate),2),
           var.diag = diag(vcov(model)),
           p.value = round(p.value,3),
           OR.StdError = round(sqrt(OR^2 * var.diag),2),
           Sig = case_when(p.value <= 0.05 & p.value > 0.01 ~ "x",
                           p.value <= 0.01 & p.value > 0.005 ~ "xx",
                           p.value <= 0.005 & p.value > 0.001 ~ "xxx",
                           p.value <= 0.005 ~ "xxxx",
                           TRUE ~ ""
           ))
  
  ## rearrange data frame
  df <- df %>%
    filter(!term == "(Intercept)") %>%
    select(outcome,outcome.reference,outcome.level.tested,predictor,predictor.reference.level, predictor.level.tested,LowerBoundOR,OR, UpperBoundOR,OR.StdError,"p.value","Sig") 
  
  ## print to screen as html kable
  df %>%
    kbl(align='cccclcccccc',
        caption=paste("<b>Multinomial logistic regression of multiple variables predicting",label(dataframe[[outcome]]),"</b>",sep=" ")) %>%
    kable_styling(bootstrap_options = c("striped", "hover")) %>%
    print()
  
  ## print forest plot
  
  label.text <- dput((sapply(dataframe[independent.variable.list],label)))
  label.text.ordered <- label.text[order(names(label.text))]
  plot_caption <- paste(unlist(label.text.ordered),collapse="\n")

  print(multinomial.forest.plot(data.in=df,
                                caption.text=plot_caption,
                                title=paste(paste("Multinomial logistic regression of variables predicting",label(dataframe[[outcome]]),sep=" "),
                                            "Reference level:", df$outcome.reference[1],sep = "\n"),
        colourpal= c("#FFC62B","#011D4B")))
}