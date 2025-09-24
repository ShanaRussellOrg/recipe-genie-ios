import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Recipe Genie")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("Welcome to Recipe Genie!")
                    .font(.title2)
                    .foregroundColor(.secondary)

                Text("This is a simplified version of the app for testing purposes.")
                    .multilineTextAlignment(.center)
                    .padding()

                Button("Continue") {
                    // This would navigate to the main app
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}