# 🏥 Shishu Suraksha (శిశు సురక్ష)
### *A step towards an inclusive, healthy, and developed future for every child. 🇮🇳*

**Shishu Suraksha** (శిశు సురక్ష) is a mission-critical platform empowering early childhood development through a fusion of AI and IoT. Designed for Anganwadi workers, ASHA personnel, and Health Administrators, it provides a robust, zero-overflow interface for monitoring, assessing, and intervening in child development across rural and urban India.

---

## 🌟 Key Pillars of the Platform

### 📊 National Admin Portal (G2G)
- **District Analytics**: Compare performance metrics (Bangalore, Mysore, Tumkur, Hassan) in real-time.
- **Critical Oversight**: Automated 'Schools Requiring Attention' list based on health & compliance scores.
- **Alert Resolution**: A centralized hub to manage and resolve high-severity triggers for child malnutrition or developmental delays.

### 👶 Anganwadi Operations (Frontline)
- **Health & Development Suite**:
    - **Live Vitals**: Real-time heart rate and SpO2 monitoring integration.
    - **Growth Monitoring**: Precision tracking against WHO growth standards (Weight-for-Age).
    - **Developmental Milestone Hub**: Formalized Motor, Speech, and Cognitive screening.
- **Intelligent Search**: Find children instantly by Name, ID, or Risk Profile.

### 🤖 Intelligent Assistant & Localization
- **Multi-Lingual AI**: Context-aware assistant supporting Telugu, Hindi, Kannada, and more.
- **Voice-First Experience**: Integrated Speech-to-Text (STT) and Text-to-Speech (TTS) for hands-free operations.
- **8-Stage OCR Pipeline**: Digitizing physical records into the Shishu Suraksha ecosystem with high precision.

---

## 🛠️ Technological Architecture

| Component | Technology |
| :--- | :--- |
| **Framework** | Flutter (Dart) |
| **State Management** | Riverpod / StateProvider |
| **Visualizations** | FL Chart (Customized for low-end devices) |
| **Intelligence** | Groq (LLAWA/LLaMA-3) & Gemini API |
| **OCR Backend** | Flask + Tesseract + OpenCV |
| **Local Data** | Hive / SQLite / Shared Preferences |

### 📊 Repository Composition
![Dart](https://img.shields.io/badge/Dart-58.6%25-blue)
![HTML](https://img.shields.io/badge/HTML-28.8%25-orange)
![C++](https://img.shields.io/badge/C%2B%2B-5.3%25-blueviolet)
![Python](https://img.shields.io/badge/Python-2.5%25-yellow)

---

## 📊 System Topology

```mermaid
graph TD
    %% Entry Point
    User([Platform User]) --> Intro[Lottie Animation]
    Intro --> Splash[Optimized Transition]
    Splash --> Login{Authentication}
    
    %% Role Branching
    Login -->|Teacher| Dashboard[Anganwadi Dashboard]
    Login -->|Admin| AdminDash[National Portal]

    %% Teacher Flow
    subgraph Operations [Field Operations]
        Dashboard -->|Vitals| LiveVitals[Vitals Hub]
        Dashboard -->|Assess| Assess[Developmental Suite]
        Dashboard -->|Growth| Growth[Nutrition Charts]
        Dashboard -->|Voice| VoiceAI[Voice Assistant STT/TTS]
        Dashboard -->|Digitize| OCR[8-Stage OCR Pipeline]
    end

    %% Admin Flow
    subgraph Analytics [Administrative Oversight]
        AdminDash -->|Insights| DistrictChart[District Comparison]
        AdminDash -->|Management| SchoolSearch[Precision Filtering]
        AdminDash -->|Drilldown| SchoolDetail[School Deep-Dive]
    end

    %% Data Core
    AdminDash -->|Sync| DataService[(Unified Data Core)]
    Dashboard -->|Sync| DataService
    DataService -->|Persist| Storage[(Hive/SQLite Offline)]
    
    %% AI Intelligence
    VoiceAI --- AI[Groq/Gemini LLaMA-3]
    OCR --- AI
```

---

*Shishu Suraksha - A step towards an inclusive, healthy, and developed future for every child.* 🇮🇳
