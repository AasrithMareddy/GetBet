import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Bet: Codable, Identifiable, Equatable, Hashable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var participant: String // List of participant emails
    var conditions: String
    var middlemanEmail: String?
    var middlemanStatus: String
    var participantStatus: String
    var amount: String
    var status: String
    var createdBy: String
    var result: String?
    var participantResult: String?
    var creatorResult: String?
    var middlemanResult: String?
    var timestamp: Timestamp
    var votedUsers: [String]
    
    static func == (lhs: Bet, rhs: Bet) -> Bool {
        return lhs.id == rhs.id
    }
}

