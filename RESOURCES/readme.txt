### README RESOURCES ###


### FOLDERS ###
# 1000Gp1v3_CEU/
Folder containing PLINK-formatted files and frequencies of 1000G phase 1, release 3 (20101123)
of the CEU population (N=170). Contains 38,248,779 variants; chromosome 1-22 and 
including X chromosome.

# 1000Gp1v3_EUR/
Folder containing PLINK-formatted files and frequencies of 1000G phase 1, release 3 (20101123)
of the EUR populations (CEU, FIN, GBR, IBS, TSI, N=379). Contains 38,248,779 variants; chromosome 
1-22 and including X chromosome.

# 1000Gp1v3_GoNL5/
Folder containing frequencies of 1000G phase 1, release 3 (20101123, EUR populations, N=758) 
combined with GoNL5 (N=499). Contains 51,349,608 variants; chromosome 1-22 and 
including X chromosome (X from 1000G).

# GoNL5/
Folder containing frequencies of GoNL5 (N=499). Contains 19,562,005 variants; chromosome 1-22 only.

# HAPMAP/
Folder containing PLINK-formatted files and frequencies of HapMap 2, release 27 of the CEU population (N=174).
Includes 3,907,239 variants; chromosome 1-22 only.

# RECOMB_RATES/
Folder containing HapMap 2, release 22 based genetic maps for hg18 (b36) and hg19 (b37). The genetic map
for the X chromosome is only available in build 37.

### dbSNP/1000G/GoNL5 variant information files ###
# dbsnp129_hg18.txt.gz
File containing per-variant strand orientation, variant type, class and functional information. See head below.
	#chrom	chromStart	chromEnd	SNP	strand	observed	class	func
	chr1	6946796	6946821	rs57898978	+	A/G	single	intron
	chr1	8912885	8912910	rs57188530	+	C/G	single	unknown
	chr1	34340790	34340885	rs6143185	+	(LARGEDELETION)/-	named	intron
	chr1	102891517	102891542	rs56752146	+	A/G	single	unknown

# dbsnp129_hg18_excl_non_ref.txt.gz
File containing per-variant strand orientation, variant type, class and functional information. Uncleaned,
contains duplicates. See head below.
	#chrom	chromStart	chromEnd	name	strand	observed	class	func
	chr1	6946796	6946821	rs57898978	+	A/G	single	intron
	chr1	8912885	8912910	rs57188530	+	C/G	single	unknown
	chr1	34340790	34340885	rs6143185	+	(LARGEDELETION)/-	named	intron
	chr1	102891517	102891542	rs56752146	+	A/G	single	unknown

# dbsnp137_hg19.txt.gz
File containing per-variant strand orientation, variant type, class and functional information. See head below.
	chrom chromStart chromEnd SNP strand observed class func
	chr10 98240381 98240382 rs243 - C/T snp intron-variant
	chr10 20992670 20992671 rs244 - C/T snp unknown
	chr10 3178914 3178915 rs541 - A/C/G snp utr-variant-3-prime,utr-variant-3-prime,utr-variant-3-prime,utr-variant-3-prime
	chr10 3178907 3178908 rs542 - A/G snp utr-variant-3-prime,utr-variant-3-prime
	chr10 3178864 3178865 rs543 + A/G snp utr-variant-3-prime,utr-variant-3-prime
	
# 1000Gp1v3_gonl5.snv_indels_sv.txt.gz
File containing per-variant strand orientation, variant type, class and functional information. 
Contains 43,476,545 variants. See head below.
	#chrom chromStart chromEnd SNP strand obs class function
	chr1 46401 46402 rs199681827 + C/CTGT indel unknown
	chr1 47189 47190 rs200430748 + G/GA indel unknown
	chr1 51913 51914 rs190452223 + T/G snp unknown
	chr1 52143 52144 rs190291950 + T/A snp unknown
	chr1 52184 52185 rs201374420 + TTAA/T indel unknown
	chr1 54352 54353 rs140052487 + C/A snp unknown
	
# gonl5.snv_indels_sv.txt.gz
File containing per-variant strand orientation, variant type, class and functional information. 
Contain 19,763,454 variants. See head below.
	chr10 60493 60494 10:60494 + A/G snp unknown
	chr10 60968 60969 10:60969 + C/A snp unknown
	chr10 61333 61334 10:61334 + G/A snp unknown
	chr10 61851 61852 10:61852 + T/C snp unknown
	chr10 62056 62057 10:62057 + G/A snp unknown
	chr10 63577 63578 10:63578 + A/G snp unknown
	chr10 64773 64774 10:64774 + C/T snp unknown
	
### dbSNP rsID update files ###
# dbsnp129_rsIDs.txt
File containing rsIDs pre-dbSNP129 which are mapped to other rsIDs in dbSNP129. To update the summary statistics
files for HapMap 2 based studies.
	SNP Build129
	rs10002216 rs1439262
	rs10002282 rs2567954
	rs10002813 rs4420991
	rs10003544 rs2956616
	rs10007155 rs1128427
	rs10008617 rs2646294
	rs10008938 rs2654751
	
# 1000Gp1r3_20101123_chrbp2variantIDs.txt
File containing chr[chr]:[bp]:[alleles] IDs mapped to corresponding 1000G (phase 1, release 3) formatted
marker/variant IDs, either dbSNP rsIDs (b137) or chr[chr]:[bp]:[D/I]. To update the summary statistics
files for 1000G phase 1, release 3 based studies.
	SNP Build129
	rs10002216 rs1439262
	rs10002282 rs2567954
	rs10002813 rs4420991
	rs10003544 rs2956616
	rs10007155 rs1128427
	rs10008617 rs2646294
	rs10008938 rs2654751

### RefSeq files ###
# hg18/b36
==> refseq_hg18.footprints.txt <==
Includes refseq genes, the so called 'footprints' which also notes the strand orientation. 
See head below.
	C9orf152 chr9 - 112001666 112010234
	ELMO2 chr20 - 44428096 44468678
	RPS11 chr19 + 54691445 54694756
	CREB3L1 chr11 + 46255803 46299548
	PNMA1 chr14 - 73248238 73250881
==> refseq_hg18.genes.short.txt <==
Includes refseq genes, but without duplicates. See head below.
	1 4224 19233 WASH5P
	1 24474 25944 FAM138A
	1 24474 25944 FAM138F
	1 24474 25944 FAM138C
	1 58953 59871 OR4F5
==> refseq_hg18.txt <==
Includes extended refseq information, including strand orientation, transcription start/end,
and exon start/end. See head below.
	#geneName	chrom	strand	txStart	txEnd	exonStarts	exonEnds
	WASH5P	chr1	-	4224	19233	4224,4832,5658,6469,6720,7095,7468,7777,8130,14600,19183,	4692,4901,5810,6628,6918,7231,7605,7924,8229,14754,19233,
	FAM138A	chr1	-	24474	25944	24474,25139,25583,	25037,25344,25944,
	FAM138F	chr1	-	24474	25944	24474,25139,25583,	25037,25344,25944,
	FAM138C	chr1	-	24474	25944	24474,25139,25583,	25037,25344,25944,

# hg19/b37
==> refseq_hg19.footprints.txt <==
Includes refseq genes, the so called 'footprints' which also notes the strand orientation. 
See head below.
	C9orf152 chr9 - 112963230 112969859
	CREB3L1 chr11 + 46299662 46342293
	RPS11 chr19 + 49999713 50002889
	ELMO2 chr20 - 44996001 45023121
	PNMA1 chr14 - 74179283 74180342
==> refseq_hg19.genes.short.extended.txt <==
Includes refseq genes, but with duplicates. See head below.
	X 99885797 99891691 TSPAN6
	X 99840015 99854711 TNMD
	20 49551671 49575060 DPM1
	20 49551671 49575060 DPM1
	20 49551671 49575060 DPM1
==> refseq_hg19.genes.short.txt <==
Includes refseq genes, but without duplicates. See head below.
	9 112963230 112969859 C9orf152
	11 46299662 46342293 CREB3L1
	19 49999713 50002889 RPS11
	20 44996001 45023121 ELMO2
	14 74179283 74180342 PNMA1

