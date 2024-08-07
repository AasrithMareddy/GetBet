import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct BetDetailView: View {
    @StateObject private var betViewModel: BetViewModel
    var bet: Bet
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccessAnimation = false
    @State private var successMessage = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var currentUserEmail: String = ""

    init(bet: Bet) {
        self.bet = bet
        _betViewModel = StateObject(wrappedValue: BetViewModel(bet: bet))
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let bet = betViewModel.bet {
                Text("Title: \(bet.title)")
                    .font(.headline)
                Text("Description: \(bet.description)")
                Text("Created By: \(bet.createdBy)")
                Text("Amount: \(bet.amount)")
                Text("Currency: \(bet.currency)")
                Text("Conditions: \(bet.conditions)")
                Text("Participant: \(bet.participant)")
                if let middlemanEmail = bet.middlemanEmail {
                    Text("Middleman: \(middlemanEmail)")
                    Text("Middleman Status: \(bet.middlemanStatus)")
                }
                Text("Designation: \(BetManager.shared.getDesignation(for: bet, email: currentUserEmail))")
                Text("Status: \(bet.status)")
                Text("Timestamp: \(bet.timestamp.dateValue(), formatter: dateFormatter)")
                
                Spacer()
                
                if bet.status == "pending" {
                    if isParticipant() {
                        HStack {
                            if bet.participantStatus == "pending" {
                                Button(action: {
                                    updateParticipantStatus(to: "accepted")
                                }) {
                                    Text("Accept")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                Button(action: {
                                    updateParticipantStatus(to: "rejected")
                                }) {
                                    Text("Reject")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            } else {
                                Text("You have already \(bet.participantStatus).")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                    } else if isCreator() {
                        Button(action: {
                            updateBetStatus(to: "rejected")
                        }) {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                    } else if isMiddleman() {
                        HStack {
                            if bet.middlemanStatus == "pending" {
                                Button(action: {
                                    updateMiddlemanStatus(to: "accepted")
                                }) {
                                    Text("Accept")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                Button(action: {
                                    updateMiddlemanStatus(to: "rejected")
                                }) {
                                    Text("Reject")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            } else {
                                Text("You have already \(bet.middlemanStatus).")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("Bet has been \(bet.status).")
                        .foregroundColor(.gray)
                }
            } else {
                Text("Loading bet details...")
            }
        }
        .padding()
        .navigationBarTitle("Bet Details", displayMode: .inline)
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $showSuccessAnimation) {
            SuccessView(message: successMessage)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSuccessAnimation = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        }
        .onAppear {
            fetchCurrentUserEmail()
            betViewModel.startListening()
        }
        .onDisappear {
            betViewModel.stopListening()
        }
    }
    
    func isParticipant() -> Bool {
        return currentUserEmail == betViewModel.bet?.participant
    }
    
    func isMiddleman() -> Bool {
        return currentUserEmail == betViewModel.bet?.middlemanEmail
    }
    
    func isCreator() -> Bool {
        return currentUserEmail == betViewModel.bet?.createdBy
    }
    
    func fetchCurrentUserEmail() {
        if let email = Auth.auth().currentUser?.email {
            currentUserEmail = email
        } else {
            errorMessage = "Unable to fetch user email."
            showError = true
        }
    }
    
    func updateMiddlemanStatus(to newStatus: String) {
        successMessage = "Bet status updated to \(newStatus) successfully!"
        showSuccessAnimation = true
        guard let betId = betViewModel.bet?.id else { return }
        BetManager.shared.updateMiddlemanStatus(betId: betId, middlemanStatus: newStatus) { result in
            handleResult(result, newStatus: newStatus)
        }
    }
    
    func updateParticipantStatus(to newStatus: String) {
        successMessage = "Bet status updated to \(newStatus) successfully!"
        showSuccessAnimation = true
        guard let betId = betViewModel.bet?.id else { return }
        BetManager.shared.updateParticipantStatus(betId: betId, participantStatus: newStatus) { result in
            handleResult(result, newStatus: newStatus)
            
        }
    }
    
    func handleResult(_ result: Result<Void, Error>, newStatus: String) {
        switch result {
        case .success():
            checkAndUpdateBetStatus()
        case .failure(let error):
            DispatchQueue.main.async {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    func checkAndUpdateBetStatus() {
        if let bet = betViewModel.bet, bet.participantStatus == "accepted" && bet.middlemanStatus == "accepted" {
            updateBetStatus(to: "accepted")
        } else if let bet = betViewModel.bet, bet.participantStatus == "rejected" || bet.middlemanStatus == "rejected" {
            updateBetStatus(to: "rejected")
        }
        // If both statuses are pending or mixed, bet status remains "pending"
    }

    func updateBetStatus(to newStatus: String) {
        guard let betId = betViewModel.bet?.id else { return }
        BetManager.shared.updateBetStatus(betId: betId, result: "", status: newStatus) { result in
            handleResult(result, newStatus: newStatus)
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}



