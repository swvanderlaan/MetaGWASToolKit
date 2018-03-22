MetaGWASToolKit
============

[![DOI](https://zenodo.org/badge/75635714.svg)](https://zenodo.org/badge/latestdoi/75635714)

** Preliminary release v0.9 **

**NOTE: For a meta-analysis using 1000G phase 1 everything should work. We are updating some items, so please check back. For a list of items we are working on check the bottom of this readme.**

### Introduction
A ToolKit to perform a Meta-analysis of Genome-Wide Association Studies. Can be used in conjunction with [**GWASToolKit**](https://github.com/swvanderlaan/GWASToolKit).
This repository contains a ToolKit to perform a Meta-analysis of (any number of) Genome-Wide Association Studies (**MetaGWASToolKit**) and comprises various scripts in Perl, Python, R, and BASH.

All scripts are annotated for debugging purposes - and future reference. The only scripts the user should edit are: 
- the main job submission script `metagwastoolkit.qsub.sh`, 
- `metagwastoolkit.conf`, a configuration file with some system and analytical settings, and 
- `metagwastoolkit.list` which contains a list of all the GWAS datasets.

Scripts will work within the context of a certain Linux environment (in this case a CentOS7 system on a SUN Grid Engine background). In addition to testing **MetaGWASToolKit** on CentOS7, we have tested it on OS X Sierra (version 10.11.[x]) too. 


--------------

### Installing the scripts locally

You can use the scripts locally to run analyses on a Unix-based system, like Mac OS X (Sierra+). We need to make an appropriate directory to download 'gits' to, and install this 'git'.

#### Step 1: Make a directory, and go there.

```
mkdir -p ~/git/ && cd ~/git
```

#### Step 2: Clone this git, unless it already exists.

```
if [ -d ~/git/MetaGWASToolKit/.git ]; then \
		cd ~/git/MetaGWASToolKit && git pull; \
	else \
		cd ~/git/ && git clone https://github.com/swvanderlaan/MetaGWASToolKit.git; \
	fi
```

#### Step 3: Check for dependencies of Python, Perl and R, and install them if necessary.
[text and codes forthcoming]


#### Step 4: Create necessary databases. These include:
You will have to download and create some data needed for **MetaGWASToolKit** to function. The `resource.creator.sh` script will automagically create the necessary files. For some of these files, it is necessary to supply the proper reference data in VCF-format (version 4.1+). The files created by `resource.creator.sh` include:
- DBSNPFILE    -- a dbSNP file containing information per variant based on dbSNP b147.
- REFFREQFILE  -- a file containing reference frequencies per variant for the chosen reference and population.
- VINFOFILE    -- a file needed to harmonize all the cohorts in terms of variant ID, contains various *variantID* versions (rs[XXXX], chr[X]:bp[XXX]:A1_A2, *etc.*). The resulting file is used by `gwas2ref.harmonizer.py` later on during harmonization.
- GENESFILE    -- a file containing chromosomal basepair positions per gene, default is `Gencode`.
- REFERENCEVCF -- needed for downstream analyses, such as clumping of genome-wide significant hits, etc. 

To download and install please run the following code, this should submit various jobs to create the necessary databases.

```
cd ~/git/MetaGWASToolKit && bash resource.creator.sh
```

##### Available references
There are a couple of reference available per standard, these are:
- **HapMap 2 [`HM2`], version 2, release 22, b36.**        -- HM2 contains about 2.54 million variants, but does *not* include variants on the X-chromosome. Obviously few, if any, meta-analyses of GWAS will be based on that reference, but it's good to keep. View it as a 'legacy' feature. [NOT AVAILABLE YET] :large_blue_diamond:
- **1000G phase 1, version 3 [`1Gp1`], b37.**              -- 1Gp1 contains about 38 million variants, including INDELs, and variation on the X, XY, and Y-chromosomes.
- **1000G phase 3, version 5 [`1Gp3`], b37.**              -- 1Gp3 contains about 88 million variants, including INDELs, and variation on the X, XY, and Y-chromosomes. [NOT AVAILABLE YET] :large_orange_diamond:
- **Genome of the Netherlands, version 4 [`GoNL4`], b37.** -- GoNL4 contains about xx million variants, including INDELs, and variation on the X, XY, and Y-chromosomes; some of which are unique for the Netherlands or are not present in dbSNP (yet).  [NOT AVAILABLE YET] :large_blue_diamond:
- **Genome of the Netherlands, version 5 [`GoNL5`], b37.** -- GoNL4 contains about xx million variants, including INDELs, and variation on the X, XY, and Y-chromosomes; some of which are unique for the Netherlands or are not present in dbSNP (yet).  [NOT AVAILABLE YET] :large_blue_diamond:
- **Combination of 1Gp3 and GoNL5 [`1Gp3GONL5`], b37.**    -- This contains about 100 million variants, including INDELs, and variation on the X, XY, and Y-chromosomes; some of which are unique for the Netherlands or are not present in dbSNP (yet).  [NOT AVAILABLE YET] :large_orange_diamond:

#### Step 5: Installation of necessary software
**MetaGWASToolKit** requires you to install several software packages. 
- *PLINK2* for LD-calculations; reference: https://www.cog-genomics.org/plink2. 
- *LocusZoom v1.3* for automatic regional association plotting; reference: http://genome.sph.umich.edu/wiki/LocusZoom_Standalone. 
- *VEGAS2*; for gene-based association analysis; reference: https://vegas2.qimrberghofer.edu.au. 
- *MAGMA* for gene-based association analysis, and gene-set enrichment analyses; reference: https://ctg.cncr.nl/software/magma. 


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

### Things to do for future versions
:ballot_box_with_check: *implemented*
:x: *skipped*
:construction: *working on it*
:large_orange_diamond: *next version, high priority*
:large_blue_diamond: *next version, low priority*

#### Meta-analysis 
- add in trans-ethnic meta-analysis option :large_orange_diamond:
- ~~add in option to choose reference to use~~ :ballot_box_with_check:
- ~~make Perl-script that generates the frequency file (perhaps while using gwas2harmonize?)~~ :ballot_box_with_check:
- add in automagical checking of each cohort after cleaning :construction:
- add in params-file generator (cohort-name, lambda [after QC], avg. sample size, beta-correction factor) :construction:
- add in option to include/exclude special chromosomes (X, Y, XY, MT) :large_blue_diamond:
- ~~add in more extensive annotation of variants - perhaps HaploReg; eQTL/mQTL/pQTL; ENCODE?~~ :ballot_box_with_check:
- add `--verbose` and other flags of `METAGWAS.pl` to `metagwastoolkit.conf`. :construction:
- ~~add in LocusTrack functionality~~ :ballot_box_with_check:
- ~~add in LD score functionality~~ :ballot_box_with_check:
- ~~add in MR base functionality~~ :ballot_box_with_check:
- ~~add in MAGMA functionality~~ :ballot_box_with_check:
- ~~add in VEGAS2 functionality~~ :ballot_box_with_check:
- add in VEGAS2 based pathway enrichment analysis :construction:
- ~~add in a relevant annotation function~~ :ballot_box_with_check:

#### Manhattan
- add in option to give the output a specific name (now it's based on the filename) :large_orange_diamond:
- automatically highlight a specific region (previous/novel loci) :large_blue_diamond:
- add in a gene name at the most significant peaks (previous/novel loci) :large_orange_diamond:
- add in option on test-statistics (Z-score, Chi^2, or P-value) :large_orange_diamond:
- add in option to choose for a stratified Manhattan (bottom vs. upper for instance male vs. female) :large_orange_diamond:
- add in option to make it horizontal, vertical or circular :large_blue_diamond:
- better outline chr X, XY, Y, MT :large_blue_diamond:
- add in option to change the title of the plot :large_orange_diamond:
- ~~change numbers (23, 24, 25, 26) to letters (X, XY, Y, MT) for these chromosomes~~ :ballot_box_with_check:
- ~~Fix issues with genomic control on final results~~ :ballot_box_with_check:

#### QQ-plots
- ~~add in confidence interval as option, and also an improved one~~ :x: SKIPPED
- ~~add in more options for variant-types, currently only SNV and INDEL; one might think in terms missense/nonsense/etc., or eQTL/mQTL/pQTL, or other annotation~~ :skipped:
- add in option to cut-off the maximum -log10(P), for instance everything p < 5.0e-10 is set to p = 5.0e-10; while at the same time lambdas are calculated based on the original p-values. :large_orange_diamond:

--------------

#### The MIT License (MIT)
##### Copyright (c) 2015-2018 Sander W. van der Laan | s.w.vanderlaan [at] gmail [dot] com.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:   

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Reference: http://opensource.org.

