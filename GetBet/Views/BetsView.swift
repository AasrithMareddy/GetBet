import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct BetsView: View {
    @State private var selectedTab = 0
    @State private var ongoingBets = [Bet]()
    @State private var completedBets = [Bet]()
    let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            Picker("Bets", selection: $selectedTab) {
                Text("Ongoing").tag(0)
                Text("Completed").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedTab == 0 {
                List(ongoingBets) { bet in
                    VStack(alignment: .leading) {
                        Text(bet.title)
                            .font(.headline)
                        Text(bet.amount)
                            .font(.subheadline)
                    }
                }
            } else {
                List(completedBets) { bet in
                    VStack(alignment: .leading) {
                        Text(bet.title)
                            .font(.headline)
                        Text(bet.amount)
                            .font(.subheadline)
                    }
                }
            }
        }
        .navigationBarTitle("Your Bets", displayMode: .inline)
        .onAppear(perform: fetchBets)
    }
    
    func fetchBets() {
        guard let email = Auth.auth().currentUser?.email else { return }
        
        db.collection("bets")
            .whereField("participants", arrayContains: email)
            .getDocuments { participantSnapshot, error in
                if let error = error {
                    print("Error fetching participant documents: \(error)")
                } else {
                    let participantBets = participantSnapshot?.documents.compactMap { doc -> Bet? in
                        try? doc.data(as: Bet.self)
                    } ?? []
                    
                    db.collection("bets")
                        .whereField("createdBy", isEqualTo: email)
                        .getDocuments { creatorSnapshot, error in
                            if let error = error {
                                print("Error fetching creator documents: \(error)")
                            } else {
                                let creatorBets = creatorSnapshot?.documents.compactMap { doc -> Bet? in
                                    try? doc.data(as: Bet.self)
                                } ?? []
                                
                                let allBets = participantBets + creatorBets
                                
                                self.ongoingBets = allBets.filter { $0.status == "accepted" }
                                self.completedBets = allBets.filter { $0.status == "completed" }
                            }
                        }
                }
            }
    }
}
    



