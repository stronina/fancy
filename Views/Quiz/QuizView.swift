import SwiftUI

struct QuizView: View {
    @EnvironmentObject private var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss

    @StateObject private var manager = QuizManager()
    @State private var showGameOver = false

    var body: some View {
        ZStack {
            // Фон
            Color.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Викторина")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                    .padding(.top, 40)

                // Сердечки по центру
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { idx in
                        Image(systemName: idx < manager.lives ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }

                // Кнопка закрыть под сердечками
                Button("Закрыть") {
                    dismiss()
                }
                .foregroundColor(.white)
                .padding(.bottom, 10)

                Spacer(minLength: 50)

                // Вопрос
                Text(manager.currentQuestion.text)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                // Варианты ответов
                VStack(spacing: 12) {
                    ForEach(manager.currentQuestion.answers.indices, id: \.self) { idx in
                        Button {
                            handleAnswer(idx)
                        } label: {
                            Text(manager.currentQuestion.answers[idx])
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        // Sheet для Game Over
        .sheet(isPresented: $showGameOver) {
            QuizGameOverView(
                onRetry: {
                    manager.reset()
                    showGameOver = false
                },
                onExit: {
                    dismiss()
                }
            )
        }
    }

    // MARK: – Логика ответа
    private func handleAnswer(_ idx: Int) {
        let correct = manager.submit(answer: idx)
        if !correct {
            if manager.lives == 0 {
                showGameOver = true
            }
            return
        }
        if manager.currentQuestionIndex < manager.questions.count - 1 {
            manager.advance()
        } else {
            gameManager.complete(level: 1)
            dismiss()
        }
    }
}

// MARK: – Экран «Поражение»

struct QuizGameOverView: View {
    let onRetry: () -> Void
    let onExit: () -> Void

    var body: some View {
        ZStack {
            Color.backgroundColor
                .ignoresSafeArea()
            VStack(spacing: 30) {
                Text("💔")
                    .font(.system(size: 80))
                Text("Жизни кончились")
                    .font(.title).bold()
                    .foregroundColor(.white)
                HStack(spacing: 20) {
                    Button("Попробовать ещё раз", action: onRetry)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.black)
                        .cornerRadius(10)

                    Button("Выбрать другой уровень", action: onExit)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

#Preview {
    QuizView()
        .environmentObject(GameManager())
}
