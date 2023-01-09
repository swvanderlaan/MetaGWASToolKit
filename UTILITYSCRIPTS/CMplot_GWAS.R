library(CMplot)
library(data.table)

args = commandArgs(trailingOnly = TRUE)
input = args[1]
pheno = args[2]

## Function to calculate lambda ##
lambda <- function(x) {
  x <- na.omit(x)
  z = qnorm(x / 2)
  l = round(median(z^2) / qchisq(0.5, df = 1), 3)
  return(l)
}


## Read DATASET ##
cat("Reading data now\n")
# Must contain following columns: rsid, chromosome, position, info, all_AB, all_BB, all_total, frequentist_add_pvalue
data <- fread(input, header = TRUE)
data <- cbind(data[,2:4], data[,9], data[,15:16], data[,18], data[,45])
head(data)
colnames(data)[c(1:8)] = c("rsid", "chromosome", "position", "info", "all_AB", "all_BB", "all_total", "P")
data$all_AB <- as.numeric(data$all_AB)
data$all_BB <- as.numeric(data$all_BB)
data$all_total <- as.numeric(data$all_total)

## MAF-stratified plot ##
# Calculate Coded Allele Frequency (CAF)
cat("Calulating CAF\n")
data$CAF <- ((2 * data$all_BB) + data$all_AB) / (2 * data$all_total)

# Separate the MAF-groups
cat("Separating MAF-groups\n")
data$maf1[data$CAF > 0.20 & data$CAF < 0.80] = data$P[data$CAF > 0.20 & data$CAF < 0.80]
data$maf2[(data$CAF < 0.20 & data$CAF > 0.05) | (data$CAF > 0.80 & data$CAF < 0.95)] = data$P[(data$CAF < 0.20 & data$CAF > 0.05) | (data$CAF > 0.80 & data$CAF < 0.95)]
data$maf3[(data$CAF < 0.05 & data$CAF > 0.01) | (data$CAF > 0.95 & data$CAF < 0.99)] = data$P[(data$CAF < 0.05 & data$CAF > 0.01) | (data$CAF > 0.95 & data$CAF < 0.99)]
data$maf4[data$CAF > 0.99 | data$CAF < 0.01] = data$P[data$CAF > 0.99 | data$CAF < 0.01]

# Calculate lambda per group
cat("Calculating lambda\n")
l_all <- lambda(data$P)
l1 <- lambda(data$maf1)
l2 <- lambda(data$maf2)
l3 <- lambda(data$maf3)
l4 <- lambda(data$maf4)

# Make a dataframe solely for this graph
cat("Creating the dataframe for MAF-stratified plot\n")
maf_data <- cbind(data[, 1:3], data$P, data[, 10:13])

# The column names will be the names in the legend, so we change them to somewhat more informative names
cat("Renaming the columns\n")
colnames(maf_data)[c(4:8)] = c("All", "MAF > 0.20", "0.05 < MAF < 0.20", "0.01 < MAF < 0.05", "MAF < 0.01")

# Plot the MAF-stratified plot
cat("\nOkay! Ready to plot this baby!\n")
CMplot(maf_data, plot.type = "q", multracks = TRUE, conf.int = FALSE,
       main = paste0("QQplot, lambda = ", l_all), cex = 0.3, pch =18,
       memo = paste0(pheno, ".MAF"))

cat("So, I finished the MAF-stratified plot, let's summarize:\n")
cat(paste0("Overal lambda: ", l_all, "\n"))
cat(paste0("MAF > 0.20 lambda: ", l1, "\n"))
cat(paste0("0.05 < MAF < 0.20 lambda: ", l2, "\n"))
cat(paste0("0.01 < MAF < 0.05 lambda: ", l3, "\n"))
cat(paste0("MAF < 0.01 lambda: ", l4, "\n"))

rm(maf_data)

cat("\n>--------------------------------------------------<\n")


## INFO-stratified plot ##
cat("\nContinuing with the INFO-stratified plot now, so first let's make the groups\n")
data$info1[data$info > 0.75] = data$P[data$info > 0.75]
data$info2[data$info < 0.75 & data$info > 0.5] = data$P[data$info < 0.75 & data$info > 0.5]
data$info3[data$info < 0.5 & data$info > 0.25] = data$P[data$info < 0.5 & data$info > 0.25]
data$info4[data$info < 0.25] = data$P[data$info < 0.25]

# Calculate lambda per group
cat("Calculating lambda\n")
l_all <- lambda(data$P)
l1 <- lambda(data$info1)
l2 <- lambda(data$info2)
l3 <- lambda(data$info3)
l4 <- lambda(data$info4)

# Make a dataframe solely for this graph
cat("Creating the dataframe for INFO-stratified plot\n")
info_data <- cbind(data[, 1:3], data$P, data[, 14:17])

# The column names will be the names in the legend, so we change them to somewhat more informative names
cat("Renaming the columns\n")
colnames(info_data)[c(4:8)] = c("All", "INFO > 0.75", "0.50 > INFO > 0.75", "0.25 < INFO < 0.50", "INFO < 0.25")

# Plot the INFO-stratified plot
cat("Okay! Ready to plot this baby!\n")
CMplot(info_data, plot.type = "q", multracks = TRUE, conf.int = FALSE,
       main = paste0("QQplot, lambda = ", l_all), cex = 0.3, pch =18,
       memo = paste0(pheno, ".INFO"))

cat("So, I finished the INFO-stratified plot, let's summarize:\n")
cat(paste0("Overal lambda: ", l_all, "\n"))
cat(paste0("INFO > 0.75 lambda: ", l1, "\n"))
cat(paste0("0.50 < INFO < 0.75 lambda: ", l2, "\n"))
cat(paste0("0.25 < INFO < 0.50 lambda: ", l3, "\n"))
cat(paste0("INFO < 0.25 lambda: ", l4, "\n"))

rm(info_data)

cat("\n>--------------------------------------------------<\n")

## Manhattan-plot ##
cat("\nLast, but not least, let's make the Manhattan-plots!\n")
data <- cbind(data[, 1:3], data$P)
CMplot(data[, 1:4], type = "p", plot.type = "m", LOG10 = TRUE,
       threshold = c(5e-8, 1e-5), threshold.col = c("red", "grey"),
       threshold.lty = c(1, 2), amplify = FALSE, 
       pch = 18, cex = 0.7, col = c("firebrick3", "tomato2"),
       memo = paste0(pheno))
