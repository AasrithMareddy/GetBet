import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct DetailedCompletedView: View {
    var bet: Bet
    @State private var currentUserEmail: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Title: \(bet.title)")
                .font(.headline)
            Text("Description: \(bet.description)")
            Text("Created By: \(bet.createdBy)")
            Text("Amount: \(bet.amount)")
            Text("Conditions: \(bet.conditions)")
            Text("Participant: \(bet.participant)")
            Text("Designation: \(BetManager.shared.getDesignation(for: bet, email: currentUserEmail))")
            if let middlemanEmail = bet.middlemanEmail {
                Text("Middleman: \(middlemanEmail)")
                Text("Middleman Status: \(bet.middlemanStatus)")
            }
            Text("Status: \(bet.status)")
            if let participantResult = bet.participantResult {
                Text("Participant Selected Result: \(participantResult)")
            } else {
                Text("")
            }
            if let creatorResult = bet.creatorResult {
                Text("Creator Selected Result: \(creatorResult)")
            } else {
                Text("")
            }
            if let middlemanResult = bet.middlemanResult {
                Text("Middleman Selected Result: \(middlemanResult)")
            } else {
                Text("")
            }
            if let result = bet.result {
                Text("Result: \(result)")
                    .fontWeight(.bold)
            } else {
                Text("Result: Pending")
            }
            Spacer()
        }
        .padding()
        .navigationBarTitle("Bet Details", displayMode: .inline)
    }
    
    func fetchCurrentUserEmail() {
        if let email = Auth.auth().currentUser?.email {
            currentUserEmail = email
        } else {
            currentUserEmail = ""
        }
    }
}


