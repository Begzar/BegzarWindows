class SingStatus {
  final String duration;
  final double uploadSpeed;
  final double downloadSpeed;
  final double upload;
  final double download;
  final String state;

  SingStatus({
    this.duration = "00:00:00",
    this.uploadSpeed = 0.0,
    this.downloadSpeed = 0.0,
    this.upload = 0.0,
    this.download = 0.0,
    this.state = "DISCONNECTED",
  });
}