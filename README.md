# Shishu Suraksha

Shishu Suraksha is a comprehensive ECD (Early Childhood Development) application designed for Anganwadi teachers and ASHA workers to monitor and support child growth and development.

## 🚀 New Features: Live AI Chatbot

The application now features a "live" AI assistant capable of interacting in multiple regional languages, with **Telugu** as the default.

### Key Capabilities:
- **Intelligent Telugu Interaction**: Powered by Groq (Llama-3), providing fast and professional responses to ECD queries.
- **Voice Response (TTS)**: The assistant reads aloud its responses in the selected language.
- **Speech-to-Text (STT)**: Users can speak their queries directly in Telugu.
- **Real-time Localized Greetings**: The dashboard banner dynamically updates based on the time of day (Morning/Afternoon/Evening) in both English and Telugu.
- **Polished Startup Experience**: A seamless, high-performance startup flow using Lottie animations and optimized splash transitions for a premium feel.
- **Responsive Design**: Prevents UI overlap on mobile devices and supports both Modern and Teacher dashboard layouts.

## 📊 System Flowchart

```mermaid
graph TD
    %% Entry Point
    User([Anganwadi Worker]) --> Intro[Lottie Opening Animation]
    Intro --> Splash[Smooth Splash Transition]
    Splash --> Login{Login / Auth}
    Login -->|Success| Dashboard[Modern Menu Dashboard]

    %% Dashboard Components
    Dashboard -->|Realtime Streams| DataService[(DataService <br/> StreamControllers)]
    Dashboard -->|Greeting| Welcome[Realtime Welcome Message]
    Dashboard -->|Alerts| RedFlag[Red Flag Indicator <br/> High Risk Count]
    Dashboard -->|Reminders| LastVisit[Last Visit Reminder <br/> >30 Days]

    %% Main Features
    Dashboard --> Features{Core Features}

    %% Quick Actions
    Features -->|Quick Actions| QA_Grid[Quick Actions Grid]
    QA_Grid --> Tasks[Tasks Screen <br/> Smart Reminders]
    QA_Grid --> Alerts[Alerts Screen <br/> Risk Badges]
    QA_Grid --> Profile[Profile Screen]
    QA_Grid --> Help[Help Center <br/> Emergency Guide]

    %% Data Entry & OCR
    Features -->|Add Child| EntryMode{Select Mode}
    EntryMode -->|Manual Fast| QuickAdd[Quick Add Screen <br/> Name, Age, Weight]
    EntryMode -->|Smart Scan| OCR[OCR Data Entry Screen]
    
    %% OCR Pipeline
    subgraph OCR_Pipeline [8-Stage OCR Architecture]
        OCR -->|Capture| Camera[Stage 1: Smart Capture]
        Camera -->|Image| Preprocess[Stage 2: Preprocessing <br/> OpenCV Denoise]
        Preprocess -->|Clean Image| Zonal[Stage 3: Zonal Cropping]
        Zonal -->|Regions| Extract[Stage 4: Smart Extraction <br/> Fuzzy Match]
        Extract -->|Data| Confidence[Stage 5: Visual Confidence]
        Confidence -->|Validation| Validate[Stage 6: Validation <br/> Aadhaar/DOB]
        Validate -->|Edit| Correction[Stage 7: Assisted Correction <br/> Field Re-scan]
        Correction -->|Submit| Learning[Stage 8: Learning Loop <br/> Feedback Log]
    end

    %% Screening Modules
    Features -->|Screening| Screening[Screening Hub]
    Screening --> Visual[Visual Screening]
    Screening --> Audio[Audio Screening]
    Screening --> Thermal[Thermal Screening]
    Screening --> Injury[Injury Analysis]
```

## Getting Started

### Environment Variables
Create a `.env` file in the root directory and add your Groq API key:
```env
GROQ_API_KEY=your_api_key_here
```

### Build & Run
1. Install dependencies: `flutter pub get`
2. Run the app: `flutter run`
