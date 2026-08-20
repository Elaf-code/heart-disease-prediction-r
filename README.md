# heart-disease-prediction-r
# 🫀 Heart Disease Risk Prediction & Clinical Data Analysis

> Supervised machine learning framework and clinical exploratory data analysis evaluating cardiovascular risk factors using the benchmark UCI Heart Disease dataset.

 **Interactive Live Application:** [Shiny Web App](https://runupw-0-0.shinyapps.io/heart-disease-prediction/)

---

##  Executive Summary & Problem
Cardiovascular diseases remain a leading cause of global mortality. This project investigates whether standard, non-invasive clinical measurements can accurately predict heart disease presence and identifies optimal supervised classification techniques for clinical screening.

##  Dataset & Preprocessing
* **Source:** UCI Machine Learning Repository / Kaggle benchmark dataset (303 records, 14 clinical features).
* **Target Feature:** Binarized `heart_disease` status (`No: 0` vs. `Yes: >0`).
* **Preprocessing Pipeline:** Complete-case handling, factor encoding for categorical predictors, and stratified $70/30$ train/test data splitting with fixed random seed (`seed = 42`) for full reproducibility.

---

##  Key Clinical Insights (Exploratory Data Analysis)
* **Age Disparity:** Significant age differential observed; patients diagnosed with heart disease showed a higher median age (~57 years) compared to healthy profiles (~52 years).
* **Correlation Patterns:** Identified notable physiological associations, including inverse correlation between maximum heart rate (`thalach`) and patient age, as well as risk alignment between ST depression (`oldpeak`) and number of major vessels (`ca`).

---

##  Model Performance Comparison

Three supervised machine learning classifiers were evaluated on the held-out 30% test set ($n = 90$):

| Model | Test Accuracy | Sensitivity | Specificity | Balanced Accuracy | Cohen's Kappa |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Logistic Regression (glm)** ⭐ | **85.56%** | **0.9167** | **0.7857** | **0.8512** | **0.7076** |
| **K-Nearest Neighbors (KNN - 5-fold CV)** | 67.78% | 0.7292 | 0.6190 | 0.6741 | 0.3498 |
| **Decision Tree (rpart)** | 67.78% | 0.9167 | 0.4048 | 0.6607 | 0.3318 |

> **Key Finding:** Logistic Regression outperformed competing classifiers by **17.8 percentage points**, achieving high sensitivity ($91.7\%$) and a low false-negative rate ($10.8\%$), exceeding the 80% clinical screening utility benchmark ($p = 9.58 \times 10^{-11}$).

---

##  Tech Stack & Libraries
* **Language:** R
* **Frameworks & Packages:** `tidyverse` (`dplyr`, `ggplot2`), `caret`, `rpart`, `corrplot`
* **Deployment:** R Shiny (`shinyapps.io`)

---

##  Project Structure
```text
├── app/          # R Shiny application code (ui.R, server.R / app.R)
├── data/         # UCI Heart disease benchmark dataset
├── scripts/      # Full R data wrangling, EDA, and model training script
├── figures/      # Generated ggplot2 confusion matrices and ROC/probability plots
└── README.md
