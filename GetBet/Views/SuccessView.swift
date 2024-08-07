import SwiftUI

struct SuccessView: View {
    var message: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding() // Add outer padding for spacing around the view
    }
}
