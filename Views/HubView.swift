import SwiftUI

struct LevelIdentifier: Identifiable {
    let id: Int
}

struct HubView: View {
    @EnvironmentObject private var gameManager: GameManager
    @State private var activeSheet: LevelIdentifier?

    // Сетка из 2 колонок
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        ZStack {
            // Фон
            Color.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                Text("Выбери испытание")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 10)

                // Кнопки уровней
                LazyVGrid(columns: columns, spacing: 20) {
                    levelButton(
                        levelNumber: 1,
                        imageName: "quiz_icon",
                        fallbackIcon: "questionmark.circle.fill"
                    )
                    levelButton(
                        levelNumber: 2,
                        imageName: "arrow_icon",
                        fallbackIcon: "book.fill"
                    )
                    levelButton(
                        levelNumber: 3,
                        imageName: "chicken_1",
                        fallbackIcon: "puzzlepiece.fill"
                    )
                    levelButton(
                        levelNumber: 4,
                        imageName: "bug",
                        fallbackIcon: "paintbrush.fill"
                    )
                }
                .padding(.horizontal)

                // Секретный хард-уровень
                if gameManager.completedLevels.count >= 4 {
                    Button {
                        activeSheet = LevelIdentifier(id: 5)
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.title)
                            Text("СЕКРЕТНЫЙ УРОВЕНЬ")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.yellow)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.red.opacity(0.8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.yellow, lineWidth: 3)
                                )
                        )
                    }
                    .shadow(color: .yellow.opacity(0.5), radius: 10)
                }

                Spacer()
            }
            .padding(.vertical)
        }
        // Показываем нужный экран по id
        .fullScreenCover(item: $activeSheet) { item in
            Group {
                switch item.id {
                case 1: QuizView()
                case 2: ArrowPuzzleWrapperView()
                case 3: ChickenGameWrapperView()
                case 4: BugGameWrapperView()
                case 5: Text("Арканоид – в разработке")
                default: EmptyView()
                }
            }
            .environmentObject(gameManager)
        }
    }

    @ViewBuilder
    private func levelButton(
        levelNumber: Int,
        imageName: String,
        fallbackIcon: String?
    ) -> some View {
        let isCompleted = gameManager.completedLevels.contains(levelNumber)

        Button {
            // открываем уровень, только если ещё не пройден
            if !isCompleted {
                activeSheet = LevelIdentifier(id: levelNumber)
            }
        } label: {
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)
            } else if UIImage(named: imageName) != nil {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            } else if let icon = fallbackIcon {
                Image(systemName: icon)
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)
            }
        }
        .frame(width: 160, height: 160)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isCompleted ? Color.accentColor.opacity(0.5) : Color.accentColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isCompleted ? Color.accentColor : Color.clear, lineWidth: 3)
        )
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
        .scaleEffect(isCompleted ? 0.95 : 1.0)
        .disabled(isCompleted)
    }
}

#Preview {
    HubView()
        .environmentObject(GameManager())
}
