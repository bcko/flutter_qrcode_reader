# QRCode Scanner plugin for Flutter

A Flutter plugin, currently for Android only, for reading QR Codes with the camera.

### Example

``` dart
Future<String> futureString = new QRCodeReader()
                                .setAutoFocusIntervalInMs(200)
                                .setForceAutoFocus(true)
                                .setTorchEnabled(true)
                                .scan();
```
