import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CustomBetView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var participant: String = ""
    @State private var conditions: String = ""
    @State private var middlemanEmail: String = ""
    @State private var amount: String = ""
    @State private var currency: String = "Virtual"
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var showSuccessAnimation = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Form {
                BetDetailsSection(title: $title, description: $description)
                ParticipantsSection(participant: $participant)
                ConditionsSection(conditions: $conditions)
                MiddlemanSection(middlemanEmail: $middlemanEmail)
                AmountSection(amount: $amount, currency: $currency)
                
                SubmitButton(
                    isLoading: $isLoading,
                    showSuccessAnimation: $showSuccessAnimation,
                    title: title,
                    participant: participant,
                    amount: amount,
                    middlemanEmail: middlemanEmail,
                    conditions: conditions,
                    description: description,
                    currency: currency,
                    showAlert: $showAlert,
                    alertMessage: $alertMessage,
                    presentationMode: presentationMode
                )
            }
        }
        .navigationBarTitle("Create Custom Bet", displayMode: .inline)
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $showSuccessAnimation) {
            SuccessView(message: "Bet added successfully!")
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSuccessAnimation = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        }
    }
}

struct BetDetailsSection: View {
    @Binding var title: String
    @Binding var description: String
    
    var body: some View {
        Section(header: Text("Bet Details")) {
            TextField("Bet Title", text: $title)
            TextField("Bet Description", text: $description)
        }
    }
}

struct ParticipantsSection: View {
    @Binding var participant: String
    
    var body: some View {
        Section(header: Text("Participant")) {
            TextField("Participant Email", text: $participant)
        }
    }
}

struct ConditionsSection: View {
    @Binding var conditions: String
    
    var body: some View {
        Section(header: Text("Conditions")) {
            TextField("Conditions", text: $conditions)
        }
    }
}

struct MiddlemanSection: View {
    @Binding var middlemanEmail: String
    
    var body: some View {
        Section(header: Text("Middleman Option")) {
            TextField("Middleman Email", text: $middlemanEmail)
        }
    }
}

struct AmountSection: View {
    @Binding var amount: String
    @Binding var currency: String
    
    var body: some View {
        Section(header: Text("Bet Amount")) {
            TextField("Amount", text: $amount)
                .keyboardType(.decimalPad)
            
            Picker("Currency", selection: $currency) {
                Text("Real").tag("Real")
                Text("Virtual").tag("Virtual")
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

struct SubmitButton: View {
    @Binding var isLoading: Bool
    @Binding var showSuccessAnimation: Bool
    var title: String
    var participant: String
    var amount: String
    var middlemanEmail: String
    var conditions: String
    var description: String
    var currency: String
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    var presentationMode: Binding<PresentationMode>

    var body: some View {
        Button(action: {
            guard let userEmail = Auth.auth().currentUser?.email else { return }

            isLoading = true
            Task { // Use Task for asynchronous operations
                do {
                    if title.isEmpty {
                        alertMessage = "Bet title is required."
                        showAlert = true
                        isLoading = false
                    } else if participant.isEmpty || participant.contains("") {
                        alertMessage = "One participant email is required."
                        showAlert = true
                        isLoading = false
                    } else if participant.lowercased() == userEmail {
                        alertMessage = "You cannot add yourself as a participant."
                        showAlert = true
                        isLoading = false
                    } else if middlemanEmail.lowercased() == userEmail {
                        alertMessage = "You cannot add yourself as a middleman."
                        showAlert = true
                        isLoading = false
                    } else if amount.isEmpty {
                        alertMessage = "Bet amount is required."
                        showAlert = true
                        isLoading = false
                    } else {
                        // Check if participant email exists (if not empty)
                        if !participant.isEmpty {
                            let participantExists = try await AuthenticationManager.shared.checkEmailExists(email: participant.lowercased())
                            if !participantExists {
                                alertMessage = "Participant email does not exist."
                                showAlert = true
                                isLoading = false
                                return // Stop the process if email doesn't exist
                            }
                        }

                        // Check if middleman email exists (if not empty)
                        if !middlemanEmail.isEmpty {
                            let middlemanExists = try await AuthenticationManager.shared.checkEmailExists(email: middlemanEmail.lowercased())
                            if !middlemanExists {
                                alertMessage = "Middleman email does not exist."
                                showAlert = true
                                isLoading = false
                                return // Stop the process if email doesn't exist
                            }
                        }
                        let bet = Bet(
                            title: title,
                            description: description,
                            participant: participant.lowercased(),
                            conditions: conditions,
                            middlemanEmail: middlemanEmail.isEmpty ? nil : middlemanEmail.lowercased(),
                            middlemanStatus: "pending",
                            participantStatus: "pending",
                            amount: amount,
                            currency: currency,
                            status: "pending",
                            createdBy: userEmail.lowercased(),
                            result: nil,
                            participantResult: nil,
                            creatorResult: nil,
                            middlemanResult: nil,
                            timestamp: Timestamp(date: Date()),
                            votedUsers: []
                        )

                        BetManager.shared.createBet(bet: bet) { result in
                            isLoading = false
                            switch result {
                            case .success():
                                showSuccessAnimation = true
                            case .failure(let error):
                                alertMessage = "Error creating bet: \(error.localizedDescription)"
                                showAlert = true
                            }
                        }
                    }
                } catch {
                    alertMessage = "Error checking email existence: \(error.localizedDescription)"
                    showAlert = true
                    isLoading = false
                }
            }
        }) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            } else {
                Text("Submit Bet")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .disabled(isLoading)
    }
}



struct CustomBetView_Previews: PreviewProvider {
    static var previews: some View {
        CustomBetView()
    }
}
