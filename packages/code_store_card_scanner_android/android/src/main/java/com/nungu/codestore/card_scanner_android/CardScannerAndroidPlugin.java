package com.nungu.codestore.card_scanner_android;

import androidx.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.text.Text;
import com.google.mlkit.vision.text.TextRecognition;
import com.google.mlkit.vision.text.TextRecognizer;
import com.google.mlkit.vision.text.latin.TextRecognizerOptions;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.ArrayList;
import java.util.List;

public class CardScannerAndroidPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;
    private TextRecognizer recognizer;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "com.nungu.codestore/card_scanner_android");
        channel.setMethodCallHandler(this);
        recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if ("processFrame".equals(call.method)) {
            try {
                byte[] bytes = call.argument("bytes");
                Integer width = call.argument("width");
                Integer height = call.argument("height");
                Integer rotation = call.argument("rotation");

                if (bytes == null || width == null || height == null || rotation == null) {
                    result.success(new ArrayList<String>());
                    return;
                }

                InputImage inputImage = InputImage.fromByteArray(
                    bytes,
                    width,
                    height,
                    rotation,
                    InputImage.IMAGE_FORMAT_NV21
                );

                recognizer.process(inputImage)
                    .addOnSuccessListener(new OnSuccessListener<Text>() {
                        @Override
                        public void onSuccess(Text visionText) {
                            List<String> rawLines = new ArrayList<>();
                            for (Text.TextBlock block : visionText.getTextBlocks()) {
                                for (Text.Line line : block.getLines()) {
                                    String text = line.getText().trim();
                                    if (!text.isEmpty()) {
                                        rawLines.add(text);
                                    }
                                }
                            }
                            result.success(rawLines);
                        }
                    })
                    .addOnFailureListener(new OnFailureListener() {
                        @Override
                        public void onFailure(@NonNull Exception e) {
                            result.error("OCR_ERROR", e.getMessage(), null);
                        }
                    });
            } catch (Exception e) {
                result.error("FRAME_ERROR", e.getMessage(), null);
            }
        } else if ("dispose".equals(call.method)) {
            if (recognizer != null) {
                recognizer.close();
            }
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (channel != null) {
            channel.setMethodCallHandler(null);
            channel = null;
        }
        if (recognizer != null) {
            recognizer.close();
            recognizer = null;
        }
    }
}
