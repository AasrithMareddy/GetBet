import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct BetsView: View {
    @Binding var ongoingBetsCount: Int
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
                    NavigationLink(destination: DetailedOngoingView(betViewModel: BetViewModel(bet: bet))) {
                        VStack(alignment: .leading) {
                            Text(bet.title)
                                .font(.headline)
                            Text("Created by: \(bet.createdBy)")
                            Text("Amount: \(bet.amount)")
                        }
                    }
                }
            } else {
                List(completedBets) { bet in
                    NavigationLink(destination: DetailedCompletedView(bet: bet)) {
                        VStack(alignment: .leading) {
                            Text(bet.title)
                                .font(.headline)
                            Text("Created by: \(bet.createdBy)")
                            Text("Amount: \(bet.amount)")
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Your Bets", displayMode: .inline)
        .onAppear {
            BetsView.fetchBets { count, ongoingBets, completedBets in
                self.ongoingBetsCount = count
                self.ongoingBets = ongoingBets
                self.completedBets = completedBets
            }
        }
    }
    
    static func fetchBets(completion: @escaping (Int, [Bet], [Bet]) -> Void) {
        guard let email = Auth.auth().currentUser?.email else {
            print("User not authenticated")
            completion(0, [], [])
            return
        }
        
        let db = Firestore.firestore()
        let participantQuery = db.collection("bets")
            .whereField("participant", isEqualTo: email)
        let creatorQuery = db.collection("bets")
            .whereField("createdBy", isEqualTo: email)
        let middlemanQuery = db.collection("bets")
            .whereField("middlemanEmail", isEqualTo: email)
        
        let group = DispatchGroup()
        
        var participantBets: [Bet] = []
        var createdBets: [Bet] = []
        var middlemanBets: [Bet] = []
        
        group.enter()
        participantQuery.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching participant documents: \(error)")
            } else {
                participantBets = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Bet.self)
                } ?? []
            }
            group.leave()
        }
        
        group.enter()
        creatorQuery.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching creator documents: \(error)")
            } else {
                createdBets = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Bet.self)
                } ?? []
            }
            group.leave()
        }
        
        group.enter()
        middlemanQuery.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching middleman documents: \(error)")
            } else {
                middlemanBets = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Bet.self)
                } ?? []
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            let allBets = participantBets + createdBets + middlemanBets
            let ongoingBets = allBets.filter { $0.status == "accepted"}
            let completedBets = allBets.filter { $0.status == "completed" }
            
            completion(ongoingBets.count, ongoingBets, completedBets)
        }
    }
}
