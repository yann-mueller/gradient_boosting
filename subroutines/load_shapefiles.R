### Load Libraries
library(dplyr)
library(xgboost)
library(ggplot2)
library(sf)
library(geojsonsf)
library(terra)
library(secr)
library(ggspatial)
library(FNN)


### Load Shapefiles

## Colors
country_color_active <- c("#fdd49e")
country_color_inactive <- c("#fef0d9")
percentile_colors <- c("blue", "#6ff5c3", "green", "yellow")


## Shapefiles 
mor2 <- geojson_sf("input/shapefiles/mor_2.geojson") # Morocco Province Boundaries
oases_countries <- geojson_sf("input/shapefiles/oases_countries.geojson")
non_oases_countries <- geojson_sf("input/shapefiles/non_oases_countries.geojson")
oases <- geojson_sf("input/shapefiles/oases.geojson")
oases$legend_label <- "Oasis"


# Combine data from .geojson file
countries <- rbind(oases_countries, non_oases_countries)

# Select countries and oases that are relevant for the analysis
countries_select <- countries[is.element(countries$color_code, "MAR"),]
oases_select <- st_filter(oases, countries_select)
province_select <- st_filter(mor2, oases_select)
countries <- countries[!is.element(countries$color_code, "MAR"),]