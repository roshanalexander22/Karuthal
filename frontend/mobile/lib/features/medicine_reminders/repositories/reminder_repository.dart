class ReminderRepository {
  Future<List<Map<String, dynamic>>> getReminders() async {
    return [
      {
        "id": "1",
        "title": "പ്രഷർ മരുന്ന് (BP Tablet)",
        "time": "08:00 AM",
        "type": "MEDICINE"
      },
      {
        "id": "2",
        "title": "ഷുഗർ മരുന്ന് (Insulin)",
        "time": "01:30 PM",
        "type": "MEDICINE"
      },
    ];
  }
}
