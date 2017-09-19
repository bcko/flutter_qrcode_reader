// Copyright (c) <2017> <Matheus Villela>
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'dart:async';

import 'package:flutter/services.dart';

class QRCodeReader {
  static const MethodChannel _channel = const MethodChannel('qrcode_reader');

  int _autoFocusIntervalInMs = 5000;
  bool _forceAutoFocus = false;
  bool _torchEnabled = false;
  bool _handlePermissions = true;
  bool _executeAfterPermissionGranted = true;

  QRCodeReader setAutoFocusIntervalInMs(int autoFocusIntervalInMs) {
    _autoFocusIntervalInMs = autoFocusIntervalInMs;
    return this;
  }

  QRCodeReader setForceAutoFocus(bool forceAutoFocus) {
    _forceAutoFocus = forceAutoFocus;
    return this;
  }

  QRCodeReader setTorchEnabled(bool torchEnabled) {
    _torchEnabled = torchEnabled;
    return this;
  }

  QRCodeReader setHandlePermissions(bool handlePermissions) {
    _handlePermissions = handlePermissions;
    return this;
  }

  QRCodeReader setExecuteAfterPermissionGranted(bool executeAfterPermissionGranted) {
    _executeAfterPermissionGranted = executeAfterPermissionGranted;
    return this;
  }

  Future<String> scan() async {
    Map params = <String, dynamic>{
      "autoFocusIntervalInMs": _autoFocusIntervalInMs,
      "forceAutoFocus": _forceAutoFocus,
      "torchEnabled": _torchEnabled,
      "handlePermissions": _handlePermissions,
      "executeAfterPermissionGranted": _executeAfterPermissionGranted,
    };
    return await _channel.invokeMethod('readQRCode', params);
  }
}
