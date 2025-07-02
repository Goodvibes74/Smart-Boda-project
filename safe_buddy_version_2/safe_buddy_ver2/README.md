# Safe Buddy

Safe Buddy is a Flutter-based web and mobile application designed to enhance personal safety for boda-boda riders and their passengers. The platform provides real-time device monitoring, crash alerts, and location tracking, ensuring help is always within reach.

## Features

- **User Authentication**: Secure login and registration for users.
- **Device Management**: Add, monitor, and manage safety devices.
- **Crash Alerts**: Receive instant notifications in case of accidents.
- **Live Location Tracking**: View device and user locations on an interactive map.
- **Notifications**: Stay updated with real-time alerts and messages.
- **Modern UI**: Clean, responsive interface with custom header and sidebar widgets.

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- A configured Firebase project

### Installation

1. **Clone the repository:**

   ```sh
   git clone https://github.com/Goodvibes74/Smart-Boda-project.git
   cd safe_buddy_version_2/safe_buddy_ver2
   ```

2. **Install dependencies:**

   ```sh
   flutter pub get
   ```

3. **Configure Firebase:**
   Ensure `firebase_options.dart` is present and configured.
   Update `web/index.html` and `firebase.json` if needed.

4. **Run the app:**

   -For web:,

   ```sh
   flutter run -d chrome
   ```

## Build for Production

-To build the web app for deployment:

```sh
flutter build web --release
```

-Deploy to Firebase Hosting:

```sh
firebase deploy --only hosting
```

## Project Structure

- `lib/`: Main Dart source files
- `widgets/`: Reusable UI components (header, sidebar, cards, map)
- `pages/`: App pages (dashboard, authentication, settings, etc.)
- `web/`: Web-specific files (`index.html`, `manifest.json`)
- `firebase.json`: Firebase Hosting configuration

## Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements and bug fixes.

## License

This project is licensed for educational purposes by Group 7 @MAKCOCIS 2025.

Developed by Group 7 @MAKCOCIS 2025
