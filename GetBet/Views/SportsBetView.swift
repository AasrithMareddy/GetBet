import SwiftUI

struct SportsBetView: View {
    var body: some View {
        VStack {
            Text("Sports & Quantifiable Bets")
                .font(.title)
                .padding()

            // Search and Popular Bets
            VStack {
                TextField("Search Sports Bets", text: .constant(""))
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                // Replace with dynamic data
                Text("Popular Sports Bets")
                    .font(.headline)
                    .padding(.top)

                List {
                    NavigationLink(destination: SportsBetDetailView()) {
                        Text("Popular Bet 1")
                    }
                    NavigationLink(destination: SportsBetDetailView()) {
                        Text("Popular Bet 2")
                    }
                }
            }
        }
        .navigationBarTitle("Sports Bets", displayMode: .inline)
        .padding()
    }
}

struct SportsBetDetailView: View {
    @State private var selectedTeam: String = ""
    @State private var amount: String = ""
    @State private var currency: String = "Virtual"
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Select Team")) {
                    Picker("Team", selection: $selectedTeam) {
                        Text("Team A").tag("Team A")
                        Text("Team B").tag("Team B")
                    }
                }
                
                Section(header: Text("Bet Amount")) {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Currency", selection: $currency) {
                        Text("Real").tag("Real")
                        Text("Virtual").tag("Virtual")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Button(action: {
                    // Handle bet submission
                }) {
                    Text("Submit Bet")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
        }
        .navigationBarTitle("Place Sports Bet", displayMode: .inline)
        .padding()
    }
}

struct SportsBetView_Previews: PreviewProvider {
    static var previews: some View {
        SportsBetView()
    }
}
