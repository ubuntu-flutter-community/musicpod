extension DateTimeX on DateTime {
  String get podcastTimeStamp =>
      '${this.year}_${this.month}_${this.day}_${this.hour}_${this.minute}';
}
