import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class BetManager {
    static let shared = BetManager()
    private let db = Firestore.firestore()

    private init() {}

    
    
    // Create a new bet
    func createBet(bet: Bet, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }

        var newBet = bet
        newBet.timestamp = Timestamp(date: Date())

        do {
            let _ = try db.collection("bets").addDocument(from: newBet) { error in
                if let error = error {
                    print("Error adding bet: \(error)")
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func listenToBetUpdates(betId: String, completion: @escaping (Result<Bet, Error>) -> Void) -> ListenerRegistration {
        let betRef = db.collection("bets").document(betId)
        return betRef.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot else {
                completion(.failure(NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No snapshot data."])))
                return
            }
            
            do {
                let bet = try snapshot.data(as: Bet.self)
                completion(.success(bet))
            } catch {
                completion(.failure(error))
            }
        }
    }




    // Retrieve designation for a user
    func getDesignation(for bet: Bet, email: String) -> String {
        if bet.createdBy == email {
            return "Creator"
        } else if bet.participant == email {
            return "Participant"
        } else if bet.middlemanEmail == email {
            return "Middleman"
        } else {
            return "Unknown"
        }
    }

    // Update the status of a bet
    func updateBetStatus(betId: String, result: String, status: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let betRef = db.collection("bets").document(betId)
        betRef.updateData(["result": result, "status": status]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Update the status of the middleman
    func updateMiddlemanStatus(betId: String, middlemanStatus: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let betRef = db.collection("bets").document(betId)
        betRef.updateData(["middlemanStatus": middlemanStatus]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateParticipantStatus(betId: String, participantStatus: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let betRef = db.collection("bets").document(betId)
        betRef.updateData(["participantStatus": participantStatus]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Add a voted user to the bet
    func addVotedUser(betId: String, email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let betRef = db.collection("bets").document(betId)
        betRef.updateData([
            "votedUsers": FieldValue.arrayUnion([email])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Update the selected result of a bet
    func updateBetSelectedResult(betId: String, result: String, role: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let betRef = db.collection("bets").document(betId)

        // Update both the role-specific result and the overall result
        var dataToUpdate: [String: Any] = [
            role : result,
        ]

        betRef.updateData(dataToUpdate) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

}
