# iDairy App

**iDairy** is a smart dairy management mobile application built using **Flutter**, integrated with **Firebase** for real-time data handling and user management, and enhanced with a **SARIMA forecasting model** to help stallholders predict product demand and manage supply effectively.

---

## Features

- Flutter-based intuitive UI for seamless user experience
- Secure authentication for stallholders (Firebase Auth)
- SARIMA model for product demand forecasting
- Daily sales and inventory tracking
- Interactive demand prediction graphs
- Firebase Firestore for real-time database management
- Admin dashboard for performance overview
- Integrated chatbot (Google Gemini API) for user queries *(planned)*

---

## Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend/DB:** Firebase Firestore, Firebase Auth
- **Forecasting Model:** SARIMA (Python)
- **Communication:** Python–Dart integration using FFI
- **Data Input:** Google Sheets (per-product sheet input)

---

## How to Run the Project

### Steps to Run

1. Clone this repository  
2. Open the project in your IDE (e.g., VS Code or Android Studio)  
3. Set up your `google-services.json` in `android/app`  
4. Run the Flutter project:
   ```bash
   flutter run

### Prerequisites

- Flutter SDK installed
- Firebase project setup
- Python 3.x installed (for SARIMA model)
- Required Python libraries:
  ```bash
  pip install pandas numpy matplotlib statsmodels

## Screenshots

| Trending Screen | Order Screen |
|-----------------|--------------|
| ![Trending Screen](Screenshots/3%20trending.jpg) | ![Order Screen](Screenshots/9%20order%20history.jpg) |

| Admin Screen | Model Screen |
|--------------|--------------|
| ![Admin Screen](Screenshots/10%20products.jpg) | ![Model Screen](Screenshots/17%20model.jpg) |

