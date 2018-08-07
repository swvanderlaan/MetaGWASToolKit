MetaGWASToolKit
============

[![DOI](https://zenodo.org/badge/75635714.svg)](https://zenodo.org/badge/latestdoi/75635714)

** Preliminary release v1.0 **

**NOTE #1: Currently, meta-analyses using 1000G phase 1 are supported. Upon request I will update to 1000G phase 3, and so on. **
**NOTE #2: I am updating some items in the coming few weeks, so please check back. For a list of items I am working on check the "Issues".**

### Introduction
A ToolKit to perform a Meta-analysis of Genome-Wide Association Studies. Can be used in conjunction with [**GWASToolKit**](https://github.com/swvanderlaan/GWASToolKit).
This repository contains a ToolKit to perform a Meta-analysis of (any number of) Genome-Wide Association Studies (**MetaGWASToolKit**) and comprises various scripts in Perl, Python, R, and BASH.

All scripts are annotated for debugging purposes - and future reference. The only scripts the user should edit are: 
- the main job submission script `metagwastoolkit.qsub.sh`, 
- `metagwastoolkit.conf`, a configuration file with some system and analytical settings, and 
- `metagwastoolkit.list` which contains a list of all the GWAS datasets.

Scripts will work within the context of a certain Linux environment (in this case a CentOS7 system on a SUN Grid Engine background). In addition to testing **MetaGWASToolKit** on CentOS7, we have tested it on OS X Sierra (version 10.11.[x]) too. 


--------------

### Meta-analysis of GWAS
**MetaGWASToolKit** will (semi-)automatically perform a meta-analysis of genome-wide association studies (GWAS). It will reformat, clean, plot, and analyze the data based on some required user-specificied configuration settings. Some relevant statistics, such as HWE, minor allele count (MAC), and coded allele frequency (CAF) will also be added to the final summarized result. The QC and reporting is based on the paper by [Winkler T.W. et al.](https://www.ncbi.nlm.nih.gov/pubmed/24762786).

The main script, which is controlled by `metagwastoolkit.qsub.sh`, `metagwastoolkit.conf`, and `metagwastoolkit.list`, is `metagwastoolkit.run.sh`. `metagwastoolkit.run.sh` will automagically chunk up data, submit jobs, and set things so that your meta-analysis will run smoothly. 
The premier step is at the 'reformatting' stage. Any weirdly formatted GWAS dataset will immediately throw errors, and effectively throwing out that particular GWAS dataset from the meta-analysis. Such errors will be reported.

#### Reformatting summary statistics GWAS data
GWAS datasets are first cut in chunks of 100,000 variants by `metagwastoolkit.run.sh`, and subsequently parse and harmonized by `gwas.parser.R` and `gwas2ref.harmonizer.py`. During *parsing* the GWAS dataset will be re-formatted to fit the downstream pipeline. In addition some variables are calculated (if not present), for instance "minor allele frequency (MAF)", and "minor allele count (MAC)". During *harmonization* the parsed dataset will be compared to a reference (see below) and certain information from the reference is obtained and added to the parsed data. `gwas.wrapper.sh` will automagically wrap up all the parsed and harmonized data into two seperate datasets, entitled `dataset.pdat` for the parsed data, and `dataset.rdat` for the harmonized data.

#### Cleaning reformatted GWAS data
After parsing and harmonization the reformatted data will be cleaned based on the settings provided in  `metagwastoolkit.conf`. Cleaning settings include:
- MAF, minimum minor allele frequency to keep variants, e.g. "0.005"
- MAC, minimum minor allele count to keep variants, e.g. "30"
- HWE, Hardy-Weinberg equilibrium p-value at which to drop variants, e.g. "1E-6"
- INFO, minimum imputation quality score to keep variants, e.g. "0.3"
- BETA, maximum effect size to allow for any variant, e.g. "10"
- SE, maximum standard error to allow for any variant, e.g. "10"

The resulting file, `dataset.cdat`, will be used for downstream plotting and analysis.

#### Plotting reformatted and cleaned GWAS data
Both the *un*cleaned and the cleaned reformatted data will be visualized: **MetaGWASToolKit** will generate various plots automagically:
- Manhattan-plot
- QQ-plot, regular with confidence interval
- QQ-plot by coded allele frequency
- QQ-plot by imputation quality
- QQ-plot by variant type
- a P-Z-plot showing the correlation between the observed p-values and the one calculated from 'beta' and the 'standard error'.
- Histograms of the 'effect size', including lines at the ±4 standard deviation, and the 'imputation quality'.

#### Perform meta-analysis
After cleaned datasets are obtained, `metagwastoolkit.run.sh` will prepare the meta-analysis by chunking up the harmonized and cleaned datasets in smaller subsets. Upon completion of the chunking, `metagwastoolkit.run.sh` will perform meta-analyses based on three models:
- random effects
- fixed effects
- Z-score based

We should note, that currently as a default, the meta-analysis is done in a `--verbose` mode, *i.e.* all relevant data of each cohort is added to the final meta-analysis output. This can be troublesome when tens or hundreds of GWAS datasets are analyzed. In the next version this behaviour can be changed by setting the appropriate flag in `metagwastoolkit.conf`. *Note: this script needs fixing.* :construction:

#### Plotting meta-analysis results
After the meta-analysis is complete for each chunk, the data is checked, and if deemed okay, it will be concatenated into one file. After concatenation of the data, various plots of each model result for visual inspection (and publication) are made.
- *QQ-plots*  -- These are both regular including the total number and lambda, as well as stratified by coded allele frequency.
- *Manhattan-plots*  -- Good old Manhattan plots. 
- *Effective Sample Size*  -- For the whole analysis the effective sample size will be calculated and plotted. *Note: this script needs fixing.* :construction:
- *SE-N-lambda*  -- Plotting the standard error accross cohorts as a function of sample size and inflation factor. Reference: [Winkler T.W. et al.](https://www.ncbi.nlm.nih.gov/pubmed/24762786). *Note: this script needs fixing.* :construction:
- *LocusZoom plots*  -- After concatenation of the meta-analysis results, these will be clumped using the appropriate reference as downloaded (see above 'Installing the scripts locally'). Based on the particular clumping settings (indicated in `metagwastoolkit.conf`) regional association plots will be generated using an installment of [LocusZoom v1.3](http://genome.sph.umich.edu/wiki/LocusZoom_Standalone). *Note: this script needs fixing.* :construction:
- *LocusTrack plots*  -- In addition to making LocusZoom plots (for which you will have to install LocusZoom) **MetaGWASToolKit** also generates files appropriate for [LocusTrack plots](https://gump.qimr.edu.au/general/gabrieC/LocusTrack/); this online tool can plot many additional informative tracks underneath the regional association plot. Reference: [Cuellar-Partida G. et al.](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4351846/).
- *Genomic control*  -- Using the results from the fixed effects model, genomic control will be applied to the meta-analysis results. These lambda-corrected results will also be plotted (Manhattan, and [stratified] QQ-plots). 

*Note: The installation of LocusZoom v1.3 is required for this function to work.*

#### Downstream analyses & annotation
##### Gene-based association study
Low power and heterogeneity can negatively impact the results of a meta-analysis of GWAS. Therefore we have implemented in **MetaGWASToolKit** two different approaches to gene-based association analyses. 
- *VEGAS2*: `A versatile gene-based association study` which will sum Z-scores accross variants mapped to a gene to derive emperical p-values for genes taking into account LD-structure. VEGAS2 will also run pathway analyses using the gene-based analysis results. Reference: ([Mishra A. et al.](http://journals.cambridge.org/abstract_S1832427414000796?) and [Liu J.Z. et al.](http://www.sciencedirect.com/science/article/pii/S0002929710003125)). :construction:
- *MAGMA*: which takes a similar approach as *VEGAS2* to derive emperical p-values. In addition MAGMA will automatically perform a set-based gene-set enrichement analysis. Reference: https://ctg.cncr.nl/software/magma and [de Leeuw C. et al.](http://journals.plos.org/ploscompbiol/article?id=10.1371%2Fjournal.pcbi.1004219).

*Note: The installation of MAGMA and VEGAS2 are required for this function to work.*

##### LD score
To examine heritability of the trait under investigation and the genetic correlation with other traits, **MetaGWASToolKit** will make the appropriate input file for [LD-Hub](http://ldsc.broadinstitute.org/ldhub/). Reference: [Zheng J. et al.](http://bioinformatics.oxfordjournals.org/content/early/2016/09/22/bioinformatics.btw613.abstract), [Bulik-Sullivan B. et al.](http://www.nature.com/ng/journal/vaop/ncurrent/full/ng.3211.html). See also [LDSC on GitHub](https://github.com/bulik/ldsc) for more information.

##### MR base
To derive causal effects **MetaGWASToolKit** will make the appropriate input file for [MR base](http://www.mrbase.org). Reference: [Hemani G. et al.](https://doi.org/10.1101/078972).

##### Annotation
FUMA was recently developed by the lab of [Danielle Posthuma](https://ctg.cncr.nl/people/danielle_posthuma), and can be used to annotate results with per-variant functional information on location, QTL, genes, etc. Reference: http://fuma.ctglab.nl.

--------------

#### The MIT License (MIT)
##### Copyright (c) 2015-2018 Sander W. van der Laan | s.w.vanderlaan [at] gmail [dot] com.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:   

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Reference: http://opensource.org.

