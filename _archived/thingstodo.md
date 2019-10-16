MetaGWASToolKit
============

### Things to do for future versions
Below a list of things to do for future versions. Some items have been crossed of the list. And all of these items are tracked as issues.

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

