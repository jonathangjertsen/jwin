import SwiftUI

class JList: Codable, Identifiable, ObservableObject {
    var id: UUID
    @Published var name: String
    @Published var items: [JListItem]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case items
    }
    
    init(id: UUID, name: String, items: [JListItem]) {
        self.id = id
        self.name = name
        self.items = items
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
    
    static func empty() -> JList {
        return JList(id: UUID(), name: "", items: [])
    }
    
    func addEmpty() {
        self.items.append(JListItem.empty())
    }
    
    func remove(at offsets: IndexSet) {
        self.items.remove(atOffsets: offsets)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        self.items.move(fromOffsets: source, toOffset: destination)
    }
    
    #if DEBUG
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

class JListItem: Codable, Equatable, Identifiable, ObservableObject {
    var id: UUID
    @Published var text: String
    @Published var active: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case active
    }
    
    init(id: UUID, text: String, active: Bool) {
        self.id = id
        self.text = text
        self.active = active
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
    
    static func empty() -> JListItem {
        return JListItem(id: UUID(), text: "", active: true)
    }
    
    static func == (lhs: JListItem, rhs: JListItem) -> Bool {
        return (lhs.id == rhs.id)
    }
    
    #if DEBUG
    static let example = JListItem(
        id: UUID(),
        text: "Do the thing",
        active: true
    )
    #endif
}
