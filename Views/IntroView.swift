import SwiftUI

struct IntroView: View {
    @State private var showButton = false
    var onStart: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 30) {
                Text("🐣 Привет, фэнси-человек!")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                Text("""
Тебя ждут странные, весёлые и неожиданные испытания.

Пройди их все, чтобы получить сюрприз 🎁
""")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding()

                if showButton {
                    Button("Начать фэнси-приключение", action: onStart)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .onAppear {
                // Показываем кнопку через 2.5 сек
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showButton = true
                }
            }
        }
    }
}

#Preview {
    IntroView(onStart: {})
}
