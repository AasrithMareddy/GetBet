import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct BetDetailView: View {
    var bet: Bet
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Title: \(bet.title)")
                .font(.headline)
            Text("Description: \(bet.description)")
            Text("Amount: \(bet.amount) \(bet.currency)")
            Text("Conditions: \(bet.conditions)")
            Text("Participants: \(bet.participants.joined(separator: ", "))")
            if let middlemanEmail = bet.middlemanEmail {
                Text("Middleman: \(middlemanEmail)")
            }
            Text("Status: \(bet.status)")
            Spacer()
            HStack {
                Button(action: {
                    updateBetStatus(to: "accepted")
                }) {
                    Text("Accept")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: {
                    updateBetStatus(to: "rejected")
                }) {
                    Text("Reject")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .padding()
        .navigationBarTitle("Bet Details", displayMode: .inline)
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func updateBetStatus(to newStatus: String) {
        guard let betId = bet.id else { return }
        let manager = BetManager.shared
        let completion: (Result<Void, Error>) -> Void = { result in
            switch result {
            case .success():
                print("Bet \(newStatus) successfully!")
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
        if newStatus == "accepted" {
            manager.acceptBet(betId: betId, completion: completion)
        } else {
            manager.rejectBet(betId: betId, completion: completion)
        }
    }
}

struct BetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BetDetailView(bet: Bet(
            title: "Sample Bet",
            description: "Sample Description",
            participants: ["example@example.com"],
            conditions: "Sample Conditions",
            middlemanEmail: nil,
            amount: "100",
            currency: "Virtual",
            status: "pending",
            createdBy: "creator@example.com",
            notifications: []
        ))
    }
}
