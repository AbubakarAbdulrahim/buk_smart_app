# SmartBUK

A mobile app built for students of Bayero University, Kano (BUK) — a single place for campus incident reporting, lost & found, campus updates, academic resources, and an in-app AI assistant that knows how the app works.

## What it does

- **Auth & profile** — registration and login (email/password via Firebase Auth), with matric number, program, level, and faculty captured as profile data; onboarding flow and password recovery
- **Home** — recent activity feed, carousel, and notifications, with quick-action shortcuts (reporting an incident is one tap away)
- **Incident reporting** — students can report campus incidents with a type, description, location, and optional photo
- **Lost & Found** — a full flow for posting a lost or found item (category, description, location, contact info, optional photo, color/brand/unique-feature fields), browsing listings, bookmarking items, and a detail view; posts can be marked resolved and verified
- **Campus Updates** — a feed of campus announcements (e.g. seminars, lectures) with a detail view per update
- **Map** — a campus map screen
- **Resources** — past exam questions and project/SIWES guidelines, filterable by faculty, department, program, level, semester, and course
- **Emergency Contacts** — quick access to official security lines, plus an SOS option to call emergency services directly
- **Smart AI** — a floating action button opens an in-app AI assistant (Gemini 2.5 Flash) with chat history, styled to match the app's own BUK colors rather than looking like a bolted-on chat widget. It's scoped specifically to help students navigate the app and answer study/academic questions — it's told not to invent system stats or fake data
- **Notifications** — an in-app notification center with detail views
- **Analytics** — an analytics screen (usage/activity insights)

## Architecture

```
lib/
├── config/
│   └── gemini_config.dart      # Gemini API key (via --dart-define) + Smart AI system prompt
├── core/
│   ├── constants/
│   ├── providers/               # App-wide, campus updates, notifications
│   ├── routes/
│   ├── theme/                   # app_colors, app_theme
│   └── utils/
├── models/                      # Incident, LostFoundItem, PastQuestion
├── screens/
│   ├── auth/            # onboarding, login, register, forgot password
│   ├── common/          # splash, auth gate, async state view
│   ├── home/            # app_shell (bottom nav), home, Smart AI page
│   ├── lost_found/      # list, detail, wizard (posting flow), bookmarks
│   ├── report/          # incident reporting
│   ├── updates/         # campus updates list + detail
│   ├── resources/
│   ├── map/
│   ├── notification/
│   ├── emergency/
│   ├── analytics/
│   └── profile/
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── cloudinary_service.dart
│   ├── image_picker_service.dart
│   ├── notification_service.dart
│   ├── gemini_service.dart          # Calls the Gemini REST API directly
│   └── smart_ai_repository.dart     # Chat history persistence for Smart AI
├── widgets/
├── app.dart
└── main.dart
```

Navigation runs through a bottom-nav `AppShell` (Home, Map, Lost & Found, Resources, Profile), with the Smart AI assistant available everywhere via a floating action button rather than living inside the tab structure. Firestore backs incidents, lost & found posts, campus updates, and resources; images go through Cloudinary.

## Tech stack

| Layer | Choice |
|---|---|
| Framework | Flutter |
| State management | Provider |
| Backend | Firebase (Auth, Cloud Firestore, Cloud Messaging, Storage) |
| Media | Cloudinary |
| AI | Google Gemini 2.5 Flash, called directly via REST, key supplied through `--dart-define` |
| Maps | flutter_map + latlong2 |
| Icons | Phosphor Flutter |

## Running locally

1. Clone the repo and check out this branch:
   ```
   git clone https://github.com/AbubakarAbdulrahim/buk_smart_app.git
   cd buk_smart_app
   git checkout submain
   cd user
   flutter pub get
   ```
2. Set up your own Firebase project (Authentication, Firestore, Cloud Messaging, Storage) and generate your own `firebase_options.dart` via `flutterfire configure`.
3. Run with your own Gemini key passed at build/run time — this project already does this the right way, so just supply your key:
   ```
   flutter run --dart-define=GEMINI_API_KEY=your_key_here
   ```

## Project background

SmartBUK was built to give BUK students a single app for the day-to-day logistics of campus life — reporting incidents, recovering lost items, and finding academic resources — plus an AI assistant that's grounded in how the app itself works rather than a generic chatbot bolted on for its own sake.
