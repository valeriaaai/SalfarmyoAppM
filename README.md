# Salfarmyo Dormitory (Android / Windows / Flutter)

Offline dormitory management app for Android and Windows, built with Flutter,
Dart, and SQLite.
The UI and local database are packaged in the APK; the installed app does not
need an internet connection, a server, or a separate SQL application.

## Included

- Animated login with floating background shapes and an entrance animation.
- Dashboard with boarder, room, available-bed, unpaid-rent, and complaint counts.
- Boarder directory with search, add/edit/delete, a rent summary, and payment history.
- Room/bedspace map grouped by building and floor; tap an open bed to assign an
  existing or new boarder. Building 1 has 2 twin rooms and 2 double-deck rooms
  on the first floor, plus 4 double-deck rooms on the second floor. Twin beds
  cost ₱2,300 per boarder/month and double-deck beds cost ₱1,800. Building 2
  has 8 solo rooms across 2 floors at ₱5,000 per boarder/month.
- Rent ledger with month and Paid/Unpaid filters, automatically created monthly
  charges for occupied beds, editable rent records, payment recording, and
  per-boarder payment history. Each new month starts with a separate unpaid
  charge while earlier months and payments remain in the ledger.
- Complaint list with search, status filters, and status changes.
- Local SQLite tables based on the Python prototype's schema.
- Layouts built with scrolling and flexible Flutter widgets for different screen sizes.

## First run data

The first launch creates a private `salfarmyo.db` in Android's app data folder,
then creates the owner and the configured room/bed layout. Existing local
databases are migrated to the updated layout while retaining boarder and rent
records. On a new install, boarders, rent, payments, and complaints start
empty; records you add are saved in this local database.
Starter login:

```text
Username: admin
Password: admin123
```

This is a demonstration account; changing the password is not yet available in
the UI. Implement a change-password flow before deploying the app with real
resident data. Updating from the previous app version removes only the bundled
demo residents and their related sample records. Uninstalling the app clears
its private database. The desktop `salfarmyo.db` is not automatically copied
into the Android app; they are separate local databases.

## Main workflow
After login, open the dashboard, then use the Rooms tab to select an available
bed and assign an existing boarder or add a new one. The saved boarder and room
assignment appear in the searchable Boarders tab, where selecting a boarder
opens their summary and payment history. The Rent tab opens on the current
billing month, creates that month's charge from each occupied room's monthly
rate, and lets you filter by month/status, edit charges, record payments, and
mark a remaining balance paid. Older months remain available from the month
filter, and payment history is retained.
Complaints can be filtered by status and updated as they are handled.

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

## Run the Windows desktop version

The project also includes a Windows desktop runner, so you can demonstrate the
app on this PC if an Android emulator is unavailable. Install Visual Studio with
the **Desktop development with C++** workload, then from this `flutter_app`
directory run:

```powershell
flutter pub get
flutter devices
flutter run -d windows
```

Windows uses SQLite FFI and stores its database in the Windows application
support directory. Android continues to use its existing SQLite plugin and
keeps its database in Android app storage. These databases are separate; running
the Windows version does not change or prevent building the Android APK.

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
