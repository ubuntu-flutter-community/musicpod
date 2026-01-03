# Plan van Aanpak: Google Drive Synchronisatie voor MusicPod

## Overzicht

| Aspect | Details |
|--------|---------|
| **Doel** | Automatische sync tussen Linux desktop en Android via Google Drive |
| **Geschatte complexiteit** | Gemiddeld-Hoog |
| **Benodigde packages** | `googleapis`, `google_sign_in`, `extension_google_sign_in_as_googleapis_auth` |
| **Sync folder** | `MusicPod/` in Google Drive root |
| **Sync trigger** | Bij app start en app stop |
| **Platforms** | Android + Linux (beide met Google Sign-In) |

---

## Architectuur

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│   Linux App     │◄───────►│   Google Drive   │◄───────►│  Android App    │
│                 │         │   /MusicPod/     │         │                 │
│  Local JSON     │  Sync   │   sync_data.json │  Sync   │  Local JSON     │
│  SharedPrefs    │◄───────►│   sync_log.json  │◄───────►│  SharedPrefs    │
└─────────────────┘         └──────────────────┘         └─────────────────┘
```

### Sync Flow

```
App Start:
1. Check of gebruiker is ingelogd bij Google
2. Haal remote timestamp op van sync_data.json
3. Vergelijk met lokale timestamp
4. Als remote nieuwer → Download en merge
5. Als lokaal nieuwer → Upload naar cloud
6. Log sync actie

App Stop:
1. Check of er lokale wijzigingen zijn sinds laatste sync
2. Als ja → Upload naar cloud
3. Log sync actie
```

---

## Te synchroniseren data

| Data | Bron | Prioriteit |
|------|------|------------|
| **Playlists** | `playlists.json` | 🔴 Hoog |
| **Liked Songs** | `likedAudios.json` | 🔴 Hoog |
| **Podcast abonnementen** | SharedPrefs: `podcastFeedUrls` | 🔴 Hoog |
| **Podcast metadata** | SharedPrefs: `{feedUrl}_*` keys | 🔴 Hoog |
| **Podcast voortgang** | `lastPositions.json` (podcast URLs) | 🔴 Hoog |
| **Radio favorieten** | SharedPrefs: `starredStations` | 🟡 Gemiddeld |
| **Favoriete albums** | SharedPrefs: `favoriteAlbums` | 🟡 Gemiddeld |
| **Favoriete tags/landen** | SharedPrefs: `favRadioTags`, `favCountryCodes` | 🟢 Laag |

---

## Bestandsstructuur

### Nieuwe bestanden in project

```
lib/sync/
├── sync_service.dart              # Hoofdlogica voor sync
├── google_drive_service.dart      # Google Drive API wrapper
├── sync_model.dart                # ViewModel voor sync status
├── sync_data.dart                 # Data model voor sync payload
├── sync_log.dart                  # Sync history model
└── view/
    ├── sync_settings_section.dart # UI sectie in settings
    ├── sync_status_widget.dart    # Status indicator widget
    └── sync_history_dialog.dart   # Dialog voor sync history
```

### Bestanden in Google Drive `/MusicPod/`

```
MusicPod/
├── sync_data.json      # Gesynchroniseerde data
└── sync_log.json       # Sync history (laatste 50 entries)
```

---

## Data Models

### SyncData

```dart
class SyncData {
  final DateTime timestamp;
  final String deviceId;
  final String deviceName;
  final String appVersion;

  // Playlists: Map van playlist naam naar lijst van Audio objects
  final Map<String, List<Audio>> playlists;

  // Liked songs
  final List<Audio> likedAudios;

  // Podcasts
  final List<String> podcastFeedUrls;
  final Map<String, PodcastMeta> podcastMetadata;

  // Radio
  final List<String> starredStations;
  final List<String> favRadioTags;
  final List<String> favCountryCodes;
  final List<String> favLanguageCodes;

  // Albums
  final List<String> favoriteAlbums;

  // Playback progress (alleen voor podcasts/radio)
  final Map<String, int> lastPositions; // URL -> milliseconds

  // Serialization
  Map<String, dynamic> toJson();
  factory SyncData.fromJson(Map<String, dynamic> json);
}
```

### SyncLogEntry

```dart
class SyncLogEntry {
  final DateTime timestamp;
  final String deviceId;
  final String deviceName;
  final SyncAction action;        // upload, download, merge
  final SyncTrigger trigger;      // appStart, appStop, manual
  final int itemsSynced;
  final String? error;

  Map<String, dynamic> toJson();
  factory SyncLogEntry.fromJson(Map<String, dynamic> json);
}

enum SyncAction { upload, download, merge, noChange }
enum SyncTrigger { appStart, appStop, manual }
```

### SyncStatus

```dart
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  offline,
  notSignedIn,
}

class SyncState {
  final SyncStatus status;
  final DateTime? lastSyncTime;
  final String? lastError;
  final String? userEmail;
}
```

---

## Services

### GoogleDriveService

```dart
class GoogleDriveService {
  // === Authenticatie ===
  Future<GoogleSignInAccount?> signIn();
  Future<void> signOut();
  bool get isSignedIn;
  String? get userEmail;
  GoogleSignInAccount? get currentUser;

  // === Folder Management ===
  /// Vindt of maakt de MusicPod folder in Drive root
  Future<String> getOrCreateMusicPodFolder();

  // === Sync Data Operations ===
  /// Download sync_data.json van Drive
  Future<SyncData?> downloadSyncData();

  /// Upload sync_data.json naar Drive
  Future<void> uploadSyncData(SyncData data);

  /// Haal alleen timestamp op (voor snelle check)
  Future<DateTime?> getRemoteTimestamp();

  // === Sync Log Operations ===
  /// Download sync history
  Future<List<SyncLogEntry>> downloadSyncLog();

  /// Voeg entry toe aan sync log
  Future<void> appendSyncLog(SyncLogEntry entry);
}
```

### SyncService

```dart
class SyncService extends ChangeNotifier {
  // === Status ===
  SyncState get state;
  Stream<SyncState> get stateStream;

  // === Sync Operations ===
  /// Volledige sync (vergelijk timestamps, upload of download)
  Future<SyncResult> sync({SyncTrigger trigger = SyncTrigger.manual});

  /// Sync bij app start
  Future<void> syncOnStartup();

  /// Sync bij app stop
  Future<void> syncOnShutdown();

  // === Data Collection ===
  /// Verzamel alle lokale data voor sync
  Future<SyncData> collectLocalData();

  /// Pas remote data toe op lokale storage
  Future<void> applyRemoteData(SyncData remote);

  // === Conflict Resolution ===
  /// Merge lokale en remote data
  SyncData mergeData(SyncData local, SyncData remote);

  // === History ===
  Future<List<SyncLogEntry>> getSyncHistory();
}
```

---

## Conflict Resolution Strategie

| Data type | Strategie | Uitleg |
|-----------|-----------|--------|
| **Playlists** | Merge by name | Playlists met zelfde naam: neem nieuwste. Unieke playlists: behoud beide. |
| **Liked songs** | Union | Combineer beide lijsten, verwijder duplicaten |
| **Podcasts** | Union | Combineer abonnementen |
| **Podcast progress** | Max | Neem hoogste positie (verste voortgang) |
| **Radio stations** | Union | Combineer favorieten |
| **Albums** | Union | Combineer favorieten |

---

## UI Integratie

### Settings Pagina

```
Instellingen
├── ... bestaande secties ...
│
└── 🔄 Cloud Synchronisatie
    │
    ├── [Niet ingelogd]
    │   └── [🔑 Inloggen met Google]
    │
    └── [Ingelogd als user@gmail.com]
        ├── Laatste sync: 5 minuten geleden ✓
        ├── [🔄 Nu synchroniseren]
        ├── [📋 Sync geschiedenis]
        └── [🚪 Uitloggen]
```

### Sync Status Indicator

Klein icoon in de sidebar/header:

| Status | Icoon | Kleur |
|--------|-------|-------|
| Syncing | 🔄 (animated) | Blauw |
| Success | ✓ | Groen |
| Error | ⚠ | Rood |
| Offline | 📵 | Grijs |
| Not signed in | - | Geen icoon |

### Sync History Dialog

```
┌─────────────────────────────────────────┐
│ Sync Geschiedenis                    [X]│
├─────────────────────────────────────────┤
│ 📤 Vandaag 14:32 - Linux Desktop        │
│    Geüpload: 3 playlists, 12 podcasts   │
│                                         │
│ 📥 Vandaag 09:15 - Pixel Fold           │
│    Gedownload: 2 nieuwe podcasts        │
│                                         │
│ 📤 Gisteren 22:45 - Linux Desktop       │
│    Geüpload: 1 playlist aangepast       │
│                                         │
│ ... meer entries ...                    │
└─────────────────────────────────────────┘
```

---

## Platform-specifieke Setup

### Android

1. **Google Cloud Console**
   - Maak OAuth 2.0 Client ID (Android)
   - Voeg SHA-1 fingerprint toe (debug + release)

2. **Bestanden**
   - `android/app/google-services.json` (optioneel, voor Firebase)

3. **AndroidManifest.xml**
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   ```

### Linux

1. **Google Cloud Console**
   - Maak OAuth 2.0 Client ID (Desktop)
   - Download credentials JSON

2. **Implementatie**
   - Gebruik `url_launcher` voor OAuth flow
   - Local HTTP server voor callback
   - Of: handmatige code invoer

3. **Credentials opslag**
   - Environment variable of
   - Compile-time constant of
   - Lokaal bestand (niet in git)

---

## Dependencies

```yaml
# pubspec.yaml - toe te voegen
dependencies:
  google_sign_in: ^6.2.1
  googleapis: ^13.2.0
  extension_google_sign_in_as_googleapis_auth: ^2.0.12
  flutter_secure_storage: ^9.2.2  # Voor token opslag
  uuid: ^4.4.2                     # Voor device ID generatie
```

---

## Implementatie Stappen

### Fase 1: Setup (2-3 uur)
- [ ] Dependencies toevoegen aan pubspec.yaml
- [ ] Google Cloud Console project aanmaken
- [ ] OAuth credentials configureren (Android + Desktop)
- [ ] Android SHA-1 fingerprints toevoegen

### Fase 2: Google Drive Service (4-5 uur)
- [ ] `GoogleDriveService` class implementeren
- [ ] Sign-in flow voor Android
- [ ] Sign-in flow voor Linux (desktop OAuth)
- [ ] Folder creatie in Drive
- [ ] File upload/download operaties
- [ ] Error handling

### Fase 3: Data Models (2 uur)
- [ ] `SyncData` model met JSON serialization
- [ ] `SyncLogEntry` model
- [ ] `SyncState` en status enums
- [ ] Unit tests voor serialization

### Fase 4: Sync Service (5-6 uur)
- [ ] `SyncService` class implementeren
- [ ] Lokale data verzamelen uit bestaande services
- [ ] Remote data toepassen op lokale services
- [ ] Timestamp vergelijking logica
- [ ] Conflict resolution implementeren
- [ ] Sync history logging

### Fase 5: App Integration (3-4 uur)
- [ ] Sync bij app start integreren in `main.dart`
- [ ] Sync bij app stop via `WidgetsBindingObserver`
- [ ] Dependency injection in `register.dart`
- [ ] Error handling en retry logica

### Fase 6: UI (3-4 uur)
- [ ] Sync settings sectie in Settings pagina
- [ ] Login/logout UI
- [ ] Sync status indicator widget
- [ ] Sync history dialog
- [ ] Loading states en error messages

### Fase 7: Testing (3-4 uur)
- [ ] Test op Android device
- [ ] Test op Linux desktop
- [ ] Test sync tussen beide platforms
- [ ] Test conflict scenarios
- [ ] Test offline gedrag

---

## Totale Geschatte Tijd

| Fase | Uren |
|------|------|
| Setup | 2-3 |
| Google Drive Service | 4-5 |
| Data Models | 2 |
| Sync Service | 5-6 |
| App Integration | 3-4 |
| UI | 3-4 |
| Testing | 3-4 |
| **Totaal** | **22-28 uur** |

---

## Toekomstige Uitbreidingen (niet in scope)

- [ ] Sync bij elke wijziging (met debounce)
- [ ] Selective sync (keuze wat te syncen)
- [ ] Meerdere cloud providers (Dropbox, OneDrive)
- [ ] Offline queue voor sync acties
- [ ] Sync conflict UI (handmatige resolution)
- [ ] Backup/restore functionaliteit
- [ ] Sync encryption (extra beveiligingslaag)

---

## Beslissingen

| Vraag | Beslissing |
|-------|------------|
| Selective sync? | ❌ Nee - alles wordt gesynchroniseerd |
| Wanneer syncen? | ✅ Bij app start en app stop |
| Sync history? | ✅ Ja - laatste 50 entries |
| Linux Google Sign-In? | ✅ Ja - beide platforms |
| Auto-sync bij wijziging? | ❌ Nee - alleen start/stop (voor nu) |

---

*Document aangemaakt: januari 2026*
*Project: MusicPod Google Drive Sync*
*Branch: claude/test-linux-android-versions-YgXVn*
