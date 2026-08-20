library(shiny)
library(tidyverse)

# ============================================================
# DATA & MODEL
# ============================================================
df <- read.csv("heart_disease_uci.csv") %>%
  select(-id) %>%
  na.omit() %>%
  mutate(
    heart_disease = as.factor(ifelse(num == 0, "No", "Yes")),
    num = NULL,
    across(where(is.character), as.factor)
  )

set.seed(42)
idx   <- sample(1:nrow(df), 0.7 * nrow(df))
train <- df[idx, ]
fit   <- glm(heart_disease ~ ., data = train, family = "binomial")
coefs <- coef(fit)

LV <- list(
  sex     = c("female","male"),
  cp      = c("asymptomatic","atypical angina","non-anginal","typical angina"),
  fbs     = c("FALSE","TRUE"),
  restecg = c("lv hypertrophy","normal","st-t abnormality"),
  exang   = c("FALSE","TRUE"),
  slope   = c("downsloping","flat","upsloping"),
  thal    = c("fixed defect","normal","reversable defect")
)

# ============================================================
# UI
# ============================================================
ui <- fluidPage(

  tags$head(tags$style(HTML('

    @import url("https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap");

    * { box-sizing: border-box; }

    body {
      background-color: #f4f6f9;
      font-family: "Inter", sans-serif;
      color: #2c3e50;
    }

    /* ---- Header ---- */
    .app-header {
      background: linear-gradient(135deg, #1B2A4A 0%, #2e4a7a 100%);
      color: white;
      padding: 28px 36px 20px 36px;
      margin-bottom: 28px;
      border-radius: 0 0 16px 16px;
      box-shadow: 0 4px 18px rgba(27,42,74,0.18);
    }
    .app-header h1 {
      font-size: 26px;
      font-weight: 700;
      margin: 0 0 4px 0;
      letter-spacing: 0.3px;
    }
    .app-header p {
      font-size: 13px;
      margin: 0;
      opacity: 0.75;
    }
    .header-badge {
      display:inline-block;
      background: rgba(255,255,255,0.15);
      border: 1px solid rgba(255,255,255,0.3);
      border-radius: 20px;
      padding: 3px 12px;
      font-size: 12px;
      margin-top: 8px;
    }

    /* ---- Sidebar card ---- */
    .well {
      background: #ffffff !important;
      border: 1px solid #e1e8f0 !important;
      border-radius: 14px !important;
      padding: 22px 20px !important;
      box-shadow: 0 2px 12px rgba(0,0,0,0.06) !important;
    }

    /* ---- Section labels inside sidebar ---- */
    .section-label {
      font-size: 11px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 1px;
      color: #1B2A4A;
      border-bottom: 2px solid #C0392B;
      padding-bottom: 5px;
      margin: 18px 0 12px 0;
    }
    .section-label:first-child { margin-top: 0; }

    /* ---- Inputs ---- */
    label { font-size: 12px !important; font-weight: 600 !important; color: #4a5568 !important; margin-bottom: 3px !important; }
    .form-control {
      border: 1px solid #d1dce8 !important;
      border-radius: 8px !important;
      font-size: 13px !important;
      padding: 7px 10px !important;
      background: #f8fafc !important;
      color: #2c3e50 !important;
      transition: border 0.2s;
    }
    .form-control:focus { border-color: #1B2A4A !important; outline: none !important; box-shadow: 0 0 0 3px rgba(27,42,74,0.1) !important; }
    select.form-control { cursor: pointer; }

    /* ---- Predict button ---- */
    .btn-predict {
      background: linear-gradient(135deg, #C0392B, #e74c3c) !important;
      color: white !important;
      width: 100% !important;
      border: none !important;
      border-radius: 10px !important;
      padding: 12px !important;
      font-size: 15px !important;
      font-weight: 700 !important;
      letter-spacing: 0.5px;
      cursor: pointer !important;
      margin-top: 8px !important;
      box-shadow: 0 4px 14px rgba(192,57,43,0.35) !important;
      transition: transform 0.15s, box-shadow 0.15s;
    }
    .btn-predict:hover { transform: translateY(-1px); box-shadow: 0 6px 18px rgba(192,57,43,0.45) !important; }
    .btn-predict:active { transform: translateY(0); }

    /* ---- Main panel ---- */
    .main-card {
      background: white;
      border-radius: 14px;
      border: 1px solid #e1e8f0;
      padding: 32px 36px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.06);
      min-height: 360px;
    }

    /* ---- Result boxes ---- */
    .res-high {
      background: linear-gradient(135deg, #C0392B, #e74c3c);
      color: white; padding: 28px; border-radius: 14px;
      font-size: 22px; font-weight: 700; text-align: center;
      box-shadow: 0 6px 20px rgba(192,57,43,0.3);
      margin-bottom: 16px;
    }
    .res-low {
      background: linear-gradient(135deg, #1B2A4A, #2e4a7a);
      color: white; padding: 28px; border-radius: 14px;
      font-size: 22px; font-weight: 700; text-align: center;
      box-shadow: 0 6px 20px rgba(27,42,74,0.3);
      margin-bottom: 16px;
    }
    .res-icon { font-size: 38px; display:block; margin-bottom: 10px; }

    /* ---- Probability bar ---- */
    .prob-wrap { margin-top: 10px; }
    .prob-label { font-size: 13px; color: #5A6A7A; margin-bottom: 6px; font-weight:600; }
    .prob-bar-bg { background:#e9ecef; border-radius:8px; height:14px; overflow:hidden; }
    .prob-bar-fill { height:14px; border-radius:8px; transition: width 0.6s ease; }

    /* ---- Model metrics table ---- */
    .metrics-title { font-size:14px; font-weight:700; color:#1B2A4A; margin: 28px 0 12px 0;
                     border-left: 4px solid #C0392B; padding-left: 10px; }
    table.metrics { width:100%; border-collapse:collapse; font-size:12px; }
    table.metrics th { background:#1B2A4A; color:white; padding:9px 12px; text-align:left; }
    table.metrics td { padding:8px 12px; border-bottom:1px solid #f0f0f0; }
    table.metrics tr:nth-child(2) td { background:#fff8f8; font-weight:700; }
    table.metrics tr:hover td { background:#f5f8ff; }

    /* ---- Idle state ---- */
    .idle-hint { text-align:center; padding: 50px 20px; color:#a0aab4; }
    .idle-hint .idle-icon { font-size:52px; margin-bottom:14px; }
    .idle-hint p { font-size:14px; margin:0; }

    /* ---- Disclaimer ---- */
    .disclaimer { font-size:11px; color:#a0aab4; text-align:center; margin-top:20px; }
  '))),

  # Header
  div(class = "app-header",
    h1("Heart Disease Prediction Dashboard"),
    p("Logistic Regression · UCI Heart Disease Dataset (n = 303)"),
    span(class = "header-badge", "CS 473 — Data Visualization · Majmaah University")
  ),

  sidebarLayout(
    sidebarPanel(
      width = 4,

      div(class="section-label", "Patient Demographics"),
      numericInput("age", "Age (years)", value = 55, min = 1, max = 120),
      selectInput( "sex", "Biological Sex", choices = c("male","female")),

      div(class="section-label", "Clinical Measurements"),
      numericInput("trestbps", "Resting Blood Pressure (mmHg)", value = 130, min = 80, max = 220),
      numericInput("chol",     "Cholesterol (mg/dl)",           value = 250, min = 100, max = 600),
      numericInput("thalach",  "Max Heart Rate Achieved",       value = 150, min = 60,  max = 220),
      numericInput("oldpeak",  "ST Depression (oldpeak)",       value = 1.0, min = 0,   max = 10, step = 0.1),
      numericInput("ca",       "Major Vessels (0-3)",           value = 0,   min = 0,   max = 3),

      div(class="section-label", "Diagnostic Indicators"),
      selectInput("cp",      "Chest Pain Type",          choices = LV$cp),
      selectInput("fbs",     "Fasting Blood Sugar >120", choices = LV$fbs),
      selectInput("restecg", "Resting ECG",              choices = LV$restecg),
      selectInput("exang",   "Exercise Induced Angina",  choices = LV$exang),
      selectInput("slope",   "ST Slope",                 choices = LV$slope),
      selectInput("thal",    "Thalassemia",              choices = LV$thal),

      br(),
      actionButton("btn", "Run Prediction", class = "btn-predict")
    ),

    mainPanel(
      width = 8,
      div(class = "main-card",

        uiOutput("result"),

        div(class = "metrics-title", "Model Performance — Held-Out Test Set (n = 90)"),
        tags$table(class = "metrics",
          tags$tr(
            tags$th("Model"), tags$th("Accuracy"), tags$th("Sensitivity"),
            tags$th("Specificity"), tags$th("Kappa"), tags$th("Balanced Acc.")
          ),
          tags$tr(tags$td("Logistic Regression ★"), tags$td("85.6%"),
                  tags$td("0.917"), tags$td("0.786"), tags$td("0.708"), tags$td("0.851")),
          tags$tr(tags$td("Decision Tree"),  tags$td("67.8%"),
                  tags$td("0.917"), tags$td("0.405"), tags$td("0.332"), tags$td("0.661")),
          tags$tr(tags$td("KNN (5-fold CV)"), tags$td("67.8%"),
                  tags$td("0.729"), tags$td("0.619"), tags$td("0.350"), tags$td("0.674"))
        ),

        div(class="disclaimer",
            "This tool is for educational purposes only and does not constitute clinical advice.")
      )
    )
  )
)

# ============================================================
# SERVER
# ============================================================
server <- function(input, output) {

  output$result <- renderUI({
    div(class = "idle-hint",
        div(class = "idle-icon", "🫀"),
        p("Fill in the patient details on the left and click Run Prediction.")
    )
  })

  observeEvent(input$btn, {
    tryCatch({
      nd <- data.frame(
        age=as.numeric(input$age), sex=factor(input$sex,levels=LV$sex),
        cp=factor(input$cp,levels=LV$cp), trestbps=as.numeric(input$trestbps),
        chol=as.numeric(input$chol), fbs=factor(input$fbs,levels=LV$fbs),
        restecg=factor(input$restecg,levels=LV$restecg), thalach=as.numeric(input$thalach),
        exang=factor(input$exang,levels=LV$exang), oldpeak=as.numeric(input$oldpeak),
        slope=factor(input$slope,levels=LV$slope), ca=as.numeric(input$ca),
        thal=factor(input$thal,levels=LV$thal), stringsAsFactors=FALSE
      )
      xmat <- model.matrix(~., data=nd)[,-1,drop=FALSE]
      cn   <- names(coefs)[-1]
      for(col in setdiff(cn, colnames(xmat))) { xmat<-cbind(xmat,0); colnames(xmat)[ncol(xmat)]<-col }
      xmat <- xmat[,cn,drop=FALSE]
      prob <- 1/(1+exp(-(coefs[[1]]+sum(xmat*coefs[-1]))))
      pct  <- round(prob*100,1)
      bar_color <- if(prob>0.5) "#C0392B" else "#1B2A4A"

      output$result <- renderUI({
        tagList(
          if(prob > 0.5)
            div(class="res-high",
                span(class="res-icon","⚠️"),
                paste0("High Risk — Heart Disease Detected"),
                br(),
                tags$small(style="font-size:15px;opacity:0.9;font-weight:400;",
                           paste0("Predicted probability: ", pct, "%"))
            )
          else
            div(class="res-low",
                span(class="res-icon","✅"),
                paste0("Low Risk — No Heart Disease Detected"),
                br(),
                tags$small(style="font-size:15px;opacity:0.9;font-weight:400;",
                           paste0("Predicted probability: ", pct, "%"))
            ),
          div(class="prob-wrap",
              div(class="prob-label", paste0("Risk Score: ", pct, "%")),
              div(class="prob-bar-bg",
                  div(class="prob-bar-fill",
                      style=paste0("width:",pct,"%; background:",bar_color,";")))
          )
        )
      })

    }, error=function(e){
      output$result <- renderUI({
        div(style="color:#C0392B;font-weight:bold;padding:20px;",
            paste("Error:", e$message))
      })
    })
  })
}

shinyApp(ui=ui, server=server)
