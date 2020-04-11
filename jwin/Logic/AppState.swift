import SwiftUI
import UIKit

class AppState: Codable, ObservableObject {
    @Published var lists: [JList]
    
    enum CodingKeys: String, CodingKey {
        case lists
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.lists = try values.decode([JList].self, forKey: .lists)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.lists, forKey: .lists)
    }
    
    static func load(from url: URL) throws -> AppState {
        let data = try Data(contentsOf: url)

        let decoder = JSONDecoder()
        guard let loaded = try? decoder.decode(AppState.self, from: data) else {
            fatalError("Failed to decode \(url)")
        }
        
        return loaded
    }
    
    func save(to url: URL) throws {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else {
            fatalError("Failed to encode \(self).")
        }

        try data.write(to: url)
    }
    
    func saveDefault(onSuccess: (URL) -> (), onError: (URL?) -> ()) {
        if let url = Self.defaultUrl() {
            do {
                try self.save(to: url)
                onSuccess(url)
            } catch {
                onError(url)
            }
        } else {
            onError(nil)
        }
    }
    
    func addList() {
        self.lists.append(
            JList(
                id: UUID(),
                name: "List \(self.lists.count + 1)",
                items: []
            )
        )
    }
    
    func removeLists(at offsets: IndexSet) {
        self.lists.remove(atOffsets: offsets)
    }
    
    func moveLists(from source: IndexSet, to destination: Int) {
        self.lists.move(fromOffsets: source, toOffset: destination)
    }
    
    static func defaultUrl() -> URL? {
        return try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent("app_state.json")
    }
    
    static func demoUrl() -> URL {
        guard let url = Bundle.main.url(forResource: "demo_app_state.json", withExtension: nil) else {
            fatalError("Failed to locate demo_app_state.json in bundle.")
        }
        
        return url
    }
    
    static func loadDemo() -> AppState {
        guard let appState = try? AppState.load(from: self.demoUrl()) else {
            fatalError("Failed to load demo app")
        }
        
        return appState
    }
    
    static func loadFromDefaultOrDemo() -> (AppState, URL) {
        if let url = AppState.defaultUrl() {
            if let appState = try? AppState.load(from: url) {
                return (appState, url)
            }
        }
        
        return (loadDemo(), AppState.demoUrl())
    }
}
