# heart-disease-prediction-r
# 🫀 Heart Disease Risk Prediction & Clinical Data Analysis
Supervised machine learning framework and clinical exploratory data analysis evaluating cardiovascular risk factors using the benchmark UCI Heart Disease dataset.

Interactive Live Application: Shiny Web App
https://runupw-0-0.shinyapps.io/heart-disease-prediction/


Executive Summary & Problem

Cardiovascular diseases remain a leading cause of global mortality. This project investigates whether standard, non-invasive clinical measurements can accurately predict heart disease presence and identifies the optimal supervised classification technique for clinical screening.

Dataset & Preprocessing
Source: UCI Machine Learning Repository / Kaggle benchmark dataset (303 records, 14 clinical features).
Target feature: Binarized heart_disease status (No: num = 0 vs. Yes: num > 0).
Preprocessing pipeline:
Removal of the identifier column (id).
Complete-case handling with na.omit().
Factor encoding of all categorical predictors.
Stratified 70/30 train/test split in the analysis script (caret::createDataPartition) using a fixed seed (seed = 42) for full reproducibility. The held-out test set contains 90 records.

Key Clinical Insights (Exploratory Data Analysis)
Age disparity: Patients diagnosed with heart disease showed a higher median age (~57 years) compared to healthy profiles (~52 years).
Correlation patterns: Notable physiological associations were identified, including an inverse correlation between maximum heart rate (thalach) and patient age, as well as risk alignment between ST depression (oldpeak) and the number of major vessels (ca).
Model Performance Comparison

Three supervised machine learning classifiers were evaluated on the held-out 30% test set (n = 90):

Model	Test Accuracy	Sensitivity	Specificity	Balanced Accuracy	Cohen's Kappa
Logistic Regression (glm) ⭐	85.56%	0.9167	0.7857	0.8512	0.7076
Decision Tree (rpart)	67.78%	0.9167	0.4048	0.6607	0.3318
K-Nearest Neighbors (KNN, 5-fold CV)	67.78%	0.7292	0.6190	0.6741	0.3498

Note on metric direction: caret::confusionMatrix() was run with No (healthy) as the positive class. Sensitivity is therefore the share of healthy patients correctly identified, and Specificity is the share of heart-disease patients correctly identified. In clinical terms, Logistic Regression detected 33 of 42 disease cases (0.7857) and missed 9.

Key finding: Logistic Regression outperformed the competing classifiers by 17.8 percentage points in accuracy (85.56% vs. 67.78%) and achieved the best balanced accuracy (0.8512). Its accuracy is significantly higher than the no-information rate of 53.3% (p = 9.58 × 10⁻¹¹).

Interactive Application (R Shiny)

The Shiny dashboard lets a user enter a patient profile and get an instant risk estimate:

Inputs (13 predictors):
Demographics: age, biological sex.
Clinical measurements: resting blood pressure, cholesterol, maximum heart rate, ST depression (oldpeak), number of major vessels (ca).
Diagnostic indicators: chest pain type, fasting blood sugar, resting ECG, exercise-induced angina, ST slope, thalassemia.
Model: A logistic regression (glm, binomial) is fitted at app start-up on the 70% training split (seed = 42). The coefficients are used to compute the predicted probability for the entered profile.
Output: Predicted probability and a risk score bar. A probability above 0.5 is labeled High Risk, otherwise Low Risk.
Model comparison table: The Decision Tree and KNN results shown in the app are the reported test-set metrics from the training script (scripts/). Only the logistic regression is fitted live inside the app.
Disclaimer: The tool is for educational purposes only and does not constitute clinical advice.

Tech Stack & Libraries
Language: R
Frameworks & packages:
Shiny app: shiny, tidyverse
Analysis and modeling scripts: tidyverse (dplyr, ggplot2), caret, rpart, corrplot
Deployment: R Shiny (shinyapps.io)

Project Structure
├── app/          # R Shiny application (single-file app.R; reads heart_disease_uci.csv)
├── data/         # UCI Heart Disease benchmark dataset (heart_disease_uci.csv)
├── scripts/      # Full R data wrangling, EDA, and model training script
├── figures/      # Generated ggplot2 confusion matrices and ROC/probability plots
└── README.md
