#!/hpc/local/CentOS7/dhl_ec/software/R-3.6.3/bin/Rscript 

# SLURM settings
#SBATCH --job-name=meta_tab   # Job name
#SBATCH --mail-type=FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e.j.a.smulders-2@umcutrecht.nl     # Where to send mail
#SBATCH --nodes=1                     #run on one node	
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem-per-cpu=10G                    # Job memory request
#SBATCH --time=12:00:00               # Time limit hrs:min:sec
#SBATCH --output=meta_tab.log   # Standard output and error log

# set loc

ROOT_loc = "/hpc/dhl_ec/esmulders/"
PROJECT_loc = paste0(ROOT_loc,
                     "MetaGWASToolKit/")
FEMALE_loc = paste0(PROJECT_loc,
                  "CHARGE_cIMT_test/females/META/")

# load packages

library("data.table")
library("dplyr")


# create tab file

female_summary <- read.table(paste0(FEMALE_loc, "female.meta.filtered.txt.gz"), header = TRUE, sep = "")

female_summary <- female_summary[order(female_summary$CHR, female_summary$POS),] 


fwrite(female_summary,
       file = paste0(FEMALE_loc, "female.tabfilt.txt.gz"),
       na = "NA", sep = "\t", quote = FALSE,
       row.names = FALSE, col.names = TRUE,
       showProgress = TRUE, verbose = TRUE)

