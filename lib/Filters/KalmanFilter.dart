// Adapted from:
// https://web.archive.org/web/20140131183356/http://interactive-matter.eu/blog/2009/12/18/filtering-sensor-data-with-a-kalman-filter/
class KalmanFilter {
  /* Kalman filter variables */
  static const double TRAINING_PREDICTION_LIMIT = 500;
  late double q; //process noise covariance
  late double r; //measurement noise covariance
  late double x; //value
  late double p; //estimation error covariance
  late double k; //kalman gain
  double predictionCycles = 0;
  KalmanFilter(double processNoise, double sensorNoise, double estimatedError,
      double initialValue) {
    q = processNoise;
    r = sensorNoise;
    p = estimatedError;
    x = initialValue;

    print("Kalman Filter initialised");
  }

  double getFilteredValue(double measurement) {
    print("Before FIltered: ${measurement}");
    // prediction phase
    p = p + q;

    // measurement update
    k = p / (p + r);
    x = x + k * (measurement - x);
    p = (1 - k) * p;
    print("After FIltered: ${x}");

    return x;
  }
}
