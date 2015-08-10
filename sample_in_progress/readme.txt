##############################################################################
## This a readme file for mock data randomly sampled from the original data ##
## 									    ##
## version 1								    ##
## 								            ##
## 08/10/2015						    		    ##
##									    ##
##############################################################################

Data sample:
 - drug_response:	10 cell lines x 5 compounds
 - rnaseq_expression:	10 cell lines x 100 genes
 - exome_variants:	10 cell lines x 10% of filtered variants
 - cnv: todo

raw.zip tree:

`-- [ 32K]  raw
    |-- [ 32K]  drug_response
    |   |-- [2.5K]  s-tum-LineA_1-x1-1.csv
    |   |-- [2.4K]  s-tum-LineB_2-x1-1.csv
    |   |-- [2.4K]  s-tum-LineC_3-x1-1.csv
    |   |-- [2.5K]  s-tum-LineD_4-x1-1.csv
    |   |-- [2.5K]  s-tum-LineE_5-x1-1.csv
    |   |-- [2.5K]  s-tum-LineF_6-x1-1.csv
    |   |-- [2.5K]  s-tum-LineG_7-x1-1.csv
    |   |-- [2.5K]  s-tum-LineH_8-x1-1.csv
    |   |-- [2.5K]  s-tum-LineI_9-x1-1.csv
    |   `-- [2.5K]  s-tum-LineJ_10-x1-1.csv
    |-- [ 32K]  exome_variants
    |   |-- [7.6K]  LineA_1_exome_variants.txt
    |   |-- [6.2K]  LineB_2_exome_variants.txt
    |   |-- [ 12K]  LineC_3_exome_variants.txt
    |   |-- [ 11K]  LineD_4_exome_variants.txt
    |   |-- [5.4K]  LineE_5_exome_variants.txt
    |   |-- [8.8K]  LineF_6_exome_variants.txt
    |   |-- [7.3K]  LineG_7_exome_variants.txt
    |   |-- [9.9K]  LineH_8_exome_variants.txt
    |   |-- [8.5K]  LineI_9_exome_variants.txt
    |   `-- [7.0K]  LineJ_10_exome_variants.txt
    |-- [ 32K]  metadata
    |   |-- [ 406]  sample_ids_drug_response.csv
    |   |-- [ 512]  sample_ids_exome_variants.csv
    |   `-- [ 366]  sample_ids_rnaseq_expression.csv
    `-- [ 32K]  rnaseq_expression
        |-- [1.8K]  LineA_1_counts.csv
        |-- [1.9K]  LineB_2_counts.csv
        |-- [1.8K]  LineC_3_counts.csv
        |-- [1.8K]  LineD_4_counts.csv
        |-- [1.9K]  LineE_5_counts.csv
        |-- [1.8K]  LineF_6_counts.csv
        |-- [1.8K]  LineG_7_counts.csv
        |-- [1.8K]  LineH_8_counts.csv
        |-- [1.8K]  LineI_9_counts.csv
        `-- [1.9K]  LineJ_10_counts.csv

5 directories, 34 files
