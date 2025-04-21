import SwiftUI

struct SportsBetView: View {
    @State private var selectedSport: Sport = .soccer
    @State private var searchQuery: String = ""
    @State private var sportsResults: [String: Any]?
    @State private var winner: String = ""
    @State private var showError = false
    @State private var errorMessage = ""

    enum Sport: String, CaseIterable, Identifiable {
        case soccer, americanFootball, basketball, hockey, baseball, cricket, tennis, f1
        var id: String { self.rawValue }
    }

    var body: some View {
        VStack {
            Picker("Select Sport", selection: $selectedSport) {
                ForEach(Sport.allCases) { sport in
                    Text(sport.rawValue.capitalized).tag(sport)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            TextField("Enter Team/Player", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Search") {
                fetchSportsResults()
            }
            .padding()

            if let sportsResults = sportsResults {
                switch selectedSport {
                case .soccer, .americanFootball, .basketball, .hockey, .baseball:
                    TeamSportResultsView(results: sportsResults)
                case .tennis:
                    TennisResultsView(results: sportsResults)
                case .f1:
                    F1ResultsView(results: sportsResults)
                default:
                    Text("Results for \(selectedSport.rawValue.capitalized)")
                }

                if !winner.isEmpty {
                    Text("Winner: \(winner)")
                        .font(.headline)
                        .padding()
                }
            }
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }


    func fetchSportsResults() {
        guard let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            self.errorMessage = "Invalid search query"
            self.showError = true
            return
        }

        let urlString = "https://serpapi.com/search.json?q=\(encodedQuery)&location=austin, texas, united states&api_key=14fbf5e64af4652f0288edfda9500b29c3d5c2c7bd3247656d06d7e0afc27dd2"

        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
            self.showError = true
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received"
                    self.showError = true
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let sportsResults = json["sports_results"] as? [String: Any] {
                            self.sportsResults = sportsResults
                            self.determineWinner()
                        } else {
                            self.errorMessage = "No sports results found"
                            self.showError = true
                        }
                    }
                } catch {
                    self.errorMessage = "Failed to parse response"
                    self.showError = true
                }
            }
        }.resume()
    }


    func determineWinner() {
        guard let sportsResults = sportsResults else { return }

        switch selectedSport {
        case .soccer, .americanFootball, .basketball, .hockey, .baseball:
            if let games = sportsResults["games"] as? [[String: Any]], let lastGame = games.last {
                let teams = lastGame["teams"] as? [[String: Any]]
                let team1Score = teams?[0]["score"] as? Int ?? 0
                let team2Score = teams?[1]["score"] as? Int ?? 0

                if team1Score > team2Score {
                    winner = teams?[0]["name"] as? String ?? ""
                } else if team2Score > team1Score {
                    winner = teams?[1]["name"] as? String ?? ""
                } else {
                    winner = "Tie"
                }
            }
        case .tennis:
            if let tables = sportsResults["tables"] as? [String: Any],
               let games = tables["games"] as? [[String: Any]],
               let lastGame = games.last {
                let players = lastGame["players"] as? [[String: Any]]
                let player1Sets = players?[0]["sets"] as? [String: String]
                let player2Sets = players?[1]["sets"] as? [String: String]

                let player1WonSets = player1Sets?.values.filter { $0.count == 1 }.count ?? 0
                let player2WonSets = player2Sets?.values.filter { $0.count == 1 }.count ?? 0

                if player1WonSets > player2WonSets {
                    winner = players?[0]["name"] as? String ?? ""
                } else if player2WonSets > player1WonSets {
                    winner = players?[1]["name"] as? String ?? ""
                } else {
                    winner = "Tie or incomplete data"
                }
            }
        case .f1:
            if let tables = sportsResults["tables"] as? [String: Any],
               let standings = tables["standings"] as? [[String: Any]] {
                winner = standings.first?["name"] as? String ?? ""
            }
        default:
            break
        }
    }
}

// Views for displaying results (example - you'll need to customize these)
struct TeamSportResultsView: View {
    let results: [String: Any]

    var body: some View {
        // ... Display title, thumbnail, league, score, etc. from results
        Text("Team Sport Results") // Placeholder
    }
}

struct TennisResultsView: View {
    let results: [String: Any]

    var body: some View {
        // ... Display title, country, date, location, players, etc. from results
        Text("Tennis Results") // Placeholder
    }
}

struct F1ResultsView: View {
    let results: [String: Any]

    var body: some View {
        // ... Display title, ranking, date, standings, etc. from results
        Text("F1 Results") // Placeholder
    }
}
