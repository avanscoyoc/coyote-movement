1\. Pre-process Collar Data
================
Amy Van Scoyoc
11/21/2022

# Purpose

This document is the code to format the coyote GPS data into a single
dataframe. Coyote data were downloaded from the Vectronic Inventa
website and named based on first and last date in the file. The date key
file contains the field-season, the coyote release date-times, and the
collar drop date-times.

## Load libraries

``` r
library(here) #reproducible working directory
library(tidyverse) #for data wrangling
library(lubridate) #for data/time
library(sp) #for UTM transformation
```

### Import and Combine Coyote field seasons

``` r
#data table with coyote sex, id, collar start_date, collar end_date
datekey <- read_csv(here("data","coyote_datekey.csv")) 

#season 1 data (8-weeks)
season1 <- read_csv(here("data", "coyote_2020.11.08_2021.06.30.csv")) %>% mutate(season = 1)

#season 2 data (16-weeks)
season2 <- read_csv(here("data", "coyote_2021.12.01_2022.03.04.csv")) %>% mutate(season = 2)

#combine field seasons
dat_all <- rbind(season1, season2) %>% 
  dplyr::select(x = `Longitude[deg]`, y = `Latitude[deg]`, 
                t = `Acq. Time [UTC]`, collar_id = `Collar ID`, season) %>%
  mutate(t = lubridate::with_tz(ymd_hms(t,tz="UTC"),"America/Los_Angeles")) %>% #adjust time
  drop_na(x) %>% #drop any missing locations
  left_join(., datekey, by = c("season", "collar_id")) %>% #join date table for filtering
  filter(t >= start_3d & t <= end, #filter 3-days after collaring
         ID != "M4") #remove, M4 died 5-days after release via vehicle collision
```

### Calculate GPS data metrics

There were hourly GPS locations for a total of 190 unique days (mean 60
days per individual) from November to May of 2020-2021 and 2021-2022.

``` r
#calculate number of collared coyote dates (190 unique days)
dat_all %>% 
  mutate(julian_day = yday(t)) %>% 
  group_by(season) %>% 
  distinct(julian_day) %>% 
  nrow() #count unique julian day by season
```

    ## [1] 190

``` r
#calculate mean days across individuals (mean 54 days)
dat_all %>% 
  group_by(ID) %>% 
  summarize(start = min(as.Date(t)), #first date per individual
            end = max(as.Date(t)), #last date per individual
            ndays = difftime(end, start, units = "days"), #n days per individual
            npoints = n()) %>% #number points
  summarize(n = mean(ndays)) #mean n days per individual
```

    ## # A tibble: 1 × 1
    ##   n      
    ##   <drtn> 
    ## 1 60 days

### Transform to UTMs

``` r
#transform coordinates
llcoord <- SpatialPoints(dat_all[,1:2],proj4string=CRS("+init=epsg:4326")) #transform to sp object
utmcoord <- spTransform(llcoord, CRS("+init=epsg:26910")) #transform to utms

# overwrite UTM locations to data frame
dat_all$x <- attr(utmcoord,"coords")[,1]
dat_all$y <- attr(utmcoord,"coords")[,2]
```

### Export dataset to object for later use

``` r
#arrange and convert to dataframe necessary for moveHMM prepData function
dat_all <- dat_all %>% 
  dplyr::select(ID, x, y, t) %>% #select columns
  arrange(ID, t) %>% #arrange by ID and timestamp
  data.frame() #convert to dataframe

save(dat_all, file = "data_objects/dat_all.Rdata") #save object

head(dat_all)
```

    ##   ID        x       y                   t
    ## 1 F1 493420.7 4315715 2020-11-14 18:00:18
    ## 2 F1 493458.9 4315786 2020-11-14 19:00:40
    ## 3 F1 493462.4 4315789 2020-11-14 20:00:12
    ## 4 F1 494390.8 4315900 2020-11-14 21:00:14
    ## 5 F1 494139.6 4315729 2020-11-14 22:00:39
    ## 6 F1 494096.8 4315332 2020-11-14 23:00:13
