import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SignUpView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var emailSent: Bool = false
    @State private var isVerified: Bool = false

    @ObservedObject var authState: AuthState

    var body: some View {
        NavigationStack {
            VStack {
                Text("Sign Up")
                    .font(.largeTitle)
                    .padding()

                TextField("Name", text: $name)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Email", text: $email)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    Task {
                        await signUp()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .disabled(isLoading)
                .alert(isPresented: Binding<Bool>(
                    get: { errorMessage != nil },
                    set: { _ in errorMessage = nil }
                )) {
                    Alert(title: Text("Error"), message: Text(errorMessage ?? ""), dismissButton: .default(Text("OK")))
                }

                if emailSent {
                    Text("A verification email has been sent. Please check your email.")
                        .foregroundColor(.blue)
                        .padding()

                    Button(action: {
                        Task {
                            await checkEmailVerification()
                        }
                    }) {
                        Text("I've Verified My Email")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
            }
            .padding()
            .navigationDestination(isPresented: $isVerified) {
                HomePageView(authState: authState)
            }
        }
    }

    private func signUp() async {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        do {
            let signInMethods = try await Auth.auth().fetchSignInMethods(forEmail: email)
            if signInMethods.contains("google.com") {
                errorMessage = "This email is already associated with a Google account. Please sign in with Google."
                return
            }
        } catch {
            errorMessage = "Failed to check sign-in methods: \(error.localizedDescription)"
            return
        }

        isLoading = true
        do {
            _ = try await AuthenticationManager.shared.createUser(email: email, password: password)
            await sendVerificationEmail()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func sendVerificationEmail() async {
        if let user = Auth.auth().currentUser {
            do {
                try await user.sendEmailVerification()
                emailSent = true
            } catch {
                errorMessage = "Error sending verification email: \(error.localizedDescription)"
            }
        }
    }

    private func checkEmailVerification() async {
        guard let user = Auth.auth().currentUser else { return }

        do {
            try await user.reload() // Refresh user data
            if user.isEmailVerified {
                isVerified = true
                authState.isSignedIn = true
            } else {
                errorMessage = "Please verify your email first."
            }
        } catch {
            errorMessage = "Failed to check email verification: \(error.localizedDescription)"
        }
    }
    
//    private func deleteUnverifiedUsers() async {
//        let db = Firestore.firestore()
//        let usersRef = db.collection("unverifiedUsers")
//        let timeLimit = Date().addingTimeInterval(-24 * 60 * 60) // 24 hours ago
//
//        do {
//            let snapshot = try await usersRef.whereField("timestamp", isLessThan: Timestamp(date: timeLimit)).getDocuments()
//            for document in snapshot.documents {
//                let userID = document.documentID
//                let userDocRef = usersRef.document(userID)
//                userDocRef.getDocument { document, error in
//                    if let document = document, document.exists {
//                        Auth.auth().currentUser?.delete { error in
//                            if let error = error {
//                                print("Error deleting user with ID \(userID): \(error)")
//                            } else {
//                                userDocRef.delete { error in
//                                    if let error = error {
//                                        print("Error deleting document for user with ID \(userID): \(error)")
//                                    } else {
//                                        print("Deleted user with ID \(userID)")
//                                    }
//                                }
//                            }
//                        }
//                    } else {
//                        print("Document does not exist for user with ID \(userID)")
//                    }
//                }
//            }
//        } catch {
//            print("Error fetching unverified users: \(error)")
//        }
//    }

    
}
