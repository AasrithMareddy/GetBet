import SwiftUI
import Firebase
import FirebaseFirestoreSwift

@MainActor
final class BetViewModel: ObservableObject {
    @Published var bet: Bet?
    @Published var currentUserEmail = Auth.auth().currentUser?.email
    @Published var hasVoted = false
    
    private var listener: ListenerRegistration?
    
    init(bet: Bet?) {
        self.bet = bet
        self.hasVoted = self.userHasVoted()
        self.startListening()
    }
    
    func startListening() {
        guard let betId = bet?.id else { return }
        
        listener = Firestore.firestore().collection("bets").document(betId).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            do {
                if let updatedBet = try document.data(as: Bet?.self) {
                    DispatchQueue.main.async {
                        self.bet = updatedBet
                        self.hasVoted = self.userHasVoted()
                        self.objectWillChange.send() // Manually trigger UI update
                    }
                }
            } catch {
                print("Error decoding document: \(error)")
            }
        }
    }
    
    func stopListening() {
        listener?.remove()
    }
    
    private func userHasVoted() -> Bool {
        guard let email = currentUserEmail else { return false }
        return bet?.votedUsers.contains(email) ?? false
    }
}
