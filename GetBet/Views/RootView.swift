import SwiftUI
import FirebaseAuth

class AuthState: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var isEmailVerified: Bool = false
}

struct RootView: View {
    @StateObject private var authState = AuthState()

    var body: some View {
        NavigationStack {
            if authState.isSignedIn && authState.isEmailVerified {
                HomePageView(authState: authState)
            } else {
                SignInView(authState: authState)
            }
        }
        .onAppear {
            checkAuthentication()
        }
    }
    
    private func checkAuthentication() {
        if let user = Auth.auth().currentUser {
            user.reload { (error) in
                if let error = error {
                    print("Failed to reload user: \(error)")
                    authState.isSignedIn = false
                    return
                }
                authState.isSignedIn = true
                authState.isEmailVerified = user.isEmailVerified
            }
        } else {
            authState.isSignedIn = false
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
