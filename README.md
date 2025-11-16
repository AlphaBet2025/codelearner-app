# CodeLearner

CodeLearner is a Flutter frontend paired with a Node.js backend. The frontend (in the project root) talks to the backend server in `backend/` for AI feedback, reports and other services.

**How to Run**

**Prerequisites:**
- **Node.js & npm**: required for the backend. Install from https://nodejs.org.
- **Flutter SDK**: required for the frontend. Install and follow setup from https://flutter.dev.
- **Android/iOS toolchains** (only if you plan to run on mobile): configure via `flutter doctor`.
- On Windows use **PowerShell** for the example commands below.

**Backend (Node.js)**
- **Location:** `backend/`
- **Install dependencies:**

```powershell
cd backend
npm install
```

- The backend uses `dotenv` and other services (MySQL, Firebase Admin, OpenAI). Create a `.env` file in `backend/` or export environment variables in your shell. Typical environment keys you may need to set (project-specific names may vary):

- `PORT` (defaults to `3000`)
- `DATABASE_HOST`, `DATABASE_USER`, `DATABASE_PASSWORD`, `DATABASE_NAME`, `DATABASE_PORT`
- `GOOGLE_APPLICATION_CREDENTIALS` (path to Firebase service-account JSON, used by `firebase-admin`)
- `OPENAI_API_KEY` (if OpenAI integration is used)

- **Run (development):**

```powershell
cd backend
$Env:OPENAI_API_KEY=""
npm run dev   # uses `node index.js`
```

- **Run (production):**

```powershell
cd backend
$Env:OPENAI_API_KEY=""
npm start
```

- The frontend expects the backend at `http://localhost:3000` by default. If you run the backend on another port or host, update the frontend constant described below.

**Frontend (Flutter)**
- **Location:** project root (contains `lib/`, `pubspec.yaml`)
- **Install packages:**

```powershell
cd C:\Workspace\codelearner_app
flutter pub get
```

- **Run on the default connected device (emulator, simulator or desktop):**

```powershell
flutter run
```

- **Run on Windows desktop (if enabled):**

```powershell
flutter run -d windows
```

- **Run on an Android emulator (example):**

```powershell
flutter emulators --launch <emulator_id>
flutter run -d <device_id>
```

- **Build release artifacts:**

```powershell
flutter build apk       # Android
flutter build windows   # Windows
```

**Important config**
- The frontend has a backend base URL constant in `lib/main.dart`:

```dart
const String backendBaseUrl = 'http://localhost:3000';
```

- If your backend runs on a different host/port, change the constant or provide a configuration mechanism before running the app.

**Troubleshooting**
- If the frontend cannot reach the backend: ensure the backend is running and listening on the correct port; open firewall or allow localhost requests.
- If you see CORS errors, make sure the backend's CORS middleware is enabled and configured to accept requests from your frontend origin.
- If Firebase services are used, set `GOOGLE_APPLICATION_CREDENTIALS` to the service account JSON path in PowerShell for the current session:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = 'C:\path\to\service-account.json'
```

- For persistent environment variables on Windows, consider using `setx` (note: requires a new shell session to take effect).

**Notes & Next steps**
- Backend scripts in `backend/package.json` include `dev` and `start` (both run `node index.js`).
- Start the backend first, then run the frontend.
- If you'd like, I can also add a `.env.example` in `backend/` that lists expected environment variables.

---

If you want, I can run `flutter pub get` and start the backend here, or add `.env.example` to the repo—which would you prefer next?
