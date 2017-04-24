#
# This script computes p-values for given z-scores 
# Usage: R CMD BATCH --args -CL -input.file -output.file meta.R
#
#

## READS input options
rm(list=ls())

x <- 0

repeat {
        x <- x+1
        if (commandArgs()[x] == "-CL") {
        input <- commandArgs()[x+1]; input <- substr(input, 2, nchar(input))
        lambda <- commandArgs()[x+2]; lambda <- as.numeric(substr(lambda, 2, nchar(lambda)))
	output <- commandArgs()[x+3]; output <- substr(output, 2, nchar(output))
        break
        }
        if (x == length(commandArgs())) {
                print("remember the -CL command!")
                break}
        }

rm(x)


#input=commandArgs()[5]
#input=substr(input,2,nchar(input))

#output=commandArgs()[6]
#output=substr(output,2,nchar(output))

print(lambda)

foo <- read.table(input, header=T)

SE <- foo$SE_FIXED * as.numeric(sqrt(lambda))

Z <- foo$BETA_FIXED / SE

P <- pnorm(-(abs(Z))) * 2;
 

write.table(data.frame(foo$SNP, P, SE, Z), file=output, sep=" ", quote=F, row.names=F)


