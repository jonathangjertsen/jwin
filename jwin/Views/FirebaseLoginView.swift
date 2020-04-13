import SwiftUI

/// Sub-form for the firebase login view
struct FirebaseLoginView: View {
    @ObservedObject var loginData: LoginData
    var onLogin: (LoginData) -> ()
    var onRegister: (LoginData) -> ()
    
    var body: some View {
        Section(header: Text("Credentials")) {
            TextField("Username", text: $loginData.username)
                .textContentType(.emailAddress)
            SecureField("Password", text: $loginData.password)
            CenteredButton(text: "Log in") {
                self.onLogin(self.loginData)
            }
            CenteredButton(text: "Register") {
                self.onRegister(self.loginData)
            }
        }
    }
}

struct FirebaseLogin_Previews: PreviewProvider {
    static var previews: some View {
        FirebaseLoginView(loginData: LoginData(
            username: "Some user",
            password: "hunter2"
        ), onLogin: {
            loginData in
            loginData.username = "Logged in"
        }, onRegister:  {
            loginData in
            loginData.username = "Registered"
        })
    }
}
