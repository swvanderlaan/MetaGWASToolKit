#
# This script computes p-values for given z-scores 
# Usage: R CMD BATCH --args -CL -input.file -output.file meta.R
#
#

## READS input options
rm(list=ls())
#input=commandArgs()[5]
#input=substr(input,2,nchar(input))

x <- 0

repeat {
        x <- x+1
        if (commandArgs()[x] == "-CL") {
        input <- commandArgs()[x+1]; input <- substr(input, 2, nchar(input))
        output <- commandArgs()[x+2]; output <- substr(output, 2, nchar(output))
        break
        }
        if (x == length(commandArgs())) {
                print("remember the -CL command!")
                break}
        }

rm(x)


#output=commandArgs()[6]
#output=substr(output,2,nchar(output))

foo <- read.table(input, header=F)

P1 <- pnorm(-(abs(foo[,2]))) * 2;
P2 <- pnorm(-(abs(foo[,3]))) * 2;
P3 <- pnorm(-(abs(foo[,4]))) * 2;


write.table(data.frame(foo[,1], P1, P2, P3), file=output, sep=" ", quote=F, row.names=F)


