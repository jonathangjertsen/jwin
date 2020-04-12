import SwiftUI

/// Wrapper for an observable list of reminders
class Reminders: Codable, ObservableObject {
    /// All of the reminders
    @Published var reminders: [Reminder]
    
    /// Trivial initializer
    /// - Parameter reminders: The reminders contained in the list
    init(_ reminders: [Reminder]) {
        self.reminders = reminders
    }
    
    /// - Returns: An empty list of reminders
    static func empty() -> Reminders {
        return Reminders([])
    }
    
    /// Adds the reminder to the list
    /// - Parameter reminder: The reminder to add
    func add(_ reminder: Reminder) {
        self.reminders.append(reminder)
    }
    
    /// Removes the given indices from the list.
    ///
    /// - Parameters:
    ///     - at: The offsets to remove (provided by e.g. `.onDelete`)
    func remove(at offsets: IndexSet) {
        self.reminders.remove(atOffsets: offsets)
    }
    
    /// Moves the given indices in the list.
    ///
    /// - Parameters:
    ///     - from: The offsets to move (provided by e.g. `onMove`)
    ///     - to: Destination for the first offset
    func move(from source: IndexSet, to destination: Int) {
        self.reminders.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: - Boilerplate to allow for the list to be encoded as JSON and also observable

    enum CodingKeys: String, CodingKey {
        case reminders
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.reminders = try values.decode([Reminder].self, forKey: .reminders)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.reminders, forKey: .reminders)
    }

    // MARK: - Debug only
    
    #if DEBUG
    /// An example list that can be used in previews.
    static let example = Reminders([
        Reminder(id: UUID(), text: "Do the thing!", time: Date()),
        Reminder(id: UUID(), text: "Do the other thing!", time: Date())
    ])
    #endif
}

/// Representation of a reminder
class Reminder: Codable, Equatable, Identifiable, ObservableObject {
    /// Unique ID for this reminder
    var id: UUID

    /// The text to show for this reminder
    @Published var text: String

    /// The date for this reminder
    @Published var time: Date

    /// Trivial initializer
    /// - Parameters:
    ///   - id: The UUID for this reminder
    ///   - text: The text for this reminder
    ///   - time: When this reminder should fire
    init(id: UUID, text: String, time: Date) {
        self.id = id
        self.text = text
        self.time = time
    }

    /// Allow the reminder to be identified
    static func == (lhs: Reminder, rhs: Reminder) -> Bool {
        return lhs.id == rhs.id
    }

    /// - Returns: a reminder with the date set to now and no text
    static func empty() -> Reminder {
        return Reminder(id: UUID(), text: "", time: Date())
    }
    
    /// Returns a copy of the reminder with a new UUID, then resets self.
    /// - Returns: A copy of the reminder
    func transfer() -> Reminder {
        let result = Reminder(id: UUID(), text: self.text, time: self.time)
        self.text = ""
        self.time = Date()
        return result
    }
    
    // MARK: - Boilerplate to allow for the reminder to be encoded as JSON and also observable

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case time
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(UUID.self, forKey: .id)
        self.text = try values.decode(String.self, forKey: .text)
        self.time = try values.decode(Date.self, forKey: .time)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.text, forKey: .text)
        try container.encode(self.time, forKey: .time)
    }
    
    // MARK: - Debug only
    
    #if DEBUG
    /// An example item that can be used in previews
    static let example = Reminder(
        id: UUID(),
        text: "Do the thing",
        time: Date()
    )
    #endif
}
