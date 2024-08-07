import Foundation
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    let isEmailVerified: Bool
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isEmailVerified = user.isEmailVerified
    }
}

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private let auth = Auth.auth()
    private var verificationId: String?

    private init() {}
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }

    // MARK: - Google Sign In
    
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    // MARK: - Email Sign In
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await auth.createUser(withEmail: email, password: password)
        let user = authDataResult.user
        return AuthDataResultModel(user: user)
    }
    
    func fetchSignInMethods(forEmail email: String) async throws -> [String] {
        return try await Auth.auth().fetchSignInMethods(forEmail: email)
    }
    
    func checkEmailExists(email: String) async throws -> Bool {
        do {
            let signInMethods = try await Auth.auth().fetchSignInMethods(forEmail: email)
            return !signInMethods.isEmpty
        } catch {
            throw error // Re-throw the error to be handled in the SubmitButton's Task
        }
    }


    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        do {
            let authDataResult = try await auth.signIn(withEmail: email, password: password)
            return AuthDataResultModel(user: authDataResult.user)
        } catch let error as NSError {
            throw error
        }
    }

    
    func resetPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }
    
    
    

//    // MARK: - Phone Number Sign In
//    
//    @discardableResult
//    func startAuth(phoneNumber: String, completion: @escaping (Bool) -> Void) {
//        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationId, error in
//            guard let verificationId = verificationId, error == nil else {
//                completion(false)
//                return
//            }
//            self?.verificationId = verificationId
//            completion(true)
//        }
//    }
//
//    @discardableResult
//    func verifyCode(smsCode: String, completion: @escaping (Bool) -> Void) {
//        guard let verificationId = verificationId else {
//            completion(false)
//            return
//        }
//        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: smsCode)
//
//        auth.signIn(with: credential) { result, error in
//            guard result != nil, error == nil else {
//                completion(false)
//                return
//            }
//            completion(true)
//        }
//    }
//    
    // MARK: - Common Sign In
    
    private func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await auth.signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    // MARK: - Sign Out
    
    func signOut() throws {
        try auth.signOut()
    }
}
