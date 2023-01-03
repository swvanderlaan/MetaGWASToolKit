#!/hpc/local/CentOS7/dhl_ec/software/R-3.6.3/bin/Rscript 

# SLURM settings
#SBATCH --job-name=cojo_dup   # Job name
#SBATCH --mail-type=FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e.j.a.smulders-2@umcutrecht.nl     # Where to send mail
#SBATCH --nodes=1                     #run on one node	
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem-per-cpu=10G                    # Job memory request
#SBATCH --time=12:00:00               # Time limit hrs:min:sec
#SBATCH --output=cojo_dup.log   # Standard output and error log


# set loc

ROOT_loc = "/hpc/dhl_ec/esmulders/"
PROJECT_loc = paste0(ROOT_loc,
                     "MetaGWASToolKit/")
female_loc = paste0(PROJECT_loc,
                    "CHARGE_cIMT_test/females/META/")

# load packages

library("data.table")
library("dplyr")
library("tidyverse")


# read file

cojo <- read.table(paste0(PROJECT_loc, "females_cojo_rs.ma"), header = TRUE, sep = " ")

cojo_unique <- cojo[!duplicated(cojo$SNP), ]



fwrite(cojo_unique,
       file = paste0(PROJECT_loc, "females_cojo_unique_rs.ma"),
       na = "NA", sep = " ", quote = FALSE,
       row.names = FALSE, col.names = FALSE,
       showProgress = TRUE, verbose = TRUE)




