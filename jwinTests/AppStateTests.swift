import XCTest

@testable import jwin

class AppStateTests: XCTestCase {
    var appState: AppState!
    
    override func setUpWithError() throws {
        appState = AppState.loadDemo()
    }

    override func tearDownWithError() throws {
        appState = nil
    }

    func testExample() throws {
    }
}
