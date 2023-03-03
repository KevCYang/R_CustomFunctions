R custom functions
================
Kevin C Yang
February 09, 2023

# Essential libraries

A list of essential libraries is also necessary, so these have been
compiled, with continuous updates, to be sourced using a single script.

Note that currently, the checkpoint package is used to install and load
packages from the Microsoft R Application Network (MRAN), which stores
daily snapshots from CRAN. This approach ensures that the packages
loaded and installed have consistent versions therefore guarantees
reproducibility. However, MRAN and checkpoint will be retired as of July
2023, so an alternative route will be needed.

``` r
source("EssentialLibraries.R")
```

The list of essential libraries are:

  - Core libraries
      - tidyverse v1.2.1
  - Data access
      - olapR v1.0.0
      - RODBC v1.3.15
      - readxl v1.2.0
  - Data wrangling
      - reshape2 v1.4.3
      - lubridate v1.7.4
      - magrittr v1.5
  - Data visualization
      - ggpubr v0.2
      - RColorBrewer v1.1.2
      - viridis v0.5.1
      - flextable v0.5.0
  - Data output
      - openxlsx v4.1.0
      - knitr v1.21
  - Others
      - mailR v0.4.1

# PHRDWquery functions

A few functions have been developed for the needs to easily pull data
from the Public Health Reporting Data Warehouse (PHRDW). These functions
have been compiled into a script where sourcing the script simply loads
in the functions.

``` r
source("PHRDWquery.R")
```

## `PHRDW_getCodes()`

`PHRDW_getCodes()` retreives a list of available order and test codes
from one of the Enteric, LADW, Respiratory, or STIBBI PHRDW mart.

## `PHRDW_pullResults()`

`PHRDW_pullResults()` pulls a line list from a particular PHRDW mart.
The fields pulled by default include personal information and results.
Parameters can be defined to filter the pulled data for a particular
test code, etc.

Currently the available parameters are:

  - mart
  - collectiondate\_start = NULL
  - collectiondate\_end = NULL
  - orderdate\_start = NULL
  - orderdate\_end = NULL
  - additional\_fields = NULL
  - testcode = NULL
  - proficiency = NULL
  - testperformed = T
  - criteria = NULL

# Session Info

``` r
sessionInfo()
```

    ## R version 3.5.2 (2018-12-20)
    ## Platform: x86_64-w64-mingw32/x64 (64-bit)
    ## Running under: Windows Server 2008 R2 x64 (build 7601) Service Pack 1
    ## 
    ## Matrix products: default
    ## 
    ## locale:
    ## [1] LC_COLLATE=English_United States.1252 
    ## [2] LC_CTYPE=English_United States.1252   
    ## [3] LC_MONETARY=English_United States.1252
    ## [4] LC_NUMERIC=C                          
    ## [5] LC_TIME=English_United States.1252    
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ##  [1] openxlsx_4.1.0       flextable_0.5.0      RColorBrewer_1.1-2  
    ##  [4] ggpubr_0.2           magrittr_1.5         lubridate_1.7.4     
    ##  [7] reshape2_1.4.3       readxl_1.2.0         RODBC_1.3-15        
    ## [10] olapR_1.0.0          forcats_0.3.0        stringr_1.3.1       
    ## [13] dplyr_0.7.8          purrr_0.3.0          readr_1.3.1         
    ## [16] tidyr_0.8.2          tibble_2.0.1         ggplot2_3.1.0       
    ## [19] tidyverse_1.2.1      checkpoint_0.4.4     RevoUtilsMath_11.0.0
    ## [22] RevoUtils_11.0.2     RevoMods_11.0.1      MicrosoftML_9.4.7   
    ## [25] mrsdeploy_1.1.3      RevoScaleR_9.4.7     lattice_0.20-38     
    ## [28] rpart_4.1-13        
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Rcpp_1.0.0             assertthat_0.2.0       digest_0.6.18         
    ##  [4] foreach_1.5.1          R6_2.3.0               cellranger_1.1.0      
    ##  [7] plyr_1.8.4             backports_1.1.3        evaluate_0.12         
    ## [10] httr_1.4.0             pillar_1.3.1           gdtools_0.1.7         
    ## [13] rlang_0.3.1            uuid_0.1-2             lazyeval_0.2.1        
    ## [16] curl_3.3               data.table_1.12.0      rstudioapi_0.9.0      
    ## [19] magick_2.0             rmarkdown_1.11         munsell_0.5.0         
    ## [22] broom_0.5.1            compiler_3.5.2         modelr_0.1.2          
    ## [25] xfun_0.4               base64enc_0.1-3        pkgconfig_2.0.2       
    ## [28] htmltools_0.3.6        tidyselect_0.2.5       codetools_0.2-15      
    ## [31] CompatibilityAPI_1.1.0 crayon_1.3.4           withr_2.1.2           
    ## [34] grid_3.5.2             nlme_3.1-137           jsonlite_1.5          
    ## [37] gtable_0.2.0           scales_1.0.0           zip_1.0.0             
    ## [40] cli_1.0.1              stringi_1.2.4          bindrcpp_0.2.2        
    ## [43] xml2_1.2.0             generics_0.0.2         iterators_1.0.11      
    ## [46] tools_3.5.2            glue_1.3.0             officer_0.3.2         
    ## [49] hms_0.4.2              yaml_2.2.0             colorspace_1.4-0      
    ## [52] rvest_0.3.2            knitr_1.21             bindr_0.1.1           
    ## [55] haven_2.0.0
