2\. Pre-process Environmental Covariates
================
Amy Van Scoyoc
11/21/2022

# Purpose

This section contains the code to reclassify environmental covariates
for use in the resource selection functions (RSFs). The initial `.tif`
files were obtained from the sources listed. The layers were cropped to
the study area (Sanel Valley, Mendocino County, California, USA) using
Google Earth Engine before importing for reclassification here.

## Load Libraries

``` r
library(here) #for setting working directory reproducibly
library(tidyverse) #data tidying
library(sf) #modifying spatial attributes 
library(raster) #reclassify environmental covariates
library(tmap) #raster plots
```

This function reclassifies the layers, converts to a distance raster (if
desired), and writes to file

``` r
mat_rec <- function(layer, reclass_vec, distance=F, filename){
  
  mat <- matrix(reclass_vec, ncol = 3, byrow = TRUE) #create matrix
  rec <- reclassify(layer, mat) #reclassify values 

  if(distance==T){
    rec <- gridDistance(rec, origin = 1) #make into distance raster if desired
  }
  
  if(missing(filename)) { #don't write to file if missing
    rec #return layer
  } else { #otherwise write to file if specified
        writeRaster(rec, filename = here("data_covariates", filename), 
                    format = "GTiff", overwrite = T) 
        rec #return layer
    }
}
```

### Land Cover

*_Source:_*

``` r
#import landcover layer
lc <- raster(here("data_covariates", "HREC_landcover_extended.tif"))

#reclassify to developed (0), cultivated (1), and natural (2)
lc_vec <- c(0, 20, NA,  # water set to NA 
            20, 21, 1,  # developed open space set cultivated as 1s
            21, 30, 0,  # developed / hardscape set to 0s
            30, 31, NA, # barren set to NA
            31, 80, 2,  # natural habitats set to 2s 
            80, 89, 1,  # cultivated space set to 1s
            89, Inf, NA)# wetlands set to NA 

lc_reclass <- mat_rec(lc, lc_vec, filename = "HREC_landcover_reclass.tif") #reclassify 
```

### Roads

*_Source:_*

``` r
#import roads layer
road <- raster(here("data_covariates", "HREC_roads_extended.tif"))

#reclassify to roads and NAs
road_vec <- c(-1, 50, NA, # non-road set to NA 
              50, Inf, 1) # all roads set to 1 

road_reclass <- mat_rec(road, road_vec, T, filename = "HREC_roads_reclass.tif") #reclassify 
```

    ## Loading required namespace: igraph

### Water

*_Source:_*

``` r
#import water layer
water <- raster(here("data_covariates", "HREC_water_extended.tif"))

#reclassify to water and NAs
water_vec <- c(-1, 0, NA, #non-water set to NA 
                0, Inf, 1) #all water set to 1 

water_reclass <- mat_rec(water, water_vec, T, filename = "HREC_water_reclass.tif") #reclassify 
```

### Human Footprint

*_Source:_* (2015)

``` r
#import dog point layer
hf <- raster(here("data_covariates", "HREC_humanfootprint_extended.tif"))

#create distance surface (meters)
hf_dist <- gridDistance(hf, origin = 255)

#write to file
writeRaster(hf_dist, filename = here("data_covariates", "HREC_hf_dist.tif"), 
            format = "GTiff", overwrite = T)
```

## Reclassified Layers

![](prep_covariates_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->