## A function to create forest plots for binomial multivariable regression output

binomial.forest.plot <- function(data.in,
                                    title,
                                    colourpal,
                                    caption.text="",
                                 pointsize=2,linesize=1,errorsize=1,
                                 axistext=14,axistitle=16,legtitle=14,stripsize=16,
                                 lowlim=0.2,uplim=7,dodge=0.5,
                                 title.size=18,
                                 cap.size=14)
  
{
  
  
  p = ggplot(data.in,
             aes(x =predictor.level.tested,y = OR,
                 fill=colourpal)) +
    
    geom_point(size = pointsize,
               position = position_dodge(dodge),
               color=colourpal) +
    
    geom_hline(yintercept =1,
               linetype=2,
               size = linesize)  +
    
    xlab('Outcome level tested') +
    ylab("\nEstimate (95% Confidence Interval)")  +
    ggtitle(title) +
    
    geom_errorbar(aes(ymin = ifelse(LowerBoundOR < lowlim,lowlim,LowerBoundOR), 
                      ymax = ifelse(UpperBoundOR > uplim,uplim,UpperBoundOR)),
                  width = 1,
                  position = position_dodge(dodge),
                  size = errorsize,
                  color=colourpal)  +
    
    facet_wrap(. ~ predictor,
               strip.position="left",nrow=length(unique(data.in$predictor)), 
               scales="free_y") +
    
    # facet_grid(cols= vars(predictor),  drop = TRUE) +
    
    scale_colour_manual(values=colourpal) +
    scale_y_continuous(trans = "log10",
                       limits = c(NA,uplim),
                       breaks=seq(lowlim,uplim,0.5)) +
  
    labs(caption = caption.text) +
    theme(plot.title=element_text(face="bold",
                                  size=title.size,
                                  hjust=0.5),
          plot.caption = element_text(face="bold",
                                      size=cap.size,
                                      hjust=0),
          axis.text=element_text(face="bold",size=axistext,),
          legend.text=element_text(size=axistext,),
          legend.title=element_text(face="bold",size=legtitle,),
          legend.position = "none",
          axis.title.x=element_blank(), #element_text(size=axistitle,face="bold"),
          axis.title.y=element_blank(),
          strip.text.y = element_text(angle=180,face="bold",size=stripsize),
          panel.background = element_blank(),
          strip.background = element_rect(fill = "light grey"),
          panel.border = element_rect(colour = "grey",fill = NA)) +
    # guides(color = guide_legend(reverse = TRUE)) 
    coord_flip() 
  
  return(p)
}