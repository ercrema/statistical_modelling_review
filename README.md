# R scripts for the manuscript 'Statistical Modelling in Archaeology: some recent trends and future perspectives'

This repository contains data and scripts used in the manuscript:

Crema, E. R. (2025). Statistical modelling in archaeology: some recent trends and future perspectives. Journal of Archaeological Science, 180, 106295. https://doi.org/10.1016/j.jas.2025.106295

The repository contains R scripts for generating figures 1-3 in the manuscript. All data required to produce the figures are generated via simulation and described in each file. All scripts are stand-alone so that users can run the script for each figure separately. The repository contains a Dockerfile for executing all scripts in a container.

| Script                           | Output                                                     | Manuscript Figure | Approximate Runtime | Additional Notes                                                                                                                              |
|----------------------------------|------------------------------------------------------------|-------------------|---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| `table1.R`      | NA                              | Table 1          | < 1 minutes        |  -                                                                                                                                            |
| `multilevelmodel_example.R`      | `figure1_multilevelmodel.pdf`                              | Figure 1          | < 10 minutes        |  -                                                                                                                                            |
| `measurement_error_example.R`    | `figure2_measurementerror.pdf`                             | Figure 2          | < 30 minutes        |  -                                                                                                                                            |
| `generative_inference_example.R` | `figure3_frequencies.pdf` and `figure3_priorposterior.pdf` | Figure 3          | ca. 8-10 hours        | Runtime based on parallel computation over 25 core; Figure 3 was generated combining the two outputs on Inkscape (see `figure3_combined.svg`) |


## R Session Info
```
attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] progress_1.2.3     doSNOW_1.0.20      snow_0.4-4         iterators_1.0.14  
 [5] foreach_1.5.2      RColorBrewer_1.1-3 brms_2.21.0        Rcpp_1.0.12       
 [9] latex2exp_0.9.6    here_1.0.1         coda_0.19-4.1      nimbleCarbon_0.2.5
[13] nimble_1.2.1       rcarbon_1.5.1     

loaded via a namespace (and not attached):
 [1] tidyselect_1.2.1       dplyr_1.1.4            loo_2.8.0             
 [4] spatstat.geom_3.2-9    pracma_2.4.4           spatstat.explore_3.2-7
 [7] tensorA_0.36.2.1       rpart_4.1.23           estimability_1.5.1    
[10] lifecycle_1.0.4        sf_1.0-16              StanHeaders_2.32.9    
[13] spatstat.data_3.0-4    magrittr_2.0.3         posterior_1.6.0       
[16] compiler_4.4.2         rlang_1.1.4            tools_4.4.2           
[19] igraph_2.0.3           utf8_1.2.4             knitr_1.46            
[22] prettyunits_1.2.0      bridgesampling_1.1-2   curl_5.2.1            
[25] pkgbuild_1.4.4         classInt_0.4-10        abind_1.4-8           
[28] KernSmooth_2.23-26     numDeriv_2016.8-1.1    grid_4.4.2            
[31] polyclip_1.10-6        stats4_4.4.2           fansi_1.0.6           
[34] xtable_1.8-4           e1071_1.7-14           colorspace_2.1-1      
[37] inline_0.3.19          ggplot2_3.5.1          emmeans_1.10.5        
[40] scales_1.3.0           spatstat.utils_3.0-4   spatstat_3.0-8        
[43] cli_3.6.3              mvtnorm_1.3-2          crayon_1.5.2          
[46] generics_0.1.3         RcppParallel_5.1.7     DBI_1.2.2             
[49] proxy_0.4-27           rstan_2.32.6           stringr_1.5.1         
[52] splines_4.4.2          spatstat.model_3.2-11  bayesplot_1.11.1      
[55] parallel_4.4.2         matrixStats_1.4.1      vctrs_0.6.5           
[58] V8_5.0.1               Matrix_1.7-2           jsonlite_1.8.8        
[61] hms_1.1.3              tensor_1.5             units_0.8-5           
[64] goftest_1.2-3          glue_1.8.0             spatstat.random_3.2-3 
[67] codetools_0.2-19       distributional_0.5.0   stringi_1.8.4         
[70] gtable_0.3.5           QuickJSR_1.2.2         deldir_2.0-4          
[73] munsell_0.5.1          tibble_3.2.1           pillar_1.9.0          
[76] Brobdingnag_1.2-9      R6_2.5.1               rprojroot_2.0.4       
[79] lattice_0.22-5         backports_1.5.0        rstantools_2.4.0      
[82] class_7.3-23           spatstat.linnet_3.1-5  gridExtra_2.3         
[85] nlme_3.1-166           checkmate_2.3.2        spatstat.sparse_3.0-3 
[88] mgcv_1.9-1             xfun_0.44              pkgconfig_2.0.3 
```

## Licence
CC-BY 3.0


