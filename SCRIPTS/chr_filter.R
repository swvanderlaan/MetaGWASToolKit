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
MALE_loc = paste0(PROJECT_loc,
                  "CHARGE_cIMT_test/males/META/")

# load packages

library("data.table")
library("dplyr")
library("tidyverse")


# create tab file

male <- read.table(paste0(MALE_loc, "male.meta.filtered.txt.gz"), header = TRUE, sep = "")


chr <- male %>% 
  filter(CHR==7)


fwrite(chr,
       file = paste0(MALE_loc, "male_chr7.txt"),
       na = "NA", sep = "\t", quote = FALSE,
       row.names = FALSE, col.names = TRUE,
       showProgress = TRUE, verbose = TRUE)