### Behavioral and diel partitioning of coyotes in a mixed-agricultural landscape 
(In Prep.)

## Purpose
We aim to identify the drivers of coyote resource selection by testing the relative influence of potential risks *(hunting, predation, development)* and rewards *(habitat cover, agricultural crops, livestock)* on coyote space use in a mixed-use agricultural landscape. We deployed GPS collars on coyotes (*n = 8*) in the Sanel Valley, Mendocino County, California, USA. We used hidden Markov models to estimate three types of movement behavior for coyotes: resting, meandering, and traveling. We analyzed coyote selection of environmental covariates, stratified by behavior and time of day. 

## **Authors**

Amy Van Scoyoc  
Department of Environmental Science, Policy, and Management  
University of California, Berkeley  
130 Mulford Hall, Berkeley, CA, USA 94720  
avanscoyoc@berkeley.edu 

Kendall Calhoun   
Department of Environmental Science, Policy, and Management   
University of California, Berkeley   
130 Mulford Hall, Berkeley, CA, USA 94720  
kendallcalhoun@gmail.com  

Justin S. Brashares  
Department of Environmental Science, Policy, and Management   
University of California, Berkeley   
130 Mulford Hall, Berkeley, CA, USA 94720  
brashares@berkeley.edu  

## **File Descriptions**

### *Scripts:*

* **1_prep_collar_data.Rmd**  - This file contains the code to load the collar datasets from each field season, combine the datasets, and filter the timestamps for each coyote ID to be 3-days post-release until the collar drop-date. The `coyote_datekey.csv` file is used to filter the timestamps. The output is the `dat_all.Rdata` object, formatted for the `moveHMM` package. 

* **2_prep_covariates.Rmd** - This file contains the code to reclassify and calculate environmental covariates for use in the resource selection functions (RSFs). The initial `.tif` files were obtained from the [National Land Cover Database (2016)](https://www.usgs.gov/node/279743). The `.tif` files were cropped to the study area (Sanel Valley, Mendocino County, California, USA) using Google Earth Engine before importing for reclassification here.

* **3_moveHMM.Rmd** - This file contains the code used to calculated the initial parameters and find the best-fit 3-state hidden Markov model for coyotes at our study site. The best model is stored as `best_hmm.Rdata` object. The code also decodes and asigns the states using the Viterbi algorithm on the best fit model. The output dataset with the assigned states is `hmm_dat.csv`. 

* **4_full_mod.Rmd**, **5_behavior_mod.Rmd**, **6_daynight_mod.Rmd** - These files contains the code used to estimate resource selection functions (RSFs) for all coyote data, by behavioral state, and by day-night, respectively. 

### *Data:*

Relevant data are contained in: 

* **data** - all `.csv` files and dataframes of GPS collar data

* **data_covariates** - all `.tif` files of enviromental covariates

* **data_objects** - all `.Rdata` objects for intermediate processing