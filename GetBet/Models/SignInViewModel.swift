import Foundation
import FirebaseAuth

@MainActor
final class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var passwordResetMessage: String?
    @Published var isSignedIn: Bool = false

    func signInWithEmail() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let authResult = try await AuthenticationManager.shared.signInUser(email: email, password: password)
            if authResult.isEmailVerified {
                isSignedIn = true
            } else {
                errorMessage = "Please verify your email"
                isSignedIn = false
            }
        } catch let error as NSError {
            handleSignInError(error)
            isSignedIn = false
        }

        isLoading = false
    }

    func signInGoogle() async {
        isLoading = true
        errorMessage = nil

        do {
            let helper = SignInGoogleHelper()
            let tokens = try await helper.signIn()
            try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
            isSignedIn = true
        } catch {
            isSignedIn = false
        }

        isLoading = false
    }

    func sendPasswordReset(to email: String) async {
        do {
            try await AuthenticationManager.shared.resetPassword(email: email)
            passwordResetMessage = "A password reset link has been sent to \(email)."
        } catch let error as NSError {
            handlePasswordResetError(error)
        }
    }

    private func handleSignInError(_ error: NSError) {
        if let authError = AuthErrorCode.Code(rawValue: error.code) {
            switch authError {
            case .invalidEmail:
                errorMessage = "Invalid email address."
            case .wrongPassword:
                errorMessage = "Incorrect password."
            case .userNotFound:
                errorMessage = "No account found for this email."
            default:
                errorMessage = "Authentication error: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "Unknown error occurred."
        }
    }
    private func handlePasswordResetError(_ error: NSError) {
        if let errorCode = AuthErrorCode.Code(rawValue: error.code) {
            switch errorCode {
            case .userNotFound:
                errorMessage = "No user found with this email."
            case .invalidEmail:
                errorMessage = "The email address is badly formatted."
            case .networkError:
                errorMessage = "Network error. Please try again."
            case .tooManyRequests:
                errorMessage = "Too many requests. Please try again later."
            default:
                errorMessage = "An unknown error occurred. Please try again."
            }
        } else if let detailedMessage = error.userInfo[NSLocalizedDescriptionKey] as? String {
            errorMessage = detailedMessage
        } else {
            errorMessage = "An unknown error occurred. Please try again."
        }
    }
    
    
}
