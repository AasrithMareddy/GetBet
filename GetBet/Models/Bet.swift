import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Bet: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var participants: [String] // List of participant emails
    var conditions: String
    var middlemanEmail: String?
    var amount: String
    var currency: String
    var status: String
    var createdBy: String
     // New field for creation timestamp
    var notifications: [Notification] // New field to store notifications
    
    struct Notification: Codable, Identifiable {
        var id = UUID()
        let email: String
        let message: String
        let timestamp: Timestamp
    }
    static func == (lhs: Bet, rhs: Bet) -> Bool {
        return lhs.id == rhs.id
    }
}
