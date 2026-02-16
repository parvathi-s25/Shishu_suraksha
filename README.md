# Shishu Suraksha

Shishu Suraksha is a comprehensive ECD (Early Childhood Development) application designed for Anganwadi teachers and ASHA workers to monitor and support child growth and development.

## 🚀 Newest Features: Health & Admin Suite

The application has been upgraded with a comprehensive and responsive suite for both field workers and regional administrators.

### Key Capabilities:
- **Health & Development Suite**: Integrated vitals monitoring (Heart Rate/SpO2), Growth Tracking (WHO Standards), and Developmental Assessments (Motor/Speech/Cognitive).
- **National Admin Portal**: A high-fidelity dashboard for ministry-level oversight, featuring district performance comparison charts and critical school alerts.
- **Responsive Design**: Zero-overflow UI architecture using `Wrap`, `Flexible`, and `FittedBox` widgets, ensuring a premium experience on any mobile device.
- **Intelligent Search**: Real-time filtering for schools and children across the entire platform.
- **Live AI Chatbot**: Real-time assistant interacting in regional languages (Telugu, Hindi, etc.) with Voice (TTS) and Speech (STT) capabilities.
- **Automated Alerts**: Real-time risk stratification and automated red-flagging for malnourished or high-risk children.

## 📊 System Flowchart

```mermaid
graph TD
    %% Entry Point
    User([User]) --> Intro[Lottie Opening Animation]
    Intro --> Splash[Smooth Splash Transition]
    Splash --> Login{Login / Auth}
    
    %% Role Branching
    Login -->|Teacher| Dashboard[Anganwadi Dashboard]
    Login -->|Admin| AdminDash[National Admin Portal]

    %% Teacher Flow
    subgraph Teacher_Module [Anganwadi Operations]
        Dashboard -->|Vitals| LiveVitals[Heart Rate & Vitals Hub]
        Dashboard -->|Search| ChildSearch[Search Children]
        Dashboard -->|Assessment| Assess[Developmental Suite <br/> Motor/Speech/Cognitive]
        Dashboard -->|Growth| Growth[Growth & Nutrition Charts]
    end

    %% Admin Flow
    subgraph Admin_Module [National Oversight]
        AdminDash -->|Analytics| DistrictChart[District Performance Comparison]
        AdminDash -->|Search| SchoolSearch[Find Specific Schools]
        AdminDash -->|Drilldown| SchoolDetail[School Deep-Dive <br/> Performance & Students]
        AdminDash -->|Management| Alerts[Alert Resolution Panel]
    end

    %% Data Core
    AdminDash -->|Sync| DataService[(Unified Data Service)]
    Dashboard -->|Sync| DataService
    
    %% Screening Modules
    Dashboard -->|Screening| Screening[Screening Hub]
    Screening --> Visual[Visual Screening]
    Screening --> Audio[Audio Screening]
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
