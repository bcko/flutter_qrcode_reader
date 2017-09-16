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

package com.matheusvillela.flutter.plugins.qrcodereader;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Process;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;

public class QRCodeReaderPlugin implements MethodCallHandler, ActivityResultListener {
    private static final String CHANNEL = "qrcode_reader";

    private static final int REQUEST_CODE_SCAN_ACTIVITY = 2777;
    private static QRCodeReaderPlugin instance;

    private Activity activity;
    private Result pendingResult;

    public QRCodeReaderPlugin(Activity activity) {
        this.activity = activity;
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
        if (instance == null) {
            final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);
            instance = new QRCodeReaderPlugin(registrar.activity());
            registrar.addActivityResultListener(instance);
            channel.setMethodCallHandler(instance);
        }
    }


    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (pendingResult != null) {
            result.error("ALREADY_ACTIVE", "QR Code reader is already active", null);
            return;
        }
        pendingResult = result;
        if (call.method.equals("readQRCode")) {
            if (!(call.arguments instanceof Map)) {
                throw new IllegalArgumentException("Plugin not passing a map as parameter: " + call.arguments);
            }
            int currentApiVersion = android.os.Build.VERSION.SDK_INT;
            if (currentApiVersion >= android.os.Build.VERSION_CODES.M) {
                if (checkSelfPermission(activity,
                        Manifest.permission.CAMERA)
                        != PackageManager.PERMISSION_GRANTED) {
                    if (shouldShowRequestPermissionRationale(activity,
                            Manifest.permission.CAMERA)) {
                        // TODO: user should be explained why the app needs the permission
                        activity.requestPermissions(new String[]{Manifest.permission.CAMERA}, 1);
                    } else {
                        activity.requestPermissions(new String[]{Manifest.permission.CAMERA}, 1);
                    }
                    pendingResult.error("permission", "you don't have the user permission to access the camera", null);
                    pendingResult = null;
                } else {
                    startView((Map<String, Object>) call.arguments);
                }
            } else {
                startView((Map<String, Object>) call.arguments);
            }
        } else {
            throw new IllegalArgumentException("Unknown method " + call.method);
        }
    }

    private boolean shouldShowRequestPermissionRationale(Activity activity,
                                                         String permission) {
        if (Build.VERSION.SDK_INT >= 23) {
            return activity.shouldShowRequestPermissionRationale(permission);
        }
        return false;
    }

    private int checkSelfPermission(Context context, String permission) {
        if (permission == null) {
            throw new IllegalArgumentException("permission is null");
        }
        return context.checkPermission(permission, android.os.Process.myPid(), Process.myUid());
    }


    private void startView(Map<String, Object> arguments) {
        Intent intent = new Intent(activity, QRScanActivity.class);
        intent.putExtra(QRScanActivity.EXTRA_FOCUS_INTERVAL, (int) arguments.get("autoFocusIntervalInMs"));
        intent.putExtra(QRScanActivity.EXTRA_FORCE_FOCUS, (boolean) arguments.get("forceAutoFocus"));
        intent.putExtra(QRScanActivity.EXTRA_TORCH_ENABLED, (boolean) arguments.get("torchEnabled"));
        activity.startActivityForResult(intent, REQUEST_CODE_SCAN_ACTIVITY);
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_SCAN_ACTIVITY) {
            if (resultCode == Activity.RESULT_OK) {
                String string = data.getStringExtra(QRScanActivity.EXTRA_RESULT);
                pendingResult.success(string);
            } else {
                pendingResult.success(null);
            }
            pendingResult = null;
            return true;
        }
        return false;
    }
}
