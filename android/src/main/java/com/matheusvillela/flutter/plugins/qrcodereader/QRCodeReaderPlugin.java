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
import android.annotation.TargetApi;
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

public class QRCodeReaderPlugin implements MethodCallHandler, ActivityResultListener, PluginRegistry.RequestPermissionsResultListener {
    private static final String CHANNEL = "qrcode_reader";

    private static final int REQUEST_CODE_SCAN_ACTIVITY = 2777;
    private static final int REQUEST_CODE_CAMERA_PERMISSION = 3777;
    //    private static QRCodeReaderPlugin instance;

    private Activity activity;
    private Result pendingResult;
    private Map<String, Object> arguments;
    private boolean executeAfterPermissionGranted;

    public QRCodeReaderPlugin(Activity activity) {
        this.activity = activity;
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
	//        if (instance == null) {
            final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);
            final QRCodeReaderPlugin instance = new QRCodeReaderPlugin(registrar.activity());
            registrar.addActivityResultListener(instance);
            registrar.addRequestPermissionsResultListener(instance);
            channel.setMethodCallHandler(instance);
	    // }
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
            arguments = (Map<String, Object>) call.arguments;
            boolean handlePermission = (boolean) arguments.get("handlePermissions");
            this.executeAfterPermissionGranted = (boolean) arguments.get("executeAfterPermissionGranted");

            if (checkSelfPermission(activity,
                    Manifest.permission.CAMERA)
                    != PackageManager.PERMISSION_GRANTED) {
                if (shouldShowRequestPermissionRationale(activity,
                        Manifest.permission.CAMERA)) {
                    // TODO: user should be explained why the app needs the permission
                    if (handlePermission) {
                        requestPermissions();
                    } else {
                        setNoPermissionsError();
                    }
                } else {
                    if (handlePermission) {
                        requestPermissions();
                    } else {
                        setNoPermissionsError();
                    }
                }
            } else {
                startView();
            }
        } else {
            throw new IllegalArgumentException("Unknown method " + call.method);
        }
    }

    @TargetApi(Build.VERSION_CODES.M)
    private void requestPermissions() {
        activity.requestPermissions(new String[]{Manifest.permission.CAMERA}, REQUEST_CODE_CAMERA_PERMISSION);
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


    private void startView() {
        Intent intent = new Intent(activity, QRScanActivity.class);
        intent.putExtra(QRScanActivity.EXTRA_FOCUS_INTERVAL, (int) arguments.get("autoFocusIntervalInMs"));
        intent.putExtra(QRScanActivity.EXTRA_FORCE_FOCUS, (boolean) arguments.get("forceAutoFocus"));
        intent.putExtra(QRScanActivity.EXTRA_TORCH_ENABLED, (boolean) arguments.get("torchEnabled"));
        intent.putExtra(QRScanActivity.EXTRA_FRONT_CAMERA, (boolean) arguments.get("frontCamera"));
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
            arguments = null;
            return true;
        }
        return false;
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode == REQUEST_CODE_CAMERA_PERMISSION) {
            for (int i = 0; i < permissions.length; i++) {
                String permission = permissions[i];
                int grantResult = grantResults[i];

                if (permission.equals(Manifest.permission.CAMERA)) {
                    if (grantResult == PackageManager.PERMISSION_GRANTED) {
                        if (executeAfterPermissionGranted) {
                            startView();
                        }
                    } else {
                        setNoPermissionsError();
                    }
                }
            }
        }
        return false;
    }

    private void setNoPermissionsError() {
        pendingResult.error("permission", "you don't have the user permission to access the camera", null);
        pendingResult = null;
        arguments = null;
    }
}
