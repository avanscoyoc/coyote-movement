## Coyote home ranges
library(tidyverse)
library(sf)
library(adehabitatHR)

# #import 2021-2022 data
season1 <- read_csv("/Users/Amy/Documents/Berkeley Classes/Brashares Lab/projects/coyote-movement/data/coyote_2020.11.08_2021.06.30.csv") %>%
  dplyr::select(x = `Longitude[deg]`, y = `Latitude[deg]`, 
                t = `Acq. Time [UTC]`, ID = `Collar ID`) %>%
  mutate(t = lubridate::with_tz(ymd_hms(t,tz="UTC"),"America/Los_Angeles")) %>% 
  drop_na(x) %>% #remove any empty locations
  nest(-ID) %>% arrange(ID) %>% 
  mutate(ID = c("C4","C3","C1","C2"), 
         sex = c("m","m","f","f"))

#import 2021-2022 data
season2 <- read_csv("/Users/Amy/Documents/Berkeley Classes/Brashares Lab/projects/coyote-movement/data/coyote_2021.12.01_2022.03.04.csv") %>% 
  dplyr::select(x = `Longitude[deg]`, y = `Latitude[deg]`, 
                t = `Acq. Time [UTC]`, ID = `Collar ID`) %>% 
  mutate(t = lubridate::with_tz(ymd_hms(t,tz="UTC"),"America/Los_Angeles")) %>% 
  drop_na(x) %>% #remove any empty locations
  nest(-ID) %>% arrange(ID) %>% 
  mutate(ID = c("C5","C6","C7","C8","C9"), 
         sex = c("m","m","f","m","f"))

#combine datasets
dat_all <- rbind(season1, season2) %>% unnest %>% data.frame() %>% 
  filter(month(time) %in% c(12,1,2,3))

#transform 
dat_sp <- dat_all %>% dplyr::select(ID,x,y) %>% 
  st_as_sf(., coords = c("x","y"), crs = "+init=epsg:4326") %>%
  st_transform("+proj=utm +zone=10 +datum=WGS84") %>% 
  as("Spatial")

kud_all <- kernelUD(dat_sp, h = 'href')
area <- kernel.area(kud_all, percent = 95) %>% 
  as.tibble() %>% pivot_longer(1:9,names_to = "ID", values_to = "Area (m^2)")
kud_contour <- getverticeshr(kud_all, percent = 95 , unout = "km2")
#save(kud_contour, file = "kud_coyote.Rdata")

#OLD
# library(ggthemes)
# ggplot() +
#   geom_sf(data = hr, aes(fill = id), alpha = .2) +
#   geom_sf(data = hopland, aes(fill = NA), color = "black", alpha = 0.01) +
#   coord_sf() +
#   ggthemes::scale_fill_gdocs() +
#   theme_void() + 
#   facet_wrap(~season)
