import SwiftUI

/// A list of items along with a name and an UUID.
class JList: Codable, Identifiable, ObservableObject {
    /// UUID for this list
    var id: UUID
    
    /// Name of the list, shows up in the navigation view and in the list of lists
    @Published var name: String
    
    /// All of the items in the list
    @Published var items: [JListItem]
    

    /// Trivial initializer for JList
    ///
    /// - Parameters:
    ///    - id: Unique UUID for this list
    ///    - name: Name for this list, not necessarily unique
    ///    - items: A list of items for this
    init(id: UUID, name: String, items: [JListItem]) {
        self.id = id
        self.name = name
        self.items = items
    }
    
    /// - Returns: a list with an empty string for a name, and no items.
    static func empty() -> JList {
        return JList(id: UUID(), name: "", items: [])
    }
    
    /// Adds an empty item to the end of the list.
    func addEmpty() {
        self.items.append(JListItem.empty())
    }
    
    /// Removes the given indices from the list.
    ///
    /// - Parameters:
    ///     - at: The offsets to remove (provided by e.g. `.onDelete`)
    func remove(at offsets: IndexSet) {
        self.items.remove(atOffsets: offsets)
    }
    
    /// Moves the given indices in the list.
    ///
    /// - Parameters:
    ///     - from: The offsets to move (provided by e.g. `onMove`)
    ///     - to: Destination for the first offset
    func move(from source: IndexSet, to destination: Int) {
        self.items.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: - Boilerplate to allow for the list to be encoded as JSON and also observable

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case items
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try values.decode(UUID.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .name)
        self.items = try values.decode([JListItem].self, forKey: .items)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.items, forKey: .items)
    }

    // MARK: - Debug only
    
    #if DEBUG
    /// An example list that can be used in previews.
    static let example = JList(
        id: UUID(),
        name: "Handleliste",
        items: [
            JListItem(id: UUID(), text: "Brød", active: true),
            JListItem(id: UUID(), text: "Egg", active: true),
            JListItem(id: UUID(), text: "Melk", active: false),
        ]
    )
    #endif
}

/// An element of a list. Has an unique identifier, some text, and an active/inactive flag.
class JListItem: Codable, Equatable, Identifiable, ObservableObject {
    /// Unique ID for this item
    var id: UUID
    
    /// The text to show for this object
    @Published var text: String
    
    /// Whether this object is currently "active" (for some appropriate definition of active)
    @Published var active: Bool
    
    /// Trivial initializer for JListItem
    ///
    /// - Parameters:
    ///    - id: Unique UUID for this item
    ///    - name: Text for this item, not necessarily unique
    ///    - active: Whether the item should be active
    init(id: UUID, text: String, active: Bool) {
        self.id = id
        self.text = text
        self.active = active
    }
    
    /// - Returns: an active item with no text
    static func empty() -> JListItem {
        return JListItem(id: UUID(), text: "", active: true)
    }
    
    /// Allows for the items to be removed
    static func == (lhs: JListItem, rhs: JListItem) -> Bool {
        return (lhs.id == rhs.id)
    }
    
    // MARK: - Boilerplate to allow for the items to be encoded as JSON and also observable

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case active
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(UUID.self, forKey: .id)
        self.text = try values.decode(String.self, forKey: .text)
        self.active = try values.decode(Bool.self, forKey: .active)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.text, forKey: .text)
        try container.encode(self.active, forKey: .active)
    }
    
    
    // Mark: - Debug only
    
    #if DEBUG
    /// An example item that can be used in previews
    static let example = JListItem(
        id: UUID(),
        text: "Do the thing",
        active: true
    )
    #endif
}
