import UserNotifications

extension Double {
    /// Returns the number if it is within range, otherwise either the lower or upper bound
    /// - Parameters:
    ///   - lower: Lower bound
    ///   - upper: Upper bound
    /// - Returns: The clamped value
    func clamp(between lower: Double, and upper: Double) -> Double {
        return min(max(self, lower), upper)
    }
}

extension DateFormatter {
    static let reminderFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.calendar = Calendar.current
        formatter.timeZone = .autoupdatingCurrent
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension UNNotificationRequest {
    /// - Returns: a printable version of the trigger for the notification request
    func printableTrigger() -> String {
        /// Extract the trigger date from either kind of notification
        var triggerDate: Date? = nil
        if let trigger = self.trigger as? UNCalendarNotificationTrigger {
            triggerDate = trigger.nextTriggerDate()
        } else if let trigger = self.trigger as? UNTimeIntervalNotificationTrigger {
            triggerDate = trigger.nextTriggerDate()

        }
        
        /// Return appropriate string
        if let triggerDate = triggerDate {
            return DateFormatter.reminderFormat.string(from: triggerDate)
        } else {
            return "No trigger date"
        }
    }
}
