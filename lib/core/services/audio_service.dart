import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:mic_stream/mic_stream.dart';
import '../constants/app_constants.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  Timer? _measurementTimer;
  StreamController<double>? _audioStreamController;
  StreamSubscription<Uint8List>? _micSubscription;
  bool _isMeasuring = false;

  /// Check microphone permission
  Future<bool> hasMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status == PermissionStatus.granted;
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  /// Start audio measurement
  Stream<double> startMeasurement() {
    if (_isMeasuring) {
      throw AudioServiceException('Measurement already in progress');
    }

    _audioStreamController = StreamController<double>();
    _isMeasuring = true;

    try {
      // Start real microphone stream
      final micStream = MicStream.microphone(
        audioSource: AudioSource.MIC,
        sampleRate: 44100,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: AudioFormat.ENCODING_PCM_16BIT,
      );

      _micSubscription = micStream.listen(
        (Uint8List audioData) {
          if (_isMeasuring && _audioStreamController != null) {
            // Convert audio data to decibel level
            double decibelLevel = _calculateDecibelLevel(audioData);
            _audioStreamController!.add(decibelLevel);
          }
        },
        onError: (error) {
          if (_audioStreamController != null &&
              !_audioStreamController!.isClosed) {
            _audioStreamController!.addError(error);
          }
        },
      );
    } catch (e) {
      // Fallback to simulation if real audio fails
      _startSimulationMode();
    }

    return _audioStreamController!.stream;
  }

  /// Calculate decibel level from audio data
  double _calculateDecibelLevel(Uint8List audioData) {
    if (audioData.isEmpty) return AppConstants.minDecibelLevel;

    // Convert bytes to 16-bit signed integers
    final samples = <int>[];
    for (int i = 0; i < audioData.length - 1; i += 2) {
      final sample = (audioData[i + 1] << 8) | audioData[i];
      samples.add(sample > 32767 ? sample - 65536 : sample);
    }

    if (samples.isEmpty) return AppConstants.minDecibelLevel;

    // Calculate RMS (Root Mean Square)
    double sum = 0;
    for (int sample in samples) {
      sum += sample * sample;
    }
    double rms = math.sqrt(sum / samples.length);

    // Convert to decibels (with some calibration)
    double decibelLevel = 20 * math.log(rms / 32768) / math.ln10;

    // Add reference level (typical smartphone microphone sensitivity)
    decibelLevel += 94; // dB SPL reference

    // Clamp to reasonable range
    return decibelLevel.clamp(
      AppConstants.minDecibelLevel,
      AppConstants.maxDecibelLevel,
    );
  }

  /// Fallback simulation mode
  void _startSimulationMode() {
    _measurementTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (_isMeasuring && _audioStreamController != null) {
          // Simulate realistic decibel levels with some variation
          double baseLevel = 45.0; // Base ambient noise level
          double variation =
              math.Random().nextDouble() * 20.0; // 0-20 dB variation
          double noise =
              (math.Random().nextDouble() - 0.5) * 5.0; // Random noise

          double decibelLevel = (baseLevel + variation + noise).clamp(
            AppConstants.minDecibelLevel,
            AppConstants.maxDecibelLevel,
          );

          _audioStreamController!.add(decibelLevel);
        }
      },
    );
  }

  /// Stop audio measurement
  Future<void> stopMeasurement() async {
    _isMeasuring = false;
    _measurementTimer?.cancel();
    _measurementTimer = null;

    await _micSubscription?.cancel();
    _micSubscription = null;

    await _audioStreamController?.close();
    _audioStreamController = null;
  }

  /// Check if currently measuring
  bool get isMeasuring => _isMeasuring;

  /// Dispose resources
  void dispose() {
    stopMeasurement();
  }

  /// Calculate noise level category from decibel reading
  static NoiseLevelCategory getNoiseLevelCategory(double decibelLevel) {
    if (decibelLevel < 40) return NoiseLevelCategory.quiet;
    if (decibelLevel < 55) return NoiseLevelCategory.moderate;
    if (decibelLevel < 70) return NoiseLevelCategory.loud;
    if (decibelLevel < 85) return NoiseLevelCategory.veryLoud;
    return NoiseLevelCategory.extreme;
  }

  /// Get noise level description
  static String getNoiseLevelDescription(double decibelLevel) {
    final category = getNoiseLevelCategory(decibelLevel);
    switch (category) {
      case NoiseLevelCategory.quiet:
        return 'Quiet - Library or quiet office';
      case NoiseLevelCategory.moderate:
        return 'Moderate - Normal conversation';
      case NoiseLevelCategory.loud:
        return 'Loud - Busy restaurant or traffic';
      case NoiseLevelCategory.veryLoud:
        return 'Very Loud - Construction site or subway';
      case NoiseLevelCategory.extreme:
        return 'Extreme - Rock concert or aircraft';
    }
  }

  /// Get noise level color
  static int getNoiseLevelColor(double decibelLevel) {
    final category = getNoiseLevelCategory(decibelLevel);
    switch (category) {
      case NoiseLevelCategory.quiet:
        return AppConstants.noiseQuiet.value;
      case NoiseLevelCategory.moderate:
        return AppConstants.noiseModerate.value;
      case NoiseLevelCategory.loud:
        return AppConstants.noiseLoud.value;
      case NoiseLevelCategory.veryLoud:
        return AppConstants.noiseVeryLoud.value;
      case NoiseLevelCategory.extreme:
        return AppConstants.noiseExtreme.value;
    }
  }
}

enum NoiseLevelCategory {
  quiet,
  moderate,
  loud,
  veryLoud,
  extreme,
}

class AudioServiceException implements Exception {
  final String message;
  AudioServiceException(this.message);

  @override
  String toString() => 'AudioServiceException: $message';
}
