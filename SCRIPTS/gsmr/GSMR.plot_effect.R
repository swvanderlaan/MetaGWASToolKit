#!/hpc/local/Rocky8/dhl_ec/software/R-3.6.3/bin/Rscript --vanilla
# SLURM settings
#SBATCH --job-name=gsmr_plotter    # Job name
#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e.j.a.smulders-2@umcutrecht.nl     # Where to send mail
#SBATCH --nodes=1                     #run on one node	
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem-per-cpu=10G                    # Job memory request
#SBATCH --time=1:00:00               # Time limit hrs:min:sec
#SBATCH --output=gsmr_plotter.log   # Standard output and error log

phenotype <- Sys.getenv("PHENOTYPE")
trait <- Sys.getenv("TRAIT")
resultdir <- Sys.getenv("resultdir")
#x_label <- trait          # TRAIT corresponds to X_LABEL
#y_label <- phenotype      # PHENOTYPE corresponds to Y_LABEL
#color_index <- as.integer(Sys.getenv("COLOR"))
print(phenotype)
print(trait)
# Construct the file path using the variables
file_path1 <- sprintf("%s/gsmr/%s.out.eff_plot.gz", resultdir, trait)
source("/hpc/dhl_ec/esmulders/gsmr/gsmr_plot.r")


# Read the data
gsmr_data <- read_gsmr_data(file_path1)
gsmr_summary(gsmr_data)

file_path2 <- sprintf("%s/gsmr/%s_effect.png", resultdir, trait)

png(filename = file_path2, width = 480, height = 480)
# Plotting function
plot_gsmr_effect(gsmr_data, trait, phenotype, colors()[630])

# Close the device to save the plot
dev.off()





