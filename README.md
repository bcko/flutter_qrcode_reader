# QRCode Reader plugin for Flutter

A Flutter plugin, currently for Android only, for reading QR Codes with the camera.

### Example

``` dart
import 'package:qrcode_reader/QRCodeReader.dart';
```

``` dart
Future<String> futureString = new QRCodeReader()
                                .setAutoFocusIntervalInMs(200)
                                .setForceAutoFocus(true)
                                .setTorchEnabled(true)
                                .scan();
```
