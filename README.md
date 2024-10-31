MetaGWASToolKit
============
[![DOI](https://zenodo.org/badge/75635714.svg)](https://zenodo.org/badge/latestdoi/75635714)

[![Languages](https://skillicons.dev/icons?i=bash,r,py)](https://skillicons.dev) 

> A ToolKit to perform a Meta-analysis of Genome-Wide Association Studies (GWAS). Check out the [wiki for more details](https://github.com/swvanderlaan/MetaGWASToolKit/wiki). 

**MetaGWASToolKit** is a set of scripts that executes a fully automated meta-analysis of GWAS. It is an extension of MANTEL, originally developed by Paul I.W. de Bakker, Sara L. Pulit and Jessica van Setten and for which many features were [described before](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2782358/) and later further extended upon by [Winkler T.W. _et al_](https://pubmed.ncbi.nlm.nih.gov/24762786/).  

In a first step, **MetaGWASToolKit** will automatically parse, harmonize, and clean summary statistics from individual GWAS. In a second step the user will _have_ to inspect each individual GWAS summarizing plot, including Manhattans, QQ-plots, Z-P plots, frequency plots, distribution of effect sizes, _etc_. In the third and fourth step, the meta-analysis is prepared and subsequently executed. In the fifth step, the results of the meta-analysis can be inspected, as the filtered and annnotated summary statistics and plots are created. Fixed- and random effects, as well as Z-score-based analyses are executed by default. Heterogeneity among cohorts is quantified using the _I<sup>2</sup>_ and Q-statistics. When genome-wide significant hits are present, clumping is automatically done, and regional association plots are generated. 

The necessary files for post-GWAS analyses, including those for Mendelian randomization and LD Score regression analysis through MR-base and LDHub, respectively. Currently, meta-analyses using 1000G phase 1 and 3, and HRC r1.1 as a reference are supported. Note that **MetaGWASToolKit** will accept multi-allelic variants coded as bi-allelic variants (each allele-combination written per line/row), however it will adhere to strict rules: only when a variant can be precisely match to the chosen reference will it be valid. Variants that cannot be matched will be analyzed, but flagged. In principle it is possible to make it work for legacy references too, _e.g._ HapMap2, please raise an issue for support on this.


# Future versions
Scripts to execute fine-mapping, create regional (MIAME) plots to compare trait-results and perform formal colocalization analyses, as well as [PolarMorphism](https://pubmed.ncbi.nlm.nih.gov/35758773/) will be added in future versions. 

--------------

#### The MIT License (MIT)
[Copyright (c)](copyright.md) 2015-2022 Sander W. van der Laan | s.w.vanderlaan [at] gmail [dot] com | [vanderlaanand.science](vanderlaanand.science).

