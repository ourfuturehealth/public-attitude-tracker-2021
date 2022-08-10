
# a funcion that plots the histogram and frequency table for a given variable


frequency_and_plot <- function(dataframe, variable){
  

  # set up plotting variables
  validn <- dataframe %>%
    filter(!is.na({{variable}})) %>%
    select({{variable}}) %>%
    count()
  
  varname <- dataframe %>%
    select({{variable}}) %>%
    colnames()
  
  varlabel <- label(dataframe[[varname]])
  

  # conditionally create frequency graph depending on whether factor or numeric
  
  if (class(dataframe[[varname]])[1] == "numeric") {
    
   
    
    plot <- ggplot(data.frame(dataframe), 
       aes(x={{variable}})) +
       geom_bar() +
      ggtitle(paste("Distribution of responses for",validn,"total valid respondents for",varname,sep=" ")) +
      labs(x=paste0("/n",varlabel)) +
      scale_x_continuous(breaks = seq(min(dataframe[[varname]]),max(dataframe[[varname]]))) +
      scale_y_continuous(breaks = seq(0,as.numeric(validn),100)) +
  theme_personal()
    
    return(plot)

}
  
  if (class(dataframe[[varname]])[1] != "numeric") {
    
    ggplot(data.frame(dataframe), 
         aes(x={{variable}})) +
      geom_bar() +
      ggtitle(paste("Distribution of responses for",validn,"total valid respondents for",varname,sep=" ")) +
      scale_y_continuous(breaks = seq(0,as.numeric(validn),100)) +
  labs(x=varlabel) +
  theme_personal()
}

   dataframe %>%
     select({{varname}}) %>%
     freq()

}