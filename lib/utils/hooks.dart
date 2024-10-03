import 'package:flutter/scheduler.dart';

void onFirstBuild(void Function(Duration) cb) {
  return SchedulerBinding.instance.addPostFrameCallback(cb);
}
