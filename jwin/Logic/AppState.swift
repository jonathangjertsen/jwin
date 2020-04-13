import SwiftUI
import UIKit

/// Container for assorted configuration bits
struct AppStateConfig: Codable {
    var permissionsGranted: Bool
}

/// Bundles up all of the state of the app
class AppState: Codable, ObservableObject {
    /// A list of lists for the "lists" sub-app
    @Published var lists: [JList]
    
    /// A list of reminders for the "reminders" sub-app
    @Published var reminders: Reminders
    
    /// Assorted configuration bits
    @Published var config: AppStateConfig
    
    /// Handle for cloud persistence layer
    @Published var cloudPersistence: CloudPersistable? = nil
    
    /// Loads the app state from an URL
    /// - Parameter url: The url from which to load the app state
    /// - Throws: any exceptions from loading the URL or decoding the data
    /// - Returns: an AppState representation of the data
    static func load(from url: URL) throws -> Self {
        return try self.loads(from: Data(contentsOf: url))
    }
    
    /// Loads the app state from some Data
    /// - Parameter from: The data to load from
    /// - Throws: any exceptions from decoding the data
    /// - Returns: an AppState representation of the data
    static func loads(from data: Data) throws -> Self {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.reminderFormat)
        return try decoder.decode(Self.self, from: data)
    }

    /// Returns a JSON representation of the state
    /// - Throws: any exceptions from encoding the data
    func dumps() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(.reminderFormat)
        return try encoder.encode(self)
    }
    
    /// Saves the app state to an URL
    /// - Parameter url: The url to which the app state should be saved
    /// - Throws: any exceptions from encoding the data or writing to the URL
    func save(to url: URL) throws {
        return try self.dumps().write(to: url)
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
    
    /// Replaces all data in this instance with the data in another instance
    func replaceAllData(with other: AppState) {
        self.lists = other.lists
        self.reminders = other.reminders
        self.config = other.config
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
    
    /// Update state on whether permissions are granted
    /// - Parameter granted: Whether permissions are granted
    func permissions(granted: Bool) {
        self.config.permissionsGranted = granted
    }
    
    /// - Returns: URL for a file on the file system if available, otherwise nil
    static func fileUrl(for name: String) -> URL? {
        return try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent(name, isDirectory: false)
    }
    
    /// - Returns: The default URL if available, otherwise `nil`
    static func defaultUrl() -> URL? {
        return self.fileUrl(for: "app_state.json")
    }
    
    /// - Returns: The backup URL for this moment if available, otherwise `nil`
    static func backupUrl(timestamp: Int) -> URL? {
        return self.fileUrl(for: "app_state_backup_\(timestamp).json")
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
        do {
            return try AppState.load(from: self.demoUrl())
        } catch {
            fatalError("Failed to load demo app: \(error)")
        }
    }
    
    /// Tries to load the app state from the default location.
    ///
    /// If the default location does not have any file, it should be safe to load the demo and use that going forward,
    /// since it will not overwrite anything.
    ///
    /// If there *is* a file in the default location, but it does not load correctly for some reason (old schema or whatever),
    /// then back it up to the backup URL and THEN load the demo url.
    /// - Returns: the app state and associated URL as a tuple
    static func loadFromDefaultOrDemo() -> (AppState, URL) {
        if let url = AppState.defaultUrl() {
            if let appState = try? AppState.load(from: url) {
                return (appState, url)
            } else {
                self.makeLocalBackup(from: url)
            }
        }
        
        return (loadDemo(), AppState.demoUrl())
    }
    
    /// Make a backup of a (possibly corrupted) JSON file
    /// - Parameter url: URL for the JSON file
    static func makeLocalBackup(from url: URL) {
        if let backupUrl = AppState.backupUrl(
            timestamp: Int(Date().timeIntervalSince1970)
            ) {
            do {
                try FileManager.default.copyItem(at: url, to: backupUrl)
                print("Backed up to \(backupUrl.absoluteString)")
            } catch (let error) {
                fatalError("Failed to back up app state to \(backupUrl.absoluteString). Exiting to avoid overwriting the state. Error: \(error)")
            }
        } else {
            fatalError("Failed to load URL for backup. Exiting to avoid overwriting the state.")
        }
    }
    
    // MARK: - Boilerplate to allow for the object to be both observable and JSON codable

    enum CodingKeys: String, CodingKey {
        case lists
        case reminders
        case config
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        /// Graceful handling of invalid config: use default config with no permissions granted
        self.config = (try? values.decode(MaybeDecodable<AppStateConfig>.self, forKey: .config).value) ?? AppStateConfig.init(permissionsGranted: false)

        /// Graceful handling of invalid reminders: init to empty set of reminders
        self.reminders = (try? values.decode(MaybeDecodable<Reminders>.self, forKey: .reminders).value) ?? Reminders.empty()
        
        /// Graceful handling of invalid lists: skip them
        self.lists = (try? values.decode([MaybeDecodable<JList>].self, forKey: .lists).compactMap { $0.value }) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.lists, forKey: .lists)
        try container.encode(self.reminders, forKey: .reminders)
        try container.encode(self.config, forKey: .config)
    }
}
