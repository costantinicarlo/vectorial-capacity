cycle1 <- rep(1, 16)
cycle2 <- rep(0:1, 8)
cycle3 <- c(rep(c(0,0,1), 5),0)
cycle4 <- rep(c(0,0,0,1),4)

a <- 0.025
b <- 0.7
c <- 0.15

p <- 0.65
S <- p^(1:16)

U <- a + 2 * b + 3 * c + 4 * (1 - (a + b + c))
ts <- a*S*cycle1 + b*S*cycle2 + c*S*cycle3 + (1-(a+b+c))*S*cycle4

plot(1:16, ts, type = "h", xlab = "Days", ylab = "Feeding", main = U)

obs <- c(9,61,6,23,0,4,2)
chi <- sum((obs / sum(obs) - ts[1:7] / sum(ts[1:7])) / (ts[1:7] / sum(ts[1:7])))
