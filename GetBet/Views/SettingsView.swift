import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @ObservedObject var authState: AuthState
    @State private var errorMessage: String?
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var pushNotifications: Bool = true
    @State private var emailNotifications: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    HStack {
                        Text("Username")
                        Spacer()
                        Text(username)
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(email)
                            .foregroundColor(.gray)
                    }
                }

                Section(header: Text("Notifications")) {
                    Toggle("Push Notifications", isOn: $pushNotifications)
                    Toggle("Email Notifications", isOn: $emailNotifications)
                }
                
                Section(header: Text("Privacy")) {
                    NavigationLink(destination: PrivacyView()) {
                        Text("Privacy Settings")
                    }
                }
                
                Section(header: Text("About")) {
                    NavigationLink(destination: AboutView()) {
                        Text("About Us")
                    }
                }
                
                Section {
                    Button(action: {
                        do {
                            try AuthenticationManager.shared.signOut()
                            authState.isSignedIn = false
                        } catch {
                            errorMessage = "Failed to log out: \(error.localizedDescription)"
                        }
                    }) {
                        Text("Log Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .onAppear(perform: fetchUserDetails)
            .alert(isPresented: .constant(errorMessage != nil)) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? ""), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func fetchUserDetails() {
        if let user = Auth.auth().currentUser {
            username = user.displayName ?? "Unknown"
            email = user.email ?? "Unknown"
        } else {
            errorMessage = "No user is currently signed in."
        }
    }
}

struct PrivacyView: View {
    var body: some View {
        Text("Privacy Settings")
            .navigationBarTitle("Privacy", displayMode: .inline)
    }
}

struct AboutView: View {
    var body: some View {
        Text("About Us")
            .navigationBarTitle("About", displayMode: .inline)
    }
}


