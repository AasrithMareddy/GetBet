import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct NotificationsView: View {
    @Binding var pendingBetsCount: Int
    @State private var selectedTab = 0
    @State private var pendingBets = [Bet]()
    @State private var rejectedBets = [Bet]()
    let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            Picker("Notifications", selection: $selectedTab) {
                Text("Pending").tag(0)
                Text("Rejected").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedTab == 0 {
                NotificationListView(bets: pendingBets, userEmail: Auth.auth().currentUser?.email ?? "")
            } else {
                NotificationListView(bets: rejectedBets, userEmail: Auth.auth().currentUser?.email ?? "")
            }
        }
        .navigationBarTitle("Notifications", displayMode: .inline)
        .onAppear {
            NotificationsView.fetchBets { count, pendingBets, rejectedBets in
                self.pendingBetsCount = count
                self.pendingBets = pendingBets
                self.rejectedBets = rejectedBets
            }
        }
    }
    
    static func fetchBets(completion: @escaping (Int, [Bet], [Bet]) -> Void) {
        guard let email = Auth.auth().currentUser?.email else {
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
            let pendingBets = allBets.filter {
                $0.status == "pending"
            }
            let rejectedBets = allBets.filter {
                $0.status == "rejected"
            }
            completion(pendingBets.count, pendingBets, rejectedBets)
        }
    }
}

struct NotificationListView: View {
    var bets: [Bet]
    var userEmail: String
    
    var body: some View {
        List(bets) { bet in
            NavigationLink(destination: BetDetailView(bet: bet)) {
                VStack(alignment: .leading) {
                    Text(bet.title)
                        .font(.headline)
                    Text("Created by: \(bet.createdBy)")
                    Text("Amount: \(bet.amount) \(bet.currency)")
                    Text("Your Designation for the bet: \(BetManager.shared.getDesignation(for: bet, email: userEmail))")
                    Text("Timestamp: \(bet.timestamp.dateValue(), formatter: dateFormatter)")
                }
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
