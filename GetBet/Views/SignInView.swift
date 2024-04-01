import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class SignInViewModel: ObservableObject {
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }
}

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @Binding var showSignInView: Bool
    @State private var phoneNumber: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Image("GetBet") // Replace "getbet" with the actual image name
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                
                // Phone Number Textfield
                TextField("Email", text: $phoneNumber)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Password Textfield
                SecureField("Password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Sign In Button
                Button(action: {
                    // Handle sign in logic
                }) {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                
                // Forgot Password Option
                NavigationLink(destination: ForgotPasswordView())
                {
                    Text("Forgot Password?")
                        .foregroundColor(.blue)
                        .padding()
                }
                
                // Sign In with Google Button
                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                    Task {
                        do {
                            try await viewModel.signInGoogle()
                            showSignInView = false
                        } catch {
                            print(error)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                NavigationLink(destination: SignUpView())
                {
                    Text("Don't have an account? ")
                        .foregroundColor(.blue)
                        .padding()

                    Text("Sign Up")
                        .foregroundColor(.blue)
                        .font(.system(size: 16, weight: .bold)) // Adjust size and weight as needed
                        .underline() // Optional: Add underline for emphasis
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(Color.white) // Optional: Add a background color

            }
            .padding()
            .navigationBarTitle("Sign In/ Sign Up", displayMode: .inline) // Optional: Set the navigation bar title
        }
    }
}

struct ForgotPasswordView: View {
    var body: some View {
        VStack {
            Text("Forgot Password")
                .font(.largeTitle)
                .padding()
            
            // Top verification and other necessary UI for password recovery
            
            Spacer()
        }
        .padding()
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(showSignInView: .constant(false))
    }
}
