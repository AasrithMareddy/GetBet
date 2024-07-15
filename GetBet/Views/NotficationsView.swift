import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct NotificationsView: View {
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
                NotificationListView(bets: pendingBets)
            } else {
                NotificationListView(bets: rejectedBets)
            }
        }
        .navigationBarTitle("Notifications", displayMode: .inline)
        .onAppear(perform: fetchBets)
    }
    
    func fetchBets() {
        guard let email = Auth.auth().currentUser?.email else { return }
        
        db.collection("bets")
            .whereField("participants", arrayContains: email)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching participant documents: \(error)")
                    return
                }
                
                let participantBets = snapshot?.documents.compactMap { doc -> Bet? in
                    try? doc.data(as: Bet.self)
                } ?? []
                
                db.collection("bets")
                    .whereField("createdBy", isEqualTo: email)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("Error fetching creator documents: \(error)")
                            return
                        }
                        
                        let createdBets = snapshot?.documents.compactMap { doc -> Bet? in
                            try? doc.data(as: Bet.self)
                        } ?? []
                        
                        let allBets = participantBets + createdBets
                        
                        // Debug output to check the fetched data
                        print("Fetched participantBets: \(participantBets)")
                        print("Fetched createdBets: \(createdBets)")
                        print("Fetched allBets: \(allBets)")
                        
                        self.pendingBets = allBets.filter { $0.status == "pending" }
                        self.rejectedBets = allBets.filter { $0.status == "rejected" }
                        
                        // Debug output to check the filtered data
                        print("Filtered pendingBets: \(self.pendingBets)")
                        print("Filtered rejectedBets: \(self.rejectedBets)")
                    }
            }
    }
}

struct NotificationListView: View {
    var bets: [Bet]
    
    var body: some View {
        List(bets) { bet in
            NavigationLink(destination: BetDetailView(bet: bet)) {
                VStack(alignment: .leading) {
                    Text(bet.title)
                        .font(.headline)
                    Text("Created by: \(bet.createdBy)")
                    Text("Amount: \(bet.amount) \(bet.currency)")
                    if let notification = bet.notifications.first(where: { $0.email == Auth.auth().currentUser?.email }) {
                        Text(notification.message)
                        Text("Timestamp: \(notification.timestamp.dateValue(), formatter: dateFormatter)")
                    }
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

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
