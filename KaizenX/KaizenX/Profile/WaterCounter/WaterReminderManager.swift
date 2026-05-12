import UserNotifications

struct WaterReminderManager {
    static let shared = WaterReminderManager()
    private init() {}

    private let hours = [9, 12, 15, 18, 21]
    private let messages = [
        "Începe ziua cu un pahar de apă — corpul tău îți mulțumește.",
        "La jumătatea zilei. Cum stai cu hidratarea?",
        "O pauză scurtă și un pahar de apă te ajută să rămâi concentrat.",
        "Mai ai câteva ore. Ai atins obiectivul de azi?",
        "Ultima șansă să îți atingi obiectivul de hidratare."
    ]

    func requestPermissionAndSchedule(enabled: Bool) {
        if enabled {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
                guard granted else { return }
                DispatchQueue.main.async { self.schedule() }
            }
        } else {
            cancel()
        }
    }

    func schedule() {
        cancel()
        let center = UNUserNotificationCenter.current()
        for (index, hour) in hours.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Hidratare 💧"
            content.body = messages[index]
            content.sound = .default

            var components = DateComponents()
            components.hour = hour
            components.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "water_reminder_\(hour)", content: content, trigger: trigger)
            center.add(request)
        }
    }

    func cancel() {
        let ids = hours.map { "water_reminder_\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
}
