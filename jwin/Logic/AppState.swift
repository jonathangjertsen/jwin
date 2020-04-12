import SwiftUI
import UIKit

/// Bundles up all of the state of the app
class AppState: Codable, ObservableObject {
    /// A list of lists for the "lists" sub-app
    @Published var lists: [JList]
    
    /// Loads the app state from an URL
    /// - Parameter url: The url from which to load the app state
    /// - Throws: any exceptions from loading the URL or decoding the data
    /// - Returns: an AppState representation of the data
    static func load(from url: URL) throws -> Self {
        return try JSONDecoder().decode(
            Self.self,
            from: Data(contentsOf: url)
        )
    }
    
    /// Saves the app state to an URL
    /// - Parameter url: The url to which the app state should be saved
    /// - Throws: any exceptions from encoding the data or writing to the URL
    func save(to url: URL) throws {
        try JSONEncoder().encode(self).write(to: url)
    }
    
    /// Saves the app state to the default URL.
    /// - Parameters:
    ///   - onSuccess: What to do if saving the app state succeeded.
    ///   - url: The default URL
    ///   - onError: What to do if saving the app state failed.
    ///   - urlOrNil: The default URL if it was available (but the saving failed), otherwise `nil`.
    func saveDefault(onSuccess: (_ url: URL) -> (), onError: (_ urlOrNil: URL?) -> ()) {
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
    
    /// Sets up and returns a timer that saves to the default URL every n seconds.
    /// It will stop if it fails.
    /// - Parameters:
    ///   - seconds: Interval between saves
    ///   - onSuccess: What to do each time the save succeeds
    ///   - url: The default URL
    ///   - onError: What to do (in addition to stopping the timer) if saving fials
    ///   - urlOrNil: The default URL if it was available (but the saving failed), otherwise `nil`.
    /// - Returns: The timer that was created
    func saveToDefaultUrlEvery(
        n seconds: Double,
        toleranceFraction: Double,
        onSuccess: @escaping (_ url: URL) -> (),
        onError: @escaping (_ urlOrNil: URL?) -> ()
    ) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: true) {
            timer in
            self.saveDefault(onSuccess: onSuccess, onError: {
                urlOrNil in
                timer.invalidate()
                onError(urlOrNil)
            })
        }
        timer.tolerance = seconds * toleranceFraction.clamp(between: 0.0, and: 1.0)
        return timer
    }
    
    /// Adds a new empty list.
    func addList() {
        self.lists.append(
            JList(
                id: UUID(),
                name: "List \(self.lists.count + 1)",
                items: []
            )
        )
    }
    
    /// Removes the given list(s).
    /// - Parameter offsets: Offsets to delete (provided by e.g. `onDelete`)
    func removeLists(at offsets: IndexSet) {
        self.lists.remove(atOffsets: offsets)
    }
    
    /// Moves the given list(s)
    /// - Parameters:
    ///   - source: Offsets from which to move (provided by e.g. `onMove`)
    ///   - destination: Where to move the first index
    func moveLists(from source: IndexSet, to destination: Int) {
        self.lists.move(fromOffsets: source, toOffset: destination)
    }
    
    /// - Returns: The default URL if available, otherwise `nil`
    static func defaultUrl() -> URL? {
        return try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent("app_state.json")
    }
    
    /// - Returns: URL to the demo app state (bundled with the app, guaranteed to be available)
    ///
    /// May trigger a fatal error if the demo app state is not available for some reason.
    static func demoUrl() -> URL {
        guard let url = Bundle.main.url(forResource: "demo_app_state.json", withExtension: nil) else {
            fatalError("Failed to locate demo_app_state.json in bundle.")
        }
        
        return url
    }
    
    /// - Returns: an AppState based on the demo app state that is bundled with the app
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
    
    // MARK: - Boilerplate to allow for the object to be both observable and JSON codable

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
}
