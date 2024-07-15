import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @ObservedObject var authState: AuthState

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                Image("GetBet")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.bottom, 40)
                

                VStack(spacing: 15) {
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Button(action: {
                    Task {
                        await viewModel.signInWithEmail()
                        if viewModel.isSignedIn {
                            authState.isSignedIn = true
                        }
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(10)
                    } else {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .alert(isPresented: Binding<Bool>(
                    get: { viewModel.errorMessage != nil },
                    set: { _ in viewModel.errorMessage = nil }
                )) {
                    Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
                }

                Button(action: {
                    if viewModel.email.isEmpty {
                        viewModel.errorMessage = "Please enter your email to reset your password."
                    } else {
                        Task {
                            await viewModel.sendPasswordReset(to: viewModel.email)
                        }
                    }
                }) {
                    Text("Forgot Password?")
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
                .padding(.bottom, 15)

                HStack {
                    Text("Don't have an account?")
                    NavigationLink(destination: SignUpView(authState: authState)) {
                        Text("Sign Up")
                            .foregroundColor(.blue)
                            .font(.system(size: 16, weight: .bold))
                            .underline()
                    }
                }
                .padding(.bottom, 30)

                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                    Task {
                        await viewModel.signInGoogle()
                        if viewModel.isSignedIn {
                            authState.isSignedIn = true
                        }
                    }
                }
                .padding()

                Spacer()
            }
            .padding()
            .navigationBarTitle("Sign In", displayMode: .inline)
        }
    }
}

