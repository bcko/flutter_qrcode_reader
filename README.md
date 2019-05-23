# QRCode Reader plugin for Flutter

A Flutter plugin for reading QR Codes with the camera.

### Example

``` dart
import 'package:qrcode_reader/qrcode_reader.dart';
```

``` dart
Future<String> futureString = new QRCodeReader()
               .setAutoFocusIntervalInMs(200) // default 5000
               .setForceAutoFocus(true) // default false
               .setTorchEnabled(true) // default false
               .setHandlePermissions(true) // default true
               .setExecuteAfterPermissionGranted(true) // default true
               .setFrontCamera(false) // default false
               .scan();
```

These options are Android only (with the exception of setFrontCamera(bool)), this is the simplest way of plugin usage:
``` dart
Future<String> futureString = new QRCodeReader().scan();
```
