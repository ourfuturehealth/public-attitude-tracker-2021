# function to relevel all factors such that largest group
# is ordered first and will serve as reference in regressions

set.largest.ref <- function(x) {
  if(!is.factor(x)) x<-factor(x)
  counts <- sort(table(x), decreasing = TRUE)
  relevel(x, ref=names(counts)[1])
}