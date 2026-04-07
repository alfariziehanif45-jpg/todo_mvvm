import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/task_viewmodel.dart';
import 'views/task_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaskViewModel>(
      create: (_) => TaskViewModel(),
      child: MaterialApp(debugShowCheckedModeBanner: false, home: TaskView()),
    );
  }
}
