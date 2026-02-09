import 'package:flutter/material.dart';
import '../models/twin_profile.dart';

class TwinProvider extends ChangeNotifier {
  /// 📊 Profile الأساسي
  TwinProfile profile = TwinProfile(
    conversations: 0,
    memories: 0,
    level: "Beginner",
  );

  /// 🧠 LifeTwin Traits (Live sliders)
  double mood = 50;        // Calm <-> Aggressive
  double confidence = 50;  // Shy <-> Bold
  double logic = 50;       // Emotional <-> Logical

  // ---------------------------
  // Profile actions
  // ---------------------------

  void addConversation() {
    profile.conversations++;
    _updateLevel();
    notifyListeners();
  }

  void addMemory() {
    profile.memories++;
    notifyListeners();
  }

  void _updateLevel() {
    if (profile.conversations >= 20) {
      profile.level = "Advanced";
    } else if (profile.conversations >= 10) {
      profile.level = "Growing";
    } else {
      profile.level = "Beginner";
    }
  }

  // ---------------------------
  // Traits setters (Editor Page)
  // ---------------------------

  void setMood(double value) {
    mood = value;
    notifyListeners();
  }

  void setConfidence(double value) {
    confidence = value;
    notifyListeners();
  }

  void setLogic(double value) {
    logic = value;
    notifyListeners();
  }

  // ---------------------------
  // 🧩 Helper logic (سلوك التوأم)
  // ---------------------------

  bool get isAggressive => mood > 70 && confidence > 70;
  bool get isCalm => mood < 40;
  bool get isLogical => logic > 60;
}
