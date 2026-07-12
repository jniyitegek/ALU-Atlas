# ALU Atlas 

ALU Atlas is a mobile campus directory and opportunities marketplace built with Flutter. It connects ALU student candidates directly with incubated campus ventures, facilitating real-world milestones and internship placements.

---

## Key Features

- **Dynamic Role-Based Portals**: Handles distinct user types (Students, Venture Owners, and Admins) with targeted dashboards.
- **Explore & Apply**: Students can search, save, and apply to active venture postings with custom requirements (Resume, Portfolio, Experience, etc.).
- **Venture Dashboard**: Allows startup operators to manage posted roles, view applicant candidates log, track status pipelines, and start chats.
- **Admin Control Console**: A dedicated space for institutional operators to toggle startup verification status and grant platform-wide trust badges.
- **Local Asset Fallback Strategy**: Optimizes storage budgets by saving logos locally on owner devices while serving graceful fallback initials to other network peers.
- **Real-Time Communication**: Thread-based chats linking candidate profiles with venture owners directly through tracking pages.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev/) (SDK `>=3.3.0 <4.0.0`)
- **State Management**: [Riverpod (flutter_riverpod)](https://riverpod.dev/)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Database**: [Cloud Firestore](https://firebase.google.com/products/firestore) (Real-Time Streams)
- **Auth**: [Firebase Authentication](https://firebase.google.com/products/auth)

---

##  Getting Started

### 1. Requirements
- Flutter SDK (v3.3.0 or higher)
- Android Studio or Xcode
- An active Android/iOS emulator or physical test device

### 2. Run Locally
Clone the repository and run:
```bash
flutter pub get
flutter run
```

### 3. Build Production Bundle
To compile a release-ready APK:
```bash
flutter build apk --release
```
