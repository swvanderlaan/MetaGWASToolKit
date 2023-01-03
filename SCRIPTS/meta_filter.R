#!/hpc/local/CentOS7/dhl_ec/software/R-3.6.3/bin/Rscript 

# SLURM settings
#SBATCH --job-name=meta_filter   # Job name
#SBATCH --mail-type=FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e.j.a.smulders-2@umcutrecht.nl     # Where to send mail
#SBATCH --nodes=1                     #run on one node	
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem-per-cpu=10G                    # Job memory request
#SBATCH --time=12:00:00               # Time limit hrs:min:sec
#SBATCH --output=meta_filter.log   # Standard output and error log

# set loc

ROOT_loc = "/hpc/dhl_ec/esmulders/"
PROJECT_loc = paste0(ROOT_loc,
                     "MetaGWASToolKit/")
FILE_loc = paste0(PROJECT_loc,
                    "CHARGE_cIMT_test/females/META/")

# load packages

library("data.table")
library("dplyr")


# create tab file

female_data <- read.table(paste0(FILE_loc, "meta.results.CHARGE_cIMT.1Gp3.EUR.txt.gz"), header = TRUE, sep = "")

female_data <- female_data[order(female_data$CHR, female_data$POS),] 

female_filtered <- subset(female_data, female_data$DF >= 4 & female_data$CAF >= 0.05) 



fwrite(female_filtered,
       file = paste0(FILE_loc, "meta.filtered.txt"),
       na = "NA", sep = " ", quote = FALSE,
       row.names = FALSE, col.names = TRUE,
       showProgress = TRUE, verbose = TRUE)
