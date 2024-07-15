import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class BetManager {
    static let shared = BetManager()
    private let db = Firestore.firestore()
    
    func createBet(bet: Bet, completion: @escaping (Result<Void, Error>) -> Void) {
        var betWithNotifications = bet
        betWithNotifications.notifications = generateNotifications(for: bet)
        
        do {
            let _ = try db.collection("bets").addDocument(from: betWithNotifications) { error in
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

    private func generateNotifications(for bet: Bet) -> [Bet.Notification] {
        var notifications = [Bet.Notification]()
        
        for participant in bet.participants {
            let notification = Bet.Notification(
                email: participant,
                message: "You've been added to a bet: \(bet.title)",
                timestamp: Timestamp(date: Date())
            )
            notifications.append(notification)
        }

        if let middlemanEmail = bet.middlemanEmail {
            let notification = Bet.Notification(
                email: middlemanEmail,
                message: "You've been requested to be a middleman for: \(bet.title)",
                timestamp: Timestamp(date: Date())
            )
            notifications.append(notification)
        }

        return notifications
    }

    func acceptBet(betId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("bets").document(betId).updateData(["status": "accepted"]) { error in
            if let error = error {
                print("Error updating document: \(error)")
                completion(.failure(error))
            } else {
                print("Bet accepted!")
                completion(.success(()))
            }
        }
    }

    func rejectBet(betId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("bets").document(betId).updateData(["status": "rejected"]) { error in
            if let error = error {
                print("Error updating document: \(error)")
                completion(.failure(error))
            } else {
                print("Bet rejected!")
                completion(.success(()))
            }
        }
    }
}
