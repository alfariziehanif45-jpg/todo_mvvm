import 'package:flutter/material.dart';

class ScheduleView extends StatefulWidget {
  final Function(List<String>, TimeOfDay) onSave;

  const ScheduleView({super.key, required this.onSave});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  List<String> selectedDays = [];
  TimeOfDay? selectedTime;

  final List<String> days = [
    "Senin",
    "Selasa",
    "Rabu",
    "Kamis",
    "Jumat",
    "Sabtu",
    "Minggu",
  ];

  void toggleDay(String day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  String formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Atur Jadwal")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pilih Hari:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: days.map((day) {
                return ChoiceChip(
                  label: Text(day),
                  selected: selectedDays.contains(day),
                  onSelected: (_) => toggleDay(day),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            const Text(
              "Pilih Jam:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: pickTime,
              child: Text(
                selectedTime == null ? "Pilih Jam" : formatTime(selectedTime!),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedDays.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pilih minimal 1 hari")),
                    );
                    return;
                  }

                  if (selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pilih jam dulu")),
                    );
                    return;
                  }

                  // 🔥 KIRIM DATA KE TASK VIEW
                  widget.onSave(selectedDays, selectedTime!);

                  Navigator.pop(context);
                },
                child: const Text("Simpan Jadwal"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
