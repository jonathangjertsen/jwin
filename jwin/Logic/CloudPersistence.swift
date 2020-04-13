import Firebase
import SwiftKeychainWrapper

/// Key / value pair with debug info
struct CloudPersistenceDebugItem {
    let key: String
    let value: String
}

/// Protocol for a cloud persistence solution
protocol CloudPersistable {
    /// Any startup that needs to be done at app launch.
    static func configure()
    
    /// Returns a list of CloudPersistenceDebugItem´s for display (implementation dependent)
    func debugItems() -> [CloudPersistenceDebugItem]
    
    /// Stores some data.
    /// - Parameters:
    ///   - blob: The bytes to store
    ///   - identifier: The identifier for the blob
    ///   - callback: What to do after the item has been stored
    ///
    /// If the `identifier` does not correspond to an ID in the back-end, this should create an item with that ID associated with the blob.
    /// Otherwise, it should update the item associated with `identifier`.
    ///
    /// `then` does not pass anything at the moment because the only relevant implementation
    /// allows using the instance properties to check what happened.
    func storeBlob(_ blob: Data, identifier: String, then callback: @escaping () -> ()) throws

    /// Downloads some data.
    /// - Parameters:
    ///   - identifier: The identifier for the blob
    ///   - callback: What to do after the item has been stored
    ///   - result: The returned data if it exists, otherwise `nil`
    func loadBlob(identifier: String, then callback: @escaping (_ result: Data?) -> ()) throws
    
    /// Logs in the user.
    /// - Parameters:
    ///    - credentials: the credentials to use.
    ///    - then: What to do after login has completed
    ///    - err: The error from logging in (if any), otherwise `nil`
    func logIn(with credentials: LoginData, then callback: @escaping (_ err: String?) -> ())
    
    /// Registers the user.
    /// - Parameters:
    ///    - credentials: the credentials to use.
    ///    - then: What to do after login has completed
    ///    - err: The error from logging in (if any), otherwise `nil`
    func register(with credentials: LoginData, then callback: @escaping (_ err: String?) -> ())

    /// The current data used for login.
    var loginData: LoginData { get set }

    /// Whether the user is currently logged in.
    var loggedIn: Bool { get }
}

/// Reference to login data
class LoginData: ObservableObject {
    @Published var username: String
    @Published var password: String
    @Published var valid: Bool
    
    init(username: String, password: String, valid: Bool = false) {
        self.username = username
        self.password = password
        self.valid = valid
    }
    
    convenience init() {
        self.init(username: "", password: "")
    }

    /// - Parameter prefix: A prefix that identifies what the login data is for
    /// - Returns: the login data stored in keychain if available, otherwise an empty instance.
    ///
    /// To check whether the login data came from the keychain or was created, check the `valid` field of the result.
    static func fromKeychainOrEmpty(under prefix: String = "") -> LoginData {
        guard let username = KeychainWrapper.standard.string(forKey: "\(prefix)_username") else {
            return LoginData()
        }
        
        guard let password = KeychainWrapper.standard.string(forKey: "\(prefix)_password") else {
            return LoginData()
        }
        
        return LoginData(
            username: username,
            password: password,
            valid: true
        )
    }
    
    /// Store the login data in keychain.
    /// - Parameter prefix: A prefix that identifies what the login data is for.
    func saveToKeychain(under prefix: String = "") {
        KeychainWrapper.standard.set(username, forKey: "\(prefix)_username")
        KeychainWrapper.standard.set(password, forKey: "\(prefix)_password")
        self.valid = true
    }
    
    /// Canonicalizes the username and password in place.
    func canonicalize() {
        self.username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        self.password = password.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Cloud persistence layer
/// Wraps Firestore at this time
class FirestorePersistence : CloudPersistable, ObservableObject {
    let collectionName: String
    private let firestoreDB: Firestore
    
    @Published var loginData: LoginData
    @Published var loggedIn: Bool = false
    @Published var lastLoginResult: String? = nil
    
    @Published var lastStoreIdentifier: String? = nil
    @Published var lastStoreTime: DatePoke
    @Published var lastStoreError: String? = nil
    @Published var lastStoreBlob: String? = nil
    @Published var lastStoreCompletedSuccessfully: Bool = false
    
    @Published var lastLoadIdentifier: String? = nil
    @Published var lastLoadTime: DatePoke
    @Published var lastLoadError: String? = nil
    @Published var lastLoadBlob: String? = nil
    @Published var lastLoadCompletedSuccessfully: Bool = false
    
    init(collectionName: String, loginData: LoginData) {
        self.collectionName = collectionName
        self.loginData = loginData
        self.firestoreDB = Firestore.firestore()
        self.lastStoreTime = DatePoke()
        self.lastLoadTime = DatePoke()
    
        if self.loginData.valid {
            self.logIn(with: loginData) { _ in }
        }
    }
    
    func register(with credentials: LoginData, then callback: @escaping (_ err: String?) -> ()) {
        credentials.canonicalize()
        Auth.auth().createUser(withEmail: credentials.username, password: credentials.password) {
            (result, error)
            in
            if let err = error {
                self.lastLoginResult = "Got error during registration: \(err.localizedDescription)"
                callback(self.lastLoginResult)
                return
            }
            
            guard let result = result else {
                self.lastLoginResult = "Got no error during registration, but the result is nil"
                callback(self.lastLoginResult)
                return
            }
            
            credentials.saveToKeychain(under: "firebase")
            self.lastLoginResult = "Registration succeeded, user ID is \(result.user.uid)"
            callback(nil)
        }
    }
    
    func logIn(with credentials: LoginData, then callback: @escaping (_ err: String?) -> ()) {
        credentials.canonicalize()
        Auth.auth().signIn(withEmail: credentials.username, password: credentials.password) {
            (result, error)
            in
            if let err = error {
                self.lastLoginResult = "Got error during login: \(err.localizedDescription)"
                callback(self.lastLoginResult)
                return
            }
            
            guard let result = result else {
                self.lastLoginResult = "Got no error during login, but the result is nil"
                callback(self.lastLoginResult)
                return
            }

            credentials.saveToKeychain(under: "firebase")
            self.lastLoginResult = "Login succeeded, user ID is \(result.user.uid)"
            self.loggedIn = true
            callback(nil)
        }
    }
    
    func storeBlob(_ blob: Data, identifier: String, then callback: @escaping () -> ()) throws {
        self.lastStoreCompletedSuccessfully = false
        let blobString = String(decoding: blob, as: UTF8.self)
        let firestoreDocument = ["json": blobString]
        self.firestoreDB.collection(self.collectionName).document(identifier).setData(firestoreDocument) {
            error in
            self.lastStoreTime.poke()
            self.lastStoreIdentifier = identifier
            self.lastStoreBlob = blobString
            if let err = error {
                self.lastStoreError = "\(err)"
            } else {
                self.lastStoreCompletedSuccessfully = true
            }
            
            callback()
        }
    }
    
    func loadBlob(identifier: String, then callback: @escaping (Data?) -> ()) throws {
        self.lastLoadCompletedSuccessfully = false
        self.firestoreDB.collection(self.collectionName).document(identifier).getDocument {
            document, error in
            self.lastLoadIdentifier = identifier
            self.lastLoadBlob = nil
            self.lastLoadTime.poke()

            guard error == nil else {
                self.lastLoadError = "\(String(describing: error))"
                callback(nil)
                return
            }
            
            guard let document = document else {
                self.lastLoadError = "getDocument returned with no error, but document was nil"
                callback(nil)
                return
            }
            
            guard document.exists else {
                self.lastLoadError = "getDocument returned with a document that does not exist"
                callback(nil)
                return
            }
            
            guard let data = document.get("json") else {
                self.lastLoadError = "getDocument returned with a document, but the blob field is not present"
                callback(nil)
                return
            }
            
            guard let blobString = data as? String else {
                self.lastLoadError = "getDocument returned with a json field, but it is not a string: \(String(describing: data))"
                callback(nil)
                return
            }
            self.lastLoadBlob = blobString
            
            guard let bytes = blobString.data(using: .utf8) else {
                self.lastLoadError = "json field could not be UTF-8 encoded: \(blobString)"
                callback(nil)
                return
            }
            
            self.lastLoadCompletedSuccessfully = true
            callback(bytes)
        }
    }
    
    func debugItems() -> [CloudPersistenceDebugItem] {
        return [
            CloudPersistenceDebugItem(key: "Logged in", value: self.loggedIn ? "Yes" : "No"),
            CloudPersistenceDebugItem(key: "Last login result", value: self.lastLoginResult ?? "None"),
        
            CloudPersistenceDebugItem(key: "Last identifier stored to", value: self.lastStoreIdentifier ?? "None"),
            CloudPersistenceDebugItem(key: "Last store time", value: "\(self.lastStoreTime.lastPoked)"),
            CloudPersistenceDebugItem(key: "Last store error", value: "\(self.lastStoreError ?? "None")"),
            CloudPersistenceDebugItem(key: "Last blob stored", value: "\(self.lastStoreBlob ?? "None")"),
            CloudPersistenceDebugItem(key: "Last store completed successfully", value: "\(self.lastStoreCompletedSuccessfully ? "Yes" : "No")"),

            CloudPersistenceDebugItem(key: "Last identifier loaded from", value: self.lastLoadIdentifier ?? "None"),
            CloudPersistenceDebugItem(key: "Last load time", value: "\(self.lastLoadTime.lastPoked)"),
            CloudPersistenceDebugItem(key: "Last load error", value: "\(self.lastLoadError ?? "None")"),
            CloudPersistenceDebugItem(key: "Last blob loaded", value: "\(self.lastLoadBlob ?? "None")"),
            CloudPersistenceDebugItem(key: "Last load completed successfully", value: "\(self.lastLoadCompletedSuccessfully ? "Yes" : "No")"),
            
        ]
    }
    
    static func configure() {
        FirebaseApp.configure()
    }
}

// MARK: -Debug stuff

class CloudPersistenceMock : CloudPersistable {
    var loginData: LoginData
    var loggedIn: Bool = false

    init() {
        self.loginData = LoginData()
    }
    
    static func configure() {
        
    }

    func logIn(with credentials: LoginData, then callback: @escaping (_ err: String?) -> ()) {
        print("Logged in with credentials: \(credentials.username), \(credentials.password)")
        callback(nil)
    }
    
    func register(with credentials: LoginData, then callback: @escaping (_ err: String?) -> ()) {
        print("Registered in with credentials: \(credentials.username), \(credentials.password)")
        callback(nil)
    }
    
    func storeBlob(_ blob: Data, identifier: String, then callback: @escaping () -> ()) throws {
        print("Mock: in identifier \(identifier), stored \(blob)")
        callback()
    }
    
    func loadBlob(identifier: String, then callback: @escaping (Data?) -> ()) throws {
        print("Mock: in identifier \(identifier), started loading")
        callback(nil)
    }
    
    func debugItems() -> [CloudPersistenceDebugItem] {
        return [
            CloudPersistenceDebugItem(key: "x", value: "y"),
            CloudPersistenceDebugItem(key: "a", value: "b")
        ]
    }
}
