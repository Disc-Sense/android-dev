# android-dev

Flutter project for the Disc-sense application.

## Build and test

from the project directory, run: 
```bash
flutter devices
```
to view native devices available to run the app.
Then run the following command with <native-device-id> being a device that is not web-based
```bash
flutter run -d <native-device-id>
```





# Documented Bugs
## Failure after incorporating ObjectBox's Dart package
The project was using a native FFI-base implementation which imported 'dart:ffi' which is not supported by chrome/web builds.
Since web-browsers are not a main target of the app, the build target was changed to Windows, which worked but required installation
of the Visual Studio toolchain for developing Windows apps (found at https://visualstudio.microsoft.com/downloads/). Android
development requires the Android SDK (found at https://developer.android.com/studio/index.html).
