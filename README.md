# Agile Sprint Simulation

Agile Sprint Simulation is a full-stack training app with a Next.js frontend and NestJS backend.

## Web App

### Prerequisites
- Node.js 18+
- npm

### Run Backend
```bash
cd backend
npm install
npm run start:dev
```

The backend runs on `http://localhost:3001`.

### Run Frontend
```bash
cd frontend
npm install
npm run dev
```

The frontend runs on `http://localhost:3000`.

## Mobile App

A new standalone Flutter mobile app lives in `mobile/` and mirrors the web functionality for iOS and Android.

### Prerequisites
- Flutter SDK 3.2+
- Dart SDK (bundled with Flutter)
- Android Studio and/or Xcode for device/simulator tooling

### Setup
```bash
cd mobile
flutter pub get
```

If your machine does not yet have generated native platform files, run:

```bash
flutter create .
```

### Run
```bash
flutter run
```

### Run On Physical Android Phone
1. Connect your phone by USB and enable Developer options + USB debugging.
2. Verify your device is visible:

```bash
flutter devices
```

3. Run on the detected Android device id:

```bash
flutter run -d <device-id>
```

4. In the app, go to Settings -> Backend Connection and set API URL to your computer LAN IP, for example:

```PC LAN address
http://192.168.114.240:3001
```

Do not use `localhost` on a physical phone.

### Build APK For Download/Install
```bash
cd mobile
flutter build apk --release
```

Output APK:
- `mobile/build/app/outputs/flutter-apk/app-release.apk`

Install to connected phone:

```bash
flutter install -d <device-id>
```

### Test
```bash
flutter test
```

### Notes
- Architecture and feature parity mapping: `mobile/MOBILE_NOTES.md`
- Mobile app uses a hybrid data strategy:
	- Calls existing backend APIs when reachable
	- Falls back to local persisted cache using `shared_preferences`
- Android app now supports HTTP local-network backends (`android:usesCleartextTraffic="true"`).
# Agile-Sprint-Simulation
