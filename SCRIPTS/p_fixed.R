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
female_loc = paste0(PROJECT_loc,
                  "CHARGE_cIMT_test/females/META/")

# load packages

library("data.table")
library("dplyr")
library("tidyverse")


# read file

female <- read.table(paste0(female_loc, "meta.filtered.txt.gz"), header = TRUE, sep = " ")


female <- female[-1,]
female <- female %>% 
  select("BETA_FIXED")

fwrite(female,
       file = paste0(female_loc, "female_BETA_filtered.txt"),
       na = "NA", sep = " ", quote = FALSE,
       row.names = FALSE, col.names = FALSE,
       showProgress = TRUE, verbose = TRUE)


#female <- female[-1,]
#female <- female %>% 
#  select("P_FIXED")

#female <- female[-1,]
#female <- female %>% 
#  select("N_EFF", "DF")

#female <- female[-1,]
#female <- female %>% 
 # select("P_FIXED", "CAF")


#female <- female[-1,]
#female <- female %>% 
 # select("CHR", "POS", "P_FIXED")

#female <- female[-1,]
#female <- female %>% 
#  select("P_FIXED", "CAF")



