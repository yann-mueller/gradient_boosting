# Gradient Boosting: Spatial Predictions with XGBoost

### Objective: Prediction of Oasis Locations
![grafik](https://github.com/user-attachments/assets/c6206bb3-5a7b-4680-8bcf-bd8edb07888e)

**Suitable for any spatial predictions with binary outcome variable!**

### Approach: Gradient Boosting
Gradient Boosting builds a predictive model in an additive, stage-wise fashion, using gradient descent to minimize a loss function. It's often used for binary classification with logistic loss.

#### Model
We aim to learn a function *F(x)* that maps features *x* to predictions *ŷ*, by sequentially adding base learners (e.g. decision trees):
![grafik](https://github.com/user-attachments/assets/5164e943-4574-4263-b5ef-0bdd3f5f3952)

Where:
- *F<sub>m</sub>(x)* is the boosted model at iteration mm
- *h<sub>m</sub>(x)* is the new base learner (tree) added at step mm
- *ν* is the learning rate (step size)
- *L(y,ŷ)* is the loss function
- *y*<sub>*i*</sub> is the true label for observation *i*

#### Optimization via Gradient Descent
Each base learner is trained to fit the **negative gradient** of the loss function with respect to the current model prediction:

![grafik](https://github.com/user-attachments/assets/f6ddd946-08d4-4522-9de1-f5e020e79c2f)

So, the new learner  *h<sub>m</sub>(x)* is fit to the residuals  *r*<sub>*i*</sub>*(m)*, and the model updates as:

![grafik](https://github.com/user-attachments/assets/0b93a6ae-f47c-4d44-8afb-9a7b7bf95fd3)

#### Binary Classification with Logistic Loss
We are now doing a binary classification, using the logistic loss function:

![grafik](https://github.com/user-attachments/assets/299a87b0-3bdb-4e21-9f28-ac660529d639)

Where *y∈{−1,+1}*, and *F(x)* is the log-odds of the predicted probability:

![grafik](https://github.com/user-attachments/assets/80a03175-b37f-46b0-8550-2f7d0dc23dfa)

The negative gradient becomes:

![grafik](https://github.com/user-attachments/assets/307dbc9d-d1d3-44e7-9d67-2217fed92993)

where *σ(F)* is the logistic (sigmoid) function.


#### Features Overview
An oasis represents a human exploitation of specific geographic conditions that allow for the cultivation of water in (semi-)arid environments. The literature on agriculture and hydrology provides information on four critical geographic conditions that are necessary for the cultivation of an oasis (illustrated below). Together with other geographic features from various datasources, we have a total of about 300 features, including information on neighboring grid cells.
![grafik](https://github.com/user-attachments/assets/b65df6d4-5802-41b5-a64d-f729516ba78b)


### XGBoost: Regularized Boosting
XGBoost extends basic gradient boosting by:
- Using **second-order derivatives** (Newton boosting) for more efficient optimization.
- Adding **regularization** to the objective:

![grafik](https://github.com/user-attachments/assets/dcf39f42-83f8-460c-8420-1ebc7922caa3)

*T*: number of leaves,

*w*<sub>*j*</sub>​: score on leaf *j*,

*γ,λ*: regularization parameters.


### Spatial Cross-Validation: Leave-One-Province-Out
To evaluate model performance and avoid overfitting, I implemented a custom K-fold cross-validation strategy, where each fold corresponds to one province (out of 69 provinces in Morocco). This is especially important in geospatial contexts, where nearby observations can be highly correlated — a problem known as spatial autocorrelation. For each fold:
- One province is held out entirely as the test set.
- The model is trained on data from all other provinces.
- Predictions are made on the held-out province.
- The error is calculated and stored.
- The predictions are also saved for building the full map later.

### Predictions (Oasis Provinces)

![grafik](https://github.com/user-attachments/assets/5354882e-d00b-443c-a583-2671185c16f3)


### Predictions (Non-Oasis Provinces)

![grafik](https://github.com/user-attachments/assets/943fdfe7-c799-4af5-9e0c-e6e370f64358)




### Notes: Smoothed Oasis Probability Map (Density Map)
After generating predictions for each fine-grained grid cell using the trained gradient boosting model, I created a density-based probability surface to make the spatial patterns easier to interpret. The raw model predictions are made at a very fine spatial resolution — often resulting in a pixelated map that's difficult to interpret, especially when zoomed out. While each prediction is informative on its own, we’re often more interested in regional trends and hotspots of high probability, not individual grid cells. To address this, I generated a smoothed probability surface using kernel density estimation (KDE), which estimates the probability of encountering an oasis across space.

### Conclusion: Model Performance
The predictions from the XGBoost model perform quite well overall. In provinces without any oases, the algorithm reliably assigns near-zero probabilities to almost all grid cells, demonstrating strong precision in these cases.

In provinces where oases are present, the model successfully identifies many oasis clusters, accurately assigning high probabilities to the correct regions. False positives—areas predicted to contain oases where none actually exist—are rare, which further supports the model’s robustness.

That said, some oasis clusters are not well captured by the algorithm. This likely reflects the fact that while geographic features explain part of the variation in oasis locations, they don’t capture all of it. In particular, **second-nature geography**—that is, human settlement and land use decisions—is not included in the model and may play an important role in determining oasis presence.

For the purposes of this research project, however, this level of predictive accuracy is sufficient. The goal is not perfect prediction, but rather to exploit the variation in oasis presence that can be explained by geographic features to construct a valid **instrumental variable**.
