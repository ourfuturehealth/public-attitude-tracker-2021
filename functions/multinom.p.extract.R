## function to get pvalues from multinomial regression using multinom
## conducts a 2 tailed Wald test on co-efgficients

multinom.p.extract <- function(x){
  z <- summary(x)$coefficients/summary(x)$standard.errors
  # 2-tailed Wald z tests to test significance of coefficients
  p <- (1 - pnorm(abs(z), 0, 1)) * 2
  p
}