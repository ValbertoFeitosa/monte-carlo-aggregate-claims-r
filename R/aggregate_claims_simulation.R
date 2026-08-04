# ==========================================================
# Monte Carlo Simulation of Aggregate Insurance Claims
# ==========================================================
#
# Description:
# Simulation of aggregate insurance claims under the
# Collective Risk Model using a Compound Poisson distribution.
#
# Author: Valberto Feitosa
# Language: R
#
# ==========================================================


# ==========================================================
# 1. Project Configuration
# ==========================================================

# Clear the R environment
rm(list = ls())

# Set the seed for reproducibility
set.seed(123)

# ==========================================================
# 2. Model Parameters
# ==========================================================

# Parameter of the Poisson claim frequency distribution
lambda_total <- 50

# Parameters of the Lognormal claim severity distribution
mu <- 3
sigma <- 0.5

# Number of Monte Carlo simulations
n_sim <- 10000

# ==========================================================
# 3. Theoretical Moments
# ==========================================================

# Expected value of the Lognormal claim severity
EX <- exp(mu + (sigma^2) / 2)

# Variance of the Lognormal claim severity
VarX <- (exp(sigma^2) - 1) * exp(2 * mu + sigma^2)

# Expected value of the aggregate loss
ES <- lambda_total * EX

# Variance of the aggregate loss
VarS <- lambda_total * VarX +
  (EX^2) * lambda_total

# ==========================================================
# 4. Monte Carlo Simulation
# ==========================================================

# Vectors used to store the simulation results
N_sim <- numeric(n_sim)
S_sim <- numeric(n_sim)

# Monte Carlo simulation
for (i in 1:n_sim) {
  
  # Simulate the number of claims
  N <- rpois(1, lambda = lambda_total)
  
  # Store the simulated number of claims
  N_sim[i] <- N
  
  # Calculate the aggregate loss
  if (N == 0) {
    
    S <- 0
    
  } else {
    
    # Simulate the individual claim amounts
    sinistros <- rlnorm(
      N,
      meanlog = mu,
      sdlog = sigma
    )
    
    # Calculate the aggregate claim amount
    S <- sum(sinistros)
  }
  
  # Store the aggregate loss
  S_sim[i] <- S
}

# Create a data frame with the simulation results
df <- data.frame(
  Simulacao = 1:n_sim,
  N = N_sim,
  S = S_sim
)

# Display the first simulated values
head(df)

# ==========================================================
# 5. Simulation Results
# ==========================================================

# Simulated statistics
media_simulada <- mean(df$S)
variancia_simulada <- var(df$S)
desvio_simulado <- sd(df$S)

# Display simulated results
cat("\n===== SIMULATION RESULTS =====\n")
cat("Simulated mean of S:", media_simulada, "\n")
cat("Simulated variance of S:", variancia_simulada, "\n")
cat("Simulated standard deviation of S:", desvio_simulado, "\n")

# Display theoretical results
cat("\n===== THEORETICAL RESULTS =====\n")
cat("E[X] =", EX, "\n")
cat("Var(X) =", VarX, "\n")
cat("E[S] =", ES, "\n")
cat("Var(S) =", VarS, "\n")
cat("SD(S) =", sqrt(VarS), "\n")

# ==========================================================
# 6. Histogram of the Simulated Distribution
# ==========================================================

hist(
  df$S,
  breaks = 50,
  probability = TRUE,
  main = "Simulated Distribution of Aggregate Losses",
  xlab = "Aggregate Loss S",
  ylab = "Density"
)

grid()

# ==========================================================
# 7. Normal Approximation
# ==========================================================

# Parameters of the Normal approximation
media_S <- ES
var_S <- VarS
dp_S <- sqrt(VarS)

cat("\n===== NORMAL APPROXIMATION =====\n")
cat("S ~ N(", media_S, ",", var_S, ")\n")
cat("Standard deviation =", dp_S, "\n")

# ==========================================================
# 8. Translated Gamma Approximation
# ==========================================================

# Second raw moment of the Lognormal claim severity
EX2 <- exp(2 * mu + 2 * sigma^2)

# Third raw moment of the Lognormal claim severity
EX3 <- exp(3 * mu + (9 * sigma^2) / 2)

# Parameters of the Translated Gamma approximation
alpha <- 4 * lambda_total * (EX2^3) / (EX3^2)

beta <- 2 * EX2 / EX3

x0 <- lambda_total * EX -
  2 * lambda_total * (EX2^2) / EX3

cat("\n===== TRANSLATED GAMMA APPROXIMATION =====\n")
cat("Alpha =", alpha, "\n")
cat("Beta =", beta, "\n")
cat("Shift x0 =", x0, "\n")


# ==========================================================
# 9. Distribution Comparison
# ==========================================================

# Values of S used to draw the curves
x <- seq(
  min(df$S),
  max(df$S),
  length.out = 1000
)

# Normal approximation density
dens_normal <- dnorm(
  x,
  mean = media_S,
  sd = dp_S
)

# Translated Gamma density
dens_gama <- dgamma(
  x - x0,
  shape = alpha,
  rate = beta
)

# Histogram of the simulated aggregate loss
hist(
  df$S,
  breaks = 50,
  probability = TRUE,
  col = "gray85",
  border = "white",
  main = "Comparison of Aggregate Loss Distributions",
  xlab = "Aggregate Loss S",
  ylab = "Density",
  ylim = c(
    0,
    max(dens_normal, dens_gama) * 1.20
  )
)

grid()

# Normal approximation
lines(
  x,
  dens_normal,
  col = "blue",
  lwd = 3
)

# Translated Gamma approximation
lines(
  x,
  dens_gama,
  col = "red",
  lwd = 3
)

# Theoretical mean
abline(
  v = media_S,
  col = "darkgreen",
  lwd = 2,
  lty = 2
)

# Legend
legend(
  "topleft",
  legend = c(
    "Monte Carlo Simulation",
    "Normal Approximation",
    "Translated Gamma",
    "Theoretical Mean"
  ),
  col = c(
    "gray60",
    "blue",
    "red",
    "darkgreen"
  ),
  lwd = c(8, 3, 3, 2),
  lty = c(1, 1, 1, 2),
  bg = "white",
  cex = 0.85,
  bty = "o"
)








