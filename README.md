# Salfarmyo Dormitory (Android / Flutter)

Offline Android dormitory management app built with Flutter, Dart, and SQLite.
The UI and local database are packaged in the APK; the installed app does not
need an internet connection, a server, or a separate SQL application.

## Included

- Animated login with floating background shapes and an entrance animation.
- Dashboard with boarder, room, available-bed, unpaid-rent, and complaint counts.
- Boarder directory with search, add/edit/delete, details, and payment history.
- Room/bedspace map for the seeded buildings; tap an open bed to assign a resident.
- Rent ledger with search, monthly rent records, payment recording, and balances.
- Complaint list with search and status changes.
- Local SQLite tables based on the Python prototype's schema.
- Layouts built with scrolling and flexible Flutter widgets for different screen sizes.

## First run data

The first launch creates a private `salfarmyo.db` in Android's app data folder,
then creates the owner, rooms, beds, sample residents, rent records, and
complaints. Starter login:

```text
Username: admin
Password: admin123
```

This is a demonstration account; changing the password is not yet available in
the UI. Implement a change-password flow before deploying the app with real
resident data. Uninstalling the app clears its private database. The desktop
`salfarmyo.db` is not automatically copied into the Android app; they are
separate local databases.

## Tools to install on Windows

1. Install the Flutter stable SDK and add its `bin` folder to `PATH`.
2. Install Android Studio. In Android Studio's SDK Manager, install Android SDK
   Platform, Android SDK Build-Tools, and Android SDK Platform-Tools.
3. Accept the SDK licenses in PowerShell:

   ```powershell
   flutter doctor --android-licenses
   flutter doctor
   ```

   Resolve any Android toolchain errors reported by `flutter doctor`.
4. Install Visual Studio Code if you want an editor; it is optional. The Flutter
   and Dart VS Code extensions are helpful but not needed to build the APK.
   Android Studio can also edit and build this project.

No MySQL, SQL Server, SQLite Browser, or database server is needed on the phone.
SQLite is embedded in the application. Network access is not used by the app.

## Run on an Android phone

1. On the phone, open **Settings → About phone** and tap **Build number** seven
   times to enable Developer options. In **Developer options**, enable **USB
   debugging**.
2. Connect the phone with a USB data cable, approve the debugging prompt on the
   phone, and in PowerShell check that it appears:

   ```powershell
   flutter devices
   ```

   If Windows does not detect the phone, install its manufacturer's USB driver
   and try another data-capable cable/USB port.
3. From this `flutter_app` directory, install dependencies and launch:

   ```powershell
   flutter pub get
   flutter run
   ```

   Select the attached phone if Flutter asks which device to use. The app itself
   works offline; the first build may need internet to download Flutter packages
   and Android build dependencies.
4. To use an emulator instead, create and start an Android Virtual Device in
   Android Studio's **Device Manager**, then run `flutter devices` followed by
   `flutter run`.

## Build and install an APK

In PowerShell, from this `flutter_app` directory:

```powershell
flutter pub get
flutter build apk --release
```

The APK is written to:

```text
build\app\outputs\flutter-apk\app-release.apk
```

To install directly onto a USB-connected phone, run:

```powershell
flutter install
```

Or copy `app-release.apk` to the phone (USB file transfer, or another trusted
transfer method), open it from the phone's file manager, and approve **Install
unknown apps** for that file manager if Android asks. No computer/cable is needed
after the APK has been copied. The local release build is for testing/sideloading;
publishing to Google Play requires configuring a production signing key.

For later builds, repeat the release build and install/copy the newly generated
APK. App data normally remains when updating the same application without
uninstalling it. Back up important records before uninstalling or replacing app
data.

## Checks

Run from this directory:

```powershell
dart format lib test
flutter analyze
flutter test
flutter build apk --release
```
