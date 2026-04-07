import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_viewmodel.dart';
import '../models/task_model.dart';

class TaskView extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TaskViewModel>(context);

    return Scaffold(
      body: Row(
        children: [
          // 🟣 SIDEBAR
          Container(
            width: 220,
            color: Color(0xFFF5F5F5),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tasks",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ListTile(leading: Icon(Icons.today), title: Text("My Day")),
                ListTile(
                  leading: Icon(Icons.star_border),
                  title: Text("Important"),
                ),
                ListTile(leading: Icon(Icons.list), title: Text("Tasks")),
                Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add),
                  label: Text("New list"),
                ),
              ],
            ),
          ),

          // 🔵 TASK LIST
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tasks",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.more_horiz),
                    ],
                  ),
                  SizedBox(height: 20),

                  // INPUT
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: "Add a task",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () async {
                            await vm.addTask(controller.text);
                            controller.clear();
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // LIST
                  Expanded(
                    child: vm.isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: vm.tasks.length,
                            itemBuilder: (context, index) {
                              Task task = vm.tasks[index];

                              return ListTile(
                                tileColor: vm.selectedTask == task
                                    ? Colors.blue.withOpacity(0.1)
                                    : null,
                                leading: Checkbox(
                                  value: task.isDone,
                                  onChanged: (_) => vm.toggleTask(task),
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration: task.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                trailing: Icon(Icons.star_border),
                                onTap: () => vm.selectTask(task),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          // ⚪ DETAIL PANEL
          Expanded(
            child: Container(
              color: Color(0xFFF9F9F9),
              padding: EdgeInsets.all(16),
              child: vm.selectedTask == null
                  ? Center(child: Text("Select a task"))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vm.selectedTask!.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),

                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16),
                            SizedBox(width: 8),
                            Text("Add due date"),
                          ],
                        ),

                        SizedBox(height: 10),

                        Row(
                          children: [
                            Icon(Icons.repeat, size: 16),
                            SizedBox(width: 8),
                            Text("Repeat"),
                          ],
                        ),

                        Spacer(),

                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            if (vm.selectedTask != null) {
                              vm.deleteTask(vm.selectedTask!.id!);
                            }
                          },
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
