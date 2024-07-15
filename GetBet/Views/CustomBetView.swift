import SwiftUI
import FirebaseAuth

struct CustomBetView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var participants: [String] = []
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
                ParticipantsSection(participants: $participants)
                ConditionsSection(conditions: $conditions)
                MiddlemanSection(middlemanEmail: $middlemanEmail)
                AmountSection(amount: $amount, currency: $currency)
                
                SubmitButton(
                    isLoading: $isLoading,
                    showSuccessAnimation: $showSuccessAnimation,
                    title: title,
                    participants: participants,
                    amount: amount,
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
            SuccessView()
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
    @Binding var participants: [String]
    
    var body: some View {
        Section(header: Text("Participants")) {
            ForEach(participants.indices, id: \.self) { index in
                TextField("Participant Email", text: $participants[index])
            }
            Button(action: {
                participants.append("")
            }) {
                Text("Add Participant")
            }
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
    var participants: [String]
    var amount: String
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Button(action: {
            guard let userEmail = Auth.auth().currentUser?.email else { return }
            if title.isEmpty {
                alertMessage = "Bet title is required."
                showAlert = true
            } else if participants.isEmpty || participants.contains("") {
                alertMessage = "At least one participant email is required."
                showAlert = true
            } else if participants.contains(userEmail) {
                alertMessage = "You cannot add yourself as a participant."
                showAlert = true
            } else if amount.isEmpty {
                alertMessage = "Bet amount is required."
                showAlert = true
            } else {
                isLoading = true
                let bet = Bet(
                    title: title,
                    description: "",
                    participants: participants,
                    conditions: "",
                    middlemanEmail: nil,
                    amount: amount,
                    currency: "Virtual",
                    status: "pending",
                    createdBy: userEmail,
                    notifications: []
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

struct SuccessView: View {
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
            Text("Bet added successfully!")
                .font(.title)
                .padding()
        }
    }
}

struct CustomBetView_Previews: PreviewProvider {
    static var previews: some View {
        CustomBetView()
    }
}
