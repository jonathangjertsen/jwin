import UIKit

/// Helper class to simplify making recoverable runtime errors
enum DebugError: Error {
    case debug(String)
}

/// Wrapper class for use when decoding potentially invalid data. Sets the wrapped value to nil if the decoding failed.
struct MaybeDecodable<T: Decodable>: Decodable {
    let value: T?

    init(from decoder: Decoder) throws {
        guard let container = try? decoder.singleValueContainer() else {
            self.value = nil
            return
        }

        self.value = try? container.decode(T.self)
    }
}

/// Reference type wrapper for Date that may also be poked when something happens
class DatePoke: ObservableObject {
    @Published var lastPoked: Date

    init() {
        self.lastPoked = Date()
    }
    
    func poke() {
        self.lastPoked = Date()
    }
}

