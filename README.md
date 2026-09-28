# Home Debit

Home Debit is a Flutter learning app for customer registration and profile
display. The Flutter UI calls the sibling Spring Boot API to persist customer
registrations in PostgreSQL.

## Documentation

Start at the [documentation index](./docs/index.md) for:

- Week 1 exercises and Flutter concept explanations
- Frontend structure and behavior
- Backend API, persistence, and configuration
- Local setup and run instructions

## Quick start

### Flutter UI

From this directory:

```powershell
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5100
```

Open `http://127.0.0.1:5100/`.

### Backend and database

The Spring Boot project is in the sibling `home-debit` directory. Use Java 25.
From that project directory:

```powershell
docker compose up -d
.\gradlew.bat bootRun
```

The API listens on `http://localhost:8080`. See
[Local development](./docs/local-development.md) for full commands, tests, and
shutdown details.

### Connect the Flutter UI

The UI posts registrations to `POST /api/customers`. Its default API URL is
`http://localhost:8080` on web and most desktop/iOS simulator targets, and
`http://10.0.2.2:8080` on the Android emulator. Override the host when needed:

```powershell
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5100 `
  --dart-define=API_BASE_URL=http://localhost:8080
```

For a physical phone, set `API_BASE_URL` to the development machine's reachable
LAN address. See [Local development](./docs/local-development.md) for details.

## Tests

From this directory:

```powershell
flutter analyze
flutter test
```

Backend integration tests use Testcontainers and require Docker:

```powershell
.\gradlew.bat test
```

Flutter tests mock HTTP and do not require a running backend.
