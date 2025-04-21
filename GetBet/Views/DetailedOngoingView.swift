import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct DetailedOngoingView: View {
    @StateObject var betViewModel: BetViewModel
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccessAnimation = false
    @State private var successMessage = ""
    @State private var showConfirmationAlert = false
    @State private var selectedResult: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var currentUserEmail: String = ""

    
    var body: some View {
        VStack(alignment: .leading) {
            if let bet = betViewModel.bet {
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

                if bet.status == "accepted" {
                    if !betViewModel.hasVoted && canVote(bet: bet) {
                        VStack {
                            Button(action: {
                                selectedResult = "\(bet.participant) won"
                                showConfirmationAlert = true
                            }) {
                                Text("\(bet.participant) Won")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            Button(action: {
                                selectedResult = "\(bet.createdBy) won"
                                showConfirmationAlert = true
                            }) {
                                Text("\(bet.createdBy) Won")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            Button(action: {
                                selectedResult = "tied"
                                showConfirmationAlert = true
                            }) {
                                Text("Tied")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.yellow)
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                    } else if betViewModel.hasVoted {
                        Text("You have already voted.")
                    } else if !canVote(bet: bet) {
                        Text("Waiting for other participants to vote.")
                            .foregroundColor(.gray)
                    }
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
        .alert(isPresented: $showConfirmationAlert) {
           Alert(
               title: Text("Confirm Result"),
               message: Text("Are you sure you want to set the result to '\(selectedResult)'?"),
               primaryButton: .default(Text("Confirm"), action: {
                   updateBetSelectedResult()
               }),
               secondaryButton: .cancel()
           )
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
            betViewModel.startListening() // Start listening for bet updates
        }
        .onDisappear {
            betViewModel.stopListening() // Stop listening when view disappears
        }
    }

    func fetchCurrentUserEmail() {
        if let email = Auth.auth().currentUser?.email {
            currentUserEmail = email
        } else {
            errorMessage = "Unable to fetch user email."
            showError = true
        }
    }


    func updateBetSelectedResult() {
        guard let betId = betViewModel.bet?.id else { return }

        let manager = BetManager.shared
        var roleField: String

        if isParticipant() {
            roleField = "participantResult"
        } else if isCreator() {
            roleField = "creatorResult"
        } else if isMiddleman() {
            roleField = "middlemanResult"
        } else {
            errorMessage = "Unable to determine role."
            showError = true
            return
        }

        manager.updateBetSelectedResult(betId: betId, result: selectedResult, role: roleField) { result in
            switch result {
            case .success:
                successMessage = "Result selected successfully!"
                showSuccessAnimation = true
                manager.addVotedUser(betId: betId, email: currentUserEmail) { result in
                    switch result {
                    case .success:
                        checkIfBetCompleted()
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    func checkIfBetCompleted() {
        guard let bet = betViewModel.bet, let betId = bet.id else { return }

        let manager = BetManager.shared

        guard let participantResult = bet.participantResult,
              let creatorResult = bet.creatorResult else {
            // Not all votes are in yet
            return
        }

        // Check for an early resolution (participant and creator agree)
        if participantResult == creatorResult {
            manager.updateBetStatus(betId: betId, result: participantResult, status: "completed") { result in
                switch result {
                case .success:
                    successMessage = "Bet completed successfully with result: \(participantResult)"
                    showSuccessAnimation = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
            return  // Exit the function early since the bet is resolved
        }
        
        // Handle middleman scenarios
        if let middlemanEmail = bet.middlemanEmail {
            if let middlemanResult = bet.middlemanResult {
                // Middleman has voted and we have a tie
                manager.updateBetStatus(betId: betId, result: middlemanResult, status: "completed") { result in
                    switch result {
                    case .success:
                        successMessage = "Bet completed successfully with result: \(middlemanResult)"
                        showSuccessAnimation = true
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            } else {
                // Votes are different, but middleman hasn't voted yet
                errorMessage = "Waiting for the middleman to break the tie."
                showError = true
            }
        } else {
            // No middleman, and the votes are different, it's a tie
            manager.updateBetStatus(betId: betId, result: "tied", status: "completed") { result in
                switch result {
                case .success:
                    successMessage = "Bet completed as a tie."
                    showSuccessAnimation = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    func canVote(bet: Bet) -> Bool {
        if isParticipant() || isCreator() {
            return true
        } else if isMiddleman() {
            guard let participantResult = bet.participantResult,
                  let creatorResult = bet.creatorResult else {
                return false // Participant or creator hasn't voted yet
            }
            return participantResult != creatorResult // Only allow middleman if votes differ
        }
        return false // User isn't involved in this bet
    }



    func userHasVoted() -> Bool {
        betViewModel.bet?.votedUsers.contains(currentUserEmail) ?? false
    }

    func isCreator() -> Bool {
        betViewModel.bet?.createdBy == currentUserEmail
    }

    func isParticipant() -> Bool {
        betViewModel.bet?.participant == currentUserEmail
    }

    func isMiddleman() -> Bool {
        betViewModel.bet?.middlemanEmail == currentUserEmail
    }
}
