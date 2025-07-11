import SwiftUI

enum ChickenGameFlowState {
    case ready, playing, gameOver(didWin: Bool)
}

struct ChickenGameWrapperView: View {
    // MARK: – Game State
    @State private var gameState: ChickenGameFlowState = .ready
    @State private var gameID = UUID()
    @Environment(\.dismiss) private var dismiss

    // MARK: – Theme Colors
    private let lightBlue: Color = .backgroundColor
    private let darkGreen: Color = .backgroundColor

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ChickenGameView(
                    size: geometry.size,
                    gameState: $gameState
                )
                .id(gameID)
            }
            .ignoresSafeArea()

            VStack {
                switch gameState {
                case .ready:
                    ChickenInstructionView(
                        lightBlue: lightBlue,
                        darkGreen: darkGreen
                    ) {
                        gameState = .playing
                    }

                case .playing:
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.5)))
                        }
                        .padding()
                    }

                case .gameOver(let didWin):
                    if didWin {
                        ChickenVictoryView(
                            lightBlue: lightBlue,
                            darkGreen: darkGreen
                        )
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                dismiss()
                            }
                        }
                    } else {
                        ChickenGameOverView(
                            lightBlue: lightBlue,
                            darkGreen: darkGreen
                        ) {
                            gameState = .ready
                            gameID = UUID()
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

// MARK: – Instruction View

struct ChickenInstructionView: View {
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
                Image("chicken_1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                Text("Голосовая курица")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                VStack(spacing: 15) {
                    Text("🎤 Управление голосом:")
                    Text("Тихий звук = шаг")
                    Text("Громкий звук = прыжок")
                    Text("🎯 Цель: пройти 100 шагов")
                }
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(15)

                Text("⚠️ Разреши доступ к микрофону!")
                    .font(.headline)
                    .foregroundColor(.yellow)

                Button(action: onStart) {
                    Text("Начать")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 15)
                        .background(Color.white)
                        .foregroundColor(darkGreen)
                        .cornerRadius(25)
                        .shadow(radius: 5)
                }
            }
            .padding()
        }
    }
}

// MARK: – Victory View

struct ChickenVictoryView: View {
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
                Text("🐔")
                    .font(.system(size: 100))

                Text("Победа!")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)

                Text("Курица дошла до цели!")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
    }
}

// MARK: – Game Over View

struct ChickenGameOverView: View {
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

                Text("Курица упала!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Попробуй ещё раз")
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
    ChickenGameWrapperView()
}

