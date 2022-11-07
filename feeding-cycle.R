f <- function(x) {
  
  cycle1 <- rep(1, 16)
  cycle2 <- rep(0:1, 8)
  cycle3 <- c(rep(c(0,0,1), 5) ,0)
  cycle4 <- rep(c(0,0,0,1), 4)
  
  a <- x[1]
  b <- x[2]
  c <- x[3]
  d <- 1 - (a+b+c)
  p <- x[4]
  S <- p^(1:16)
  
  ts <- a*S*cycle1 + b*S*cycle2 + c*S*cycle3 + d*S*cycle4
  
  obs <- c(9,61,6,23,0,4,2)
  sum(
    (obs / sum(obs) - ts[1:7] / sum(ts[1:7]))^2 / (ts[1:7] / sum(ts[1:7]))
    )
  
}
g <- function(x) {
  
  cycle1 <- rep(1, 16)
  cycle2 <- rep(0:1, 8)
  cycle3 <- c(rep(c(0,0,1), 5),0)
  cycle4 <- rep(c(0,0,0,1),4)
  
  a <- x[1]
  b <- x[2]
  c <- x[3]
  d <- 1 - (a+b+c)
  p <- x[4]
  S <- p^(1:16)
  
  U <- a + 2 * b + 3 * c + 4 * (1 - (a + b + c))
  ts <- a*S*cycle1 + b*S*cycle2 + c*S*cycle3 + (1-(a+b+c))*S*cycle4
  
  plot(1:16, ts, type = "h", xlab = "Days", ylab = "Feeding", main = paste("U =", round(U, 2)))
  
}

par <- c(0.1, 0.8, 0.1, 0.6)
out <- optim(par, f, method = "L-BFGS-B", lower = 0, upper = 1)
g(out$par)