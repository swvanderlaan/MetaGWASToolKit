#!/hpc/local/CentOS7/dhl_ec/software/R-3.6.3/bin/Rscript 

# SLURM settings
#SBATCH --job-name=BP_remover   # Job name
#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e.j.a.smulders-2@umcutrecht.nl     # Where to send mail
#SBATCH --nodes=1                     #run on one node	
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem-per-cpu=10G                    # Job memory request
#SBATCH --time=12:00:00               # Time limit hrs:min:sec
#SBATCH --output=bp_remove.log   # Standard output and error log

ROOT_loc = "/hpc/dhl_ec/esmulders/"
PROJECT_loc = paste0(ROOT_loc,
                     "MetaGWASToolKit/")
INPUT_loc = "/hpc/dhl_ec/svanderlaan/projects/consortia/CHARGE_cIMT_Sex/DATA/UKB/"
OUTPUT_loc = "/hpc/dhl_ec/svanderlaan/projects/consortia/CHARGE_cIMT_Sex/DATA/UKB/"

library("data.table")
library("dplyr")

#### remove BP from UKB

UKB <- read.table(paste0(INPUT_loc, "UKB_IMT_GWAS_Sex.Stratified_Female.info_0_8.forLZwebsite.txt.gz"), header = TRUE, sep="\t") #not sure about separator

UKB$N <- 22082

UKB_NO_BP <- UKB %>% select("SNP", "CHR", "BP", "ALLELE1", "ALLELE0", "A1FREQ",	"INFO",	"CHISQ_LINREG",	"P_LINREG", "BETA",	"SE",	"CHISQ_BOLT_LMM_INF",	"P_BOLT_LMM_INF", "N")

fwrite(UKB_NO_BP,
       file = paste0(OUTPUT_loc, "UKB_IMT_GWAS_Sex.Stratified_Female.info_0_8.forLZwebsite.NOGP.txt.gz"),
       na = "NA", sep = "\t", quote = FALSE,
       row.names = FALSE, col.names = TRUE,
       showProgress = TRUE, verbose = TRUE)