library(tidyverse)
library(adehabitatHR)
#get file names in folder
files <- list.files("/Users/Amy/Documents/Berkeley Classes/Brashares Lab/projects/coyote-movement/data_covariates/dogs", full.names = T)

#read in all files from 'data_raw', combine into single data frame
dogs <- map_df(files, function(x) {
  data <- read_csv(x) %>% #read in file, add header
    cbind(animal_id = as.factor(str_extract(x, pattern = "[^._]+(?=[^_]*$)")))
}) %>% 
  mutate(timestamp = as.POSIXct(paste(Date,Time, format = "%Y-%m-%d %H:%M:%S"))) %>% 
  dplyr::select(animal_id, timestamp, Longitude, Latitude) %>% 
  st_as_sf(., coords = c("Longitude","Latitude"), crs = "+init=epsg:4326") %>% #create sf coordinates
  st_transform("+proj=utm +zone=10 +datum=WGS84") %>% #transform to utm
  as("Spatial")

