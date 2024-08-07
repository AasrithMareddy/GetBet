import SwiftUI

struct HomePageView: View {
    @ObservedObject var authState: AuthState
    @State private var pendingBetsCount = 0
    @State private var ongoingBetsCount = 0

    var body: some View {
        TabView {
            HomeTabView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BetsView(ongoingBetsCount: $ongoingBetsCount)
                .tabItem {
                    Label("Bets", systemImage: "sportscourt.fill")
                }
                .badge(ongoingBetsCount)
            
            NotificationsView(pendingBetsCount: $pendingBetsCount)
                .tabItem {
                    Label("Notifications", systemImage: "bell.fill")
                }
                .badge(pendingBetsCount)
            
            SettingsView(authState: authState)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{
            fetchPendingBets()
            fetchOngoingBets()
        }
    }
    
    private func fetchPendingBets() {
        NotificationsView.fetchBets { pendingCount, _, _ in
            self.pendingBetsCount = pendingCount
        }
    }
    
    private func fetchOngoingBets() {
        BetsView.fetchBets { ongoingCount, _, _ in
            self.ongoingBetsCount = ongoingCount
        }
    }
}





struct HomeTabView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(destination: CustomBetView()) {
                    HomeCardView(title: "Custom Bet", image: "doc.text.fill", color: .blue)
                }
                
                NavigationLink(destination: SportsBetView()) {
                    HomeCardView(title: "Quantifiable Bet", image: "sportscourt.fill", color: .green)
                }
            }
            .padding()
            .navigationBarTitle("Home", displayMode: .inline)
        }
    }
}

struct HomeCardView: View {
    let title: String
    let image: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: image)
                .foregroundColor(.white)
                .font(.largeTitle)
                .padding()
            
            Text(title)
                .foregroundColor(.white)
                .font(.headline)
            
            Spacer()
        }
        .padding()
        .frame(height: 80)
        .background(LinearGradient(gradient: Gradient(colors: [color, color.opacity(0.8)]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(10)
        .shadow(color: color.opacity(0.6), radius: 10, x: 0, y: 5)
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView(authState: AuthState())
    }
}
