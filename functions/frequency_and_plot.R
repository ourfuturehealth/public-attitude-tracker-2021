
# a funcion that plots the histogram and frequency table for a given variable


frequency_and_plot <- function(dataframe, variable){
  
  # set up plotting variables
  validn <- dataframe %>%
    filter(!is.na({{variable}})) %>%
    select({{variable}}) %>%
    count()
  
  
  varlabel <- label(dataframe[[variable]])
  

  # conditionally create frequency graph depending on whether factor or numeric
  
  if (class(dataframe[[variable]])[1] == "numeric") {
    
    print(ggplot(dataframe), 
       aes_string(x=variable) +
       geom_bar() +
      ggtitle(paste("Distribution of responses for",validn,"total valid respondents for",variable,sep=" ")) +
      labs(x=paste0("/n",varlabel)) +
      scale_x_continuous(breaks = seq(min(dataframe[[variable]]),max(dataframe[[variable]]))) +
      scale_y_continuous(breaks = seq(0,as.numeric(validn),100)) +
  theme_personal())
    
}
  
  if (class(dataframe[[variable]])[1] != "numeric") {
    
    print(ggplot(data.frame(dataframe), 
         aes_string(x=variable)) +
      geom_bar() +
      ggtitle(paste("Distribution of responses for",validn,"total valid respondents for",variable,sep=" ")) +
      scale_y_continuous(breaks = seq(0,as.numeric(validn),100)) +
  labs(x=varlabel) +
  theme_personal())
}

   show(dataframe %>%
     select(variable) %>%
     freq())

}

