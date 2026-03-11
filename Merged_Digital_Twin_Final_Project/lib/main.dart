import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const DigitalTwinApp(),
    ),
  );
}