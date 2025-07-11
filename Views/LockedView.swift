import SwiftUI

struct LockedView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.gray.opacity(0.8), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 25) {
                Image(systemName: "lock.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .shadow(radius: 10)

                Text("но-но-но, мистер фиш!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Этот фэнси-подарок можно будет открыть только в твой день рождения. Наберись терпения 😉")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
}

#Preview {
    LockedView()
}
