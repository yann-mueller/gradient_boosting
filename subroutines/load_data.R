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

### Load Data

## Spatial Data
#save(prediction_data, file = "input/spatial_data.RData")
load("input/spatial_data_reduced.RData")

# Transform Factor Columns into Dummy Columns
prediction_data$texture <- as.factor(prediction_data$texture)
dummy_texture <- model.matrix(~ texture - 1, data = prediction_data)
prediction_data <- cbind(prediction_data, dummy_texture)
prediction_data <- prediction_data[, !names(prediction_data) %in% "texture"]

# Replace Geometry Column with Longitude and Latitude Column
coords <- st_coordinates(prediction_data)
prediction_data$x <- coords[, "X"]
prediction_data$y <- coords[, "Y"]
prediction_data <- as.data.frame(st_drop_geometry(prediction_data))
prediction_data <- prediction_data[, c("x", "y", setdiff(names(prediction_data), c("x", "y")))]

# Create Columns of the 3rd Polynomial of Longitude and Latitude 
prediction_data <- prediction_data %>%
  mutate(
    x2 = x^2,
    x3 = x^3,
    y2 = y^2,
    y3 = y^3,
    xy = x * y,
    x2y = x^2 * y,
    xy2 = x * y^2
  )

# Prepare coordinate matrix (x = longitude, y = latitude)
coords <- as.matrix(prediction_data[,c("x", "y")])

# Find 21 nearest neighbors (first one is the point itself)
nn_result <- get.knn(coords, k = 21)

# Drop the first column (self)
nn_indices <- nn_result$nn.index[, 2:21]


# Extract the indices of nearest neighbors
nn_indices <- nn_result$nn.index

# For each row, pull neighbor values and attach as new columns
for (col_name in c("tri", "Cl1", "Cl2", "Cl3", "Cl4", "Cl5", "Cl6", "Cl7", "Cl8", "texture0", "texture3", "texture5", "texture9", "texture11")) {  # replace or extend with your actual column names
  for (j in 1:20) {
    prediction_data[[paste0(col_name, "_nn", j)]] <- prediction_data[[col_name]][nn_indices[, j]]
  }
}



# Ensure it's a data frame
prediction_data <- as.data.frame(prediction_data)

coords <- prediction_data %>%
  dplyr::select(x, y) %>%
  as.matrix()


# Find 11 nearest neighbors (first one is the point itself)
nn_result <- get.knn(coords, k = 21)

# Drop the first column (self)
nn_indices <- nn_result$nn.index[, 2:21]

# Loop through desired columns and assign nearest neighbors' values
for (col_name in c("tri", "Cl1", "Cl2", "Cl3", "Cl4", "Cl5", "Cl6", "Cl7", "Cl8",
                   "groundwater", "texture0", "texture3", "texture5", "texture9",
                   "texture11"
                   )) {  # replace with actual column names
  for (j in 1:10) {
    prediction_data[[paste0(col_name, "_nn", j)]] <- prediction_data[[col_name]][nn_indices[, j]]
  }
}

rm(coords, dummy_texture, nn_result, nn_indices, col_name, j)





