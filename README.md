MetaGWASToolKit
============

**NOTE: these scripts and the readme are under heavy development, check back frequently.**

### Introduction
A ToolKit to perform a Meta-analysis of Genome-Wide Association Studies. Can be used in conjunction with [**GWASToolKit**](https://github.com/swvanderlaan/GWASToolKit).
This repository contains a ToolKit to perform a Meta-analysis of Genome-Wide Association Studies (**MetaGWASToolKit**): various scripts in Perl, BASH, and Python scripts to use in meta-analysis of GWAS of any number of cohorts.

Scripts will work within the context of a certain Linux environment (in this case a CentOS7 system on a SUN Grid Engine background). 

All scripts are annotated for debugging purposes - and future reference. The only script the user should edit is the `metagwastoolkit.qsub.sh` script, and two text-files: `metagwastoolkit.conf` (a configuration file with some system and analytical settings), and `metagwastoolkit.list` (containing a list of all the GWAS datasets).

The installation procedure is quite straightforward, and only entails four steps consisting of command one-liners that are *easy* to read. You can copy/paste each example command, per block of code. For some steps you need administrator privileges. Follow the steps in consecutive order.

```
these `mono-type font` illustrate commands illustrate terminal commands. You can copy & paste these.
```

To make it easier to copy and paste, long commands that stretch over multiple lines are structered as follows:

```
Multiline commands end with a dash \
	indent 4 spaces, and continue on the next line. \
	Copy & paste these whole blocks of code.
```

Although we made it easy to just select, copy and paste and run these blocks of code, it is not a good practise to blindly copy and paste commands. Try to be aware about what you are doing. And never, never run `sudo` commands without a good reason to do so. 

We have tested **MetaGWASToolKit** on CentOS7, and OS X Sierra (version 10.11.[x]). 


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
- DBSNPFILE     -- a dbSNP/Reference file containing information per variant.
- REFFREQFILE   -- a file containing reference frequencies per variant.
- GENESFILE     -- a file containing chromosomal basepair positions per gene.

[text and codes forthcoming]


--------------

### Meta-analysis of GWAS
**MetaGWASToolKit** will (semi-)automatically perform a meta-analysis of GWAS. It will reformat, clean, plot, and analyze the data based on some required user-specificied configuration settings. Some relevant statistics, such as HWE, minor allele count (MAC), and coded allele frequency (CAF) will also be added to the final summarized result. The QC and reporting is based on the paper by [Winkler T.W. et al.](https://www.ncbi.nlm.nih.gov/pubmed/24762786).

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
[Some text here]
- random effects model
- fixed effects model
- Z-score based model

#### Plotting meta-analysis results
[Some text here]
- QQ plots
- Manhattan
- LocusZoom
- Effective Sample Size
- SE-N lambda

#### References and other datasebases
##### Creating references
One can create the reference from VCF-files (version 4.1+) using `parseVCF.pl`, and in fact doing so is an option in the `metagwastoolkit.qsub.sh`. This script will automagically create various *variantID* versions, and add in information per variant. The resulting file is used by `gwas2ref.harmonizer.py` for harmonization. 
[more text and codes forthcoming]

##### Available references
There are a couple of reference available per standard, these are:
- **HapMap 2 [`HM2`], version 2, release 22, b36.**        -- HM2 contains about 2.54 million variants, but does *not* include variants on the X-chromosome. Obviously few, if any, meta-analyses of GWAS will be based on that reference, but it's good to keep. View it as a 'legacy' feature.
- **1000G phase 1, version 3 [`1Gp1`], b37.**              -- 1Gp1 contains about 38 million variants, including INDELs, and variation on the X, XY, and Y-chromosomes.
- **1000G phase 3, version 5 [`1Gp3`], b37.**              -- 1Gp3 contains about 88 million variants, including INDELs, and variation on the X, XY, and Y-chromosomes.
- **Genome of the Netherlands, version 4 [`GoNL4`], b37.** -- GoNL4 contains about xx million variants, including INDELs, and variation on the X, XY, and Y-chromosomes; some of which are unique for the Netherlands or are not present in dbSNP (yet).
- **Genome of the Netherlands, version 5 [`GoNL5`], b37.** -- GoNL4 contains about xx million variants, including INDELs, and variation on the X, XY, and Y-chromosomes; some of which are unique for the Netherlands or are not present in dbSNP (yet).
- **Combination of 1Gp3 and GoNL5 [`1Gp3GONL5`], b37.**    -- This contains about 100 million variants, including INDELs, and variation on the X, XY, and Y-chromosomes; some of which are unique for the Netherlands or are not present in dbSNP (yet).

#### Something
[Some text here]

--------------

### Things to do
#### Manhattan
- add in option to give the output a specific name (now it's based on the filename)
- highlight a specific region (previous/novel loci)
- add in a gene name at the most significant peaks (previous/novel loci)
- add in option on test-statistics (Z-score, Chi^2, or P-value)
- add in option to choose for a stratified Manhattan (bottom vs. upper for instance male vs. female)
- add in option to make it horizontal, vertical or circular
- better outline chr X, XY, Y, MT
- add in option to change the title of the plot
- ~~change numbers (23, 24, 25, 26) to letters (X, XY, Y, MT) for these chromosomes~~ :ballot_box_with_check:

#### QQ-plots
- add in confidence interval as option, and also an improved one
- add in more options for variant-types, currently only SNV and INDEL; one might think in terms missense/nonsense/etc., or eQTL/mQTL/pQTL, or other annotation
- add in option to cut-off the maximum -log10(P), for instance everything p < 5.0e-10 is set to p = 5.0e-10; while at the same time lambdas are calculate based on the original p-values.

#### Meta-analysis 
- add in trans-ethnic meta-analysis option
- ~~add in option to choose reference to use~~ :ballot_box_with_check:
- ~~make Perl-script that generates the frequency file (perhaps while using gwas2harmonize?)~~ :ballot_box_with_check:
- add in params-file generator (cohort-name, lambda [after QC], avg. sample size, beta-correction factor)
- add in option to include/exclude special chromosomes (X, Y, XY, MT)
- add in more extensive annotation of variants - perhaps HaploReg; eQTL/mQTL/pQTL; ENCODE?

#### Something
- [some text here]

--------------

#### The MIT License (MIT)
##### Copyright (c) 2015-2017 Sander W. van der Laan | s.w.vanderlaan-2 [at] umcutrecht.nl

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:   

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Reference: http://opensource.org.

