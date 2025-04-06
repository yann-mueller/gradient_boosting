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
library(MASS)
library(ggdensity)
library(ks)

### Set WD
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

### Load Data
# Spatial Data
source("subroutines/load_data.R")

# Shapefiles
source("subroutines/load_shapefiles.R")


### Gradient Boosting

## K-Fold Cross Validation (Leave-One-Province-Out)
# Create List of Provinces
provinces <- mor2$ADM2_FR

# Test Error list
fold_errors <- c()

# Create an Empty Prediction Vector
all_preds <- rep(NA, nrow(prediction_data))

# Loop Through Every Fold (Province)
for (fold in 1:length(provinces)) {
  print(fold)
  
  # Select province geometry
  province_poly <- mor2[fold, ]
  
  # Extract test data: points within province
  test_idx <- which(pointsInPolygon(prediction_data[,1:2], province_poly, logical=TRUE))
  test <- prediction_data[test_idx, ]
  
  # Train: all others
  train <- prediction_data[-test_idx, ]
  
  # Convert to matrix
  train_mat <- as.matrix(train)
  test_mat <- as.matrix(test)
  
  # Build DMatrix and train
  dtrain <- xgb.DMatrix(data = train_mat[,-3], label = train[,3])
  bst <- xgboost(data = dtrain, max.depth = 100, eta = 1, nthread = 2,
                 nrounds = 100, objective = "binary:logistic", verbose = 0)
  
  # Predict and calculate error
  pred <- predict(bst, test_mat[,-3])
  err <- mean(as.numeric(pred > 0.5) != test_mat[,3])
  fold_errors <- c(fold_errors, err)
  
  # Store predictions in the full vector
  all_preds[test_idx] <- pred
  
  cat(paste("Province", fold, "test-error =", round(err, 4), "\n"))
}

#save(prediction_data, file = "output/prediction_data.RData")
#load("output/prediction_data.RData")


### Density Map

# Allows better visual interpretation of the prediction

# Step 1: Replace NA / Inf in pred with 0
prediction_data$pred_clean <- prediction_data$pred
prediction_data$pred_clean[!is.finite(prediction_data$pred_clean)] <- 0

# Step 2: Prepare input
coords <- cbind(prediction_data$x, prediction_data$y)
weights <- prediction_data$pred_clean

# Step 3: Run weighted KDE
fhat <- kde(x = coords, w = weights, gridsize = c(300, 300))

# Turn KDE result into dataframe
dens_df <- data.frame(
  expand.grid(x = fhat$eval.points[[1]], y = fhat$eval.points[[2]]),
  z = as.vector(fhat$estimate)
)



### Plots
plots <- list()

for (i in 1:nrow(mor2)) {
  print(i)
  province_name <- mor2$ADM2_FR[i]
  province_geom <- mor2[i, ]
  
  # Step 1: Compute centroid
  centroid <- st_centroid(province_geom)
  center_x <- st_coordinates(centroid)[1]
  center_y <- st_coordinates(centroid)[2]
  
  # Step 2: Define fixed window around centroid (in degrees)
  box_half_width <- 1.4
  box_half_height <- 1.4
  xlim <- c(center_x - box_half_width, center_x + box_half_width)
  ylim <- c(center_y - box_half_height, center_y + box_half_height)
  
  # Step 3: # Filter smoothed KDE data inside province bbox
  test_idx <- which(pointsInPolygon(dens_df[, c("x", "y")], province_geom, logical = TRUE))
  temp <- dens_df[test_idx, ]
  
  # Step 4: Create the plot
  p <- ggplot() +
    geom_sf(data = countries, fill = country_color_inactive) +
    geom_sf(data = mor2, fill = country_color_active) +
    geom_tile(data = temp, aes(x = x, y = y, fill = z)) +
    scale_fill_gradientn(
      colours = percentile_colors,
      name = "Oasis Prediction Probability\n",
      limits = c(0, 1),
      breaks = c(0, 1),
      oob = scales::squish
    ) +
    geom_sf(data = province_geom, fill = NA, color = "black", size = 1) +
    geom_sf(
      data = oases,
      aes(shape = legend_label),
      size = 1.5,
      color = "darkred",
      fill = "darkred",
      show.legend = "point"
    ) +
    scale_shape_manual(name = "Oasis", values = c("Oasis" = 21), labels = NULL) +
    guides(
      shape = guide_legend(
        override.aes = list(size = 5),
        title.theme = element_text(size = 14),
        label.theme = element_text(size = 12)
      ),
      fill = guide_colorbar(
        title.theme = element_text(size = 14),
        label.theme = element_text(size = 12)
      )
    ) +
    coord_sf(
      xlim = xlim,
      ylim = ylim
    ) +
    annotation_scale(location = "br", width_hint = 0.4, height = unit(0.25, "cm"), text_cex = 1.1) +
    ggtitle(province_name) +
    theme(
      panel.grid.major = element_line(color = gray(.8), linetype = "dashed", size = 0.5),
      panel.background = element_rect(fill = "aliceblue"),
      legend.position = "bottom",
      plot.title = element_text(hjust = 0.5, size = 18),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.x = element_blank(),
      axis.ticks.y = element_blank()
    )
  
  plots[[province_name]] <- p
  
  ggsave(
    filename = paste0("plots/", gsub("[^A-Za-z0-9_]", "_", province_name), ".png"),
    plot = p,
    width = 6,
    height = 6,
    dpi = 300
  )
}
