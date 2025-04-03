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


An oasis represents a human exploitation of specific geographic conditions that allow for the cultivation of water in (semi-)arid environments. In order to be used as instrumental variable and predict modern time economic activity (<a href="https://github.com/yann-mueller/oases_market_potential" target="_blank" rel="noopener noreferrer">view academic project outline for more information</a>), it is necessary to exploit only the variation stemming from locational fundamentals but not human choices in the prediction.

#### Features Overview
The literature on agriculture and hydrology provides information on four critical geographic conditions that are necessary for the cultivation of an oasis (illustrated below). Together with other geographic features from various datasources, I use gradient boosting to create a prediction of the oases locations. Specifically, I use a K-fold cross validation algorithm, where *K* is equal to the number of provinces in Morocco, such that a out-of-sample prediction is constructed for every province, using the remaining provinces as training data.
![grafik](https://github.com/user-attachments/assets/b65df6d4-5802-41b5-a64d-f729516ba78b)
