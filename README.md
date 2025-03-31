# Gradient Boosting: Spatial Predictions with XGBoost

### Objective: Prediction of Oasis Locations
![grafik](https://github.com/user-attachments/assets/c6206bb3-5a7b-4680-8bcf-bd8edb07888e)

#### Difficulty
An oasis represents a human exploitation of specific geographic conditions that allow for the cultivation of water in (semi-)arid environments. In order to be used as instrumental variable, it is necessary to exploit only the variation stemming from locational fundamentals but not human choices in the prediction.

#### Solution Approach
The literature on agriculture and hydrology provides information on four critical geographic conditions (illustrated below). Together with other geographic features from various datasources, I use gradient boosting to create a prediction of the oases locations. Specifically, I use a K-fold cross validation algorithm, where *K* is equal to the number of provinces in Morocco, such that a out-of-sample prediction is constructed for every province, using the remaining provinces as training data.
![grafik](https://github.com/user-attachments/assets/b65df6d4-5802-41b5-a64d-f729516ba78b)

