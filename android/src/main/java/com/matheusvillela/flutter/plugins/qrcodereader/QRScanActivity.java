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

import android.app.Activity;
import android.content.Intent;
import android.graphics.PointF;
import android.os.Bundle;

import com.dlazaro66.qrcodereaderview.QRCodeReaderView;

public class QRScanActivity extends Activity implements QRCodeReaderView.OnQRCodeReadListener {

    private boolean qrRead;
    private QRCodeReaderView view;

    public static String EXTRA_RESULT = "extra_result";

    public static String EXTRA_FOCUS_INTERVAL = "extra_focus_interval";
    public static String EXTRA_FORCE_FOCUS = "extra_force_focus";
    public static String EXTRA_TORCH_ENABLED = "extra_torch_enabled";
    public static String EXTRA_FRONT_CAMERA = "extra_front_camera";

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_qr_read);
        view = (QRCodeReaderView) findViewById(R.id.activity_qr_read_reader);
        Intent intent = getIntent();
        view.setOnQRCodeReadListener(this);
        view.setQRDecodingEnabled(true);
        if (intent.getBooleanExtra(EXTRA_FORCE_FOCUS, false)) {
            view.forceAutoFocus();
        }
        view.setAutofocusInterval(intent.getIntExtra(EXTRA_FOCUS_INTERVAL, 2000));
        view.setTorchEnabled(intent.getBooleanExtra(EXTRA_TORCH_ENABLED, false));
        if (intent.getBooleanExtra(EXTRA_FRONT_CAMERA, false)) {
            view.setFrontCamera();
        }
    }

    @Override
    public void onQRCodeRead(String text, PointF[] points) {
        if (!qrRead) {
            synchronized (this) {
                qrRead = true;
                Intent data = new Intent();
                data.putExtra(EXTRA_RESULT, text);
                setResult(Activity.RESULT_OK, data);
                finish();
            }
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        view.startCamera();
    }

    @Override
    protected void onPause() {
        super.onPause();
        view.stopCamera();
    }
}