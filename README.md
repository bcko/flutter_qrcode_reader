# QRCode Reader plugin for Flutter

A Flutter plugin for reading QR Codes with the camera.

### Example

``` dart
import 'package:qrcode_reader/QRCodeReader.dart';
```

``` dart
Future<String> futureString = new QRCodeReader()
               .setAutoFocusIntervalInMs(200) // default 5000
               .setForceAutoFocus(true) // default false
               .setTorchEnabled(true) // default false
               .setHandlePermissions(true) // default true
               .setExecuteAfterPermissionGranted(true) // default true
               .scan();
```

These options are Android only, this is the simplest way of plugin usage:
``` dart
Future<String> futureString = new QRCodeReader().scan();
```