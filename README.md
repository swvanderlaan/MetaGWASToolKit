MetaGWASToolKit
============
A ToolKit to perform a Meta-analysis of Genome-Wide Association Studies.
This repository contains a ToolKit to perform a Meta-analysis of Genome-Wide Association Studies (MetaGWASToolKit): various scripts in Perl, BASH, and Python scripts to use in meta-analysis of GWAS of any number of cohorts.

Scripts will work within the context of a certain Linux environment (in this case a CentOS7 system on a SUN Grid Engine background). 

All scripts are annotated for debugging purposes - and future reference. The only script the user should edit is the `run_analysis.sh` script, and depending on the analyses to be run, some text-files.

The installation procedure is quite straightforward, and only entails two steps consisting of command one-liners that are *easy* to read. You can copy/paste each example command, per block of code. For some steps you need administrator privileges. Follow the steps in consecutive order.

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

We have tested MetaGWASToolKit on CentOS7, and OS X Sierra (version 10.11.[x]). 


--------------

#### Installing the scripts locally

You can use the scripts locally to run analyses on a Unix-based system, like Mac OS X (Sierra+). We need to make an appropriate directory to download 'gits' to, and install this 'git'.

##### Step 1: make a directory, and go there.

```
mkdir -p ~/git/ && cd ~/git
```

##### Step 2: clone this git, unless it already exists.

```
if [ -d ~/git/MetaGWASToolKit/.git ]; then \
		cd ~/git/MetaGWASToolKit && git pull; \
	else \
		cd ~/git/ && git clone https://github.com/swvanderlaan/MetaGWASToolKit.git; \
	fi
```


--------------

#### Meta-analysis of GWAS
This ToolKit will (semi-)automatically perform a meta-analysis of GWAS. It will reformat, clean, plot, and analyze the data based on some required user-specificied configuration settings. Some relevant statistics, such as HWE, minor allele count (MAC), and coded allele frequency (CAF) will also be added to the final summarized result. The QC and reporting is based on the paper by [Winkler T.W. et al.](https://www.ncbi.nlm.nih.gov/pubmed/24762786).

##### Reformatting summary statistics GWAS data
[Some text here]

##### Plotting reformatted GWAS data
[Some text here]

##### Cleaning reformatted GWAS data
[Some text here]

##### Plotting cleaned GWAS data
[Some text here]

##### Perform meta-analysis
[Some text here]
- random effects model
- fixed effects model
- Z-score based model

##### Plotting meta-analysis results
[Some text here]
- QQ plots
- Manhattan
- LocusZoom
- Effective Sample Size
- SE-N lambda

--------------

#### TO DO

- [some text here]

--------------

#### The MIT License (MIT)
####Copyright (c) 2015-2016 Sander W. van der Laan | s.w.vanderlaan-2 [at] umcutrecht.nl

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:   

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Reference: http://opensource.org.
