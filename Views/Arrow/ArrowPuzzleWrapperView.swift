import SwiftUI

struct ArrowPuzzleWrapperView: View {
    @EnvironmentObject private var gameManager: GameManager
    @Environment(\.dismiss)    private var dismiss

    @State private var started = false
    @StateObject private var puzzleManager = ArrowPuzzleManager()

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.black.opacity(0.7))
                    }
                    .padding()
                }

                Spacer()

                if !started {
                    VStack(spacing: 20) {
                        Text("А что делать?")
                            .font(.largeTitle).bold()
                        Text("Нажимай на стрелки, чтобы очистить все поля \n Направления показывают, куда она улетит ➡️")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Начать") {
                            started = true
                        }
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(8)
                        .foregroundColor(.black)
                    }
                    .padding()
                } else {
                    ArrowPuzzleView()
                        .environmentObject(puzzleManager)
                        .environmentObject(gameManager)
                }

                Spacer()
            }
        }
    }
}
