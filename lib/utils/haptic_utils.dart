import 'package:flutter/services.dart';

void hapticClick() {
  HapticFeedback.lightImpact();
}

void hapticHeavy() {
  HapticFeedback.heavyImpact();
}

void hapticSelection() {
  HapticFeedback.selectionClick();
}

void playClickSound() {
  SystemSound.play(SystemSoundType.click);
}
