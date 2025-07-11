import SwiftUI

enum BugGameFlowState {
    case ready, playing, gameOver(didWin: Bool)
}

struct BugGameWrapperView: View {
    // MARK: – Game State
    @State private var gameState: BugGameFlowState = .ready
    @State private var gameID = UUID()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var gameManager: GameManager

    // MARK: – Theme Colors
    private let lightBlue: Color = .backgroundColor
    private let darkGreen: Color = .backgroundColor

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                BugGameView(size: geometry.size, gameState: $gameState)
                    .id(gameID)
            }
            .ignoresSafeArea()

            VStack {
                switch gameState {
                case .ready:
                    BugInstructionView(
                        lightBlue: lightBlue,
                        darkGreen: darkGreen
                    ) {
                        gameState = .playing
                    }

                case .gameOver(let didWin):
                    if didWin {
                        BugVictoryView(
                            lightBlue: lightBlue,
                            darkGreen: darkGreen
                        )
                        .onAppear {
                            gameManager.complete(level: 4)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                dismiss()
                            }
                        }
                    } else {
                        BugGameOverView(
                            lightBlue: lightBlue,
                            darkGreen: darkGreen
                        ) {
                            // перезапустить уровень
                            gameState = .ready
                            gameID = UUID()
                        }
                    }

                case .playing:
                    // кнопка «закрыть» поверх игры
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.5)))
                        }
                        .padding()
                        Spacer()
                    }
                }
                Spacer()
            }
        }
    }
}

// MARK: – Instruction View

struct BugInstructionView: View {
    let lightBlue: Color
    let darkGreen: Color
    var onStart: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [lightBlue, darkGreen],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Image("bug")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                Text("Жук-собиратель")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                VStack(spacing: 15) {
                    Text("🎯 Цель: собери 100 сердечек")
                    Text("👆 Управление: тяни жука пальцем")
                    Text("⚠️ Избегай злых куриц!")
                }
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(15)

                Button("Начать", action: onStart)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 15)
                    .background(Color.white)
                    .foregroundColor(darkGreen)
                    .cornerRadius(25)
                    .shadow(radius: 5)
            }
            .padding()
        }
    }
}

// MARK: – Victory View

struct BugVictoryView: View {
    let lightBlue: Color
    let darkGreen: Color

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [lightBlue, darkGreen],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("🎉")
                    .font(.system(size: 100))

                Text("Победа!")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)

                Text("Жук собрал все сердечки!")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
    }
}

// MARK: – Game Over View

struct BugGameOverView: View {
    let lightBlue: Color
    let darkGreen: Color
    var onRestart: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [lightBlue, darkGreen],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("💔")
                    .font(.system(size: 80))

                Text("Жук устал...")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Попробуй ещё раз!")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))

                Button("Заново", action: onRestart)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 15)
                    .background(Color.white)
                    .foregroundColor(darkGreen)
                    .cornerRadius(25)
                    .shadow(radius: 5)
            }
            .padding()
        }
    }
}

#Preview {
    BugGameWrapperView()
}

