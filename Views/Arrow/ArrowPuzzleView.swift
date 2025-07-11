import SwiftUI

struct ArrowPuzzleView: View {
    @EnvironmentObject private var puzzleManager: ArrowPuzzleManager
    @EnvironmentObject private var gameManager: GameManager
    @Environment(\.dismiss)    private var dismiss

    @State private var cellSize: CGFloat = 0
    @State private var showGameOverAlert = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()   // 1. Белый фон

            VStack(spacing: 40) {
                // Заголовок и жизни
                VStack {
                    Text("Уровень \(puzzleManager.currentSubLevel + 1)")
                        .font(.largeTitle).bold()
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: "heart.fill")
                                .font(.title)
                                .foregroundColor(i < puzzleManager.lives ? .red : .gray.opacity(0.5))
                        }
                    }
                }

                // 2. Доска, центрированная по горизонтали
                HStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)

                        // Сразу считаем размер клетки
                        GeometryReader { geo in
                            Color.clear.onAppear {
                                cellSize = geo.size.width / CGFloat(puzzleManager.boardSize.width)
                            }
                        }

                        // Блоки со стрелками
                        ForEach(puzzleManager.blocks) { block in
                            Button {
                                moveBlock(block)
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(block.color)
                                        .shadow(radius: 2)
                                    Image(systemName: getIconName(for: block.direction))
                                        .font(.system(size: cellSize * 0.4, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(width: cellSize * 0.9, height: cellSize * 0.9)
                            .position(
                                x: cellSize * CGFloat(block.position.col) + cellSize/2,
                                y: cellSize * CGFloat(block.position.row) + cellSize/2
                            )
                        }
                    }
                    .frame(width: 320, height: 320)
                    Spacer()
                }
            }
        }
        .id(puzzleManager.currentSubLevel)
        .sheet(isPresented: $showGameOverAlert) {
            GameOverPopup(isPresented: $showGameOverAlert)
        }
    }

    // MARK: – Логика игры

    private func moveBlock(_ block: ArrowBlock) {
        if isPathClear(for: block) {
            guard let idx = puzzleManager.blocks.firstIndex(where: { $0.id == block.id }) else { return }
            var finalPos = block.position
            switch block.direction {
            case .up:    finalPos.row = -1
            case .down:  finalPos.row = puzzleManager.boardSize.height
            case .left:  finalPos.col = -1
            case .right: finalPos.col = puzzleManager.boardSize.width
            }
            withAnimation(.easeOut(duration: 0.4)) {
                puzzleManager.blocks[idx].position = finalPos
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                puzzleManager.blocks.removeAll { $0.id == block.id }
                if currentSubLevelIsComplete() {
                    if puzzleManager.currentSubLevel == puzzleManager.allSubLevels.count - 1 {
                        winLevel()
                    } else {
                        puzzleManager.advanceToNextSubLevel()
                    }
                }
            }
        } else {
            puzzleManager.loseLife()
            if puzzleManager.lives == 0 {
                showGameOverAlert = true
            }
        }
    }

    private func currentSubLevelIsComplete() -> Bool {
        let setup = puzzleManager.allSubLevels[puzzleManager.currentSubLevel]
        return !puzzleManager.blocks.contains { setup.contains($0) }
    }

    private func isPathClear(for block: ArrowBlock) -> Bool {
        for other in puzzleManager.blocks where other.id != block.id {
            switch block.direction {
            case .up:
                if other.position.col == block.position.col && other.position.row < block.position.row { return false }
            case .down:
                if other.position.col == block.position.col && other.position.row > block.position.row { return false }
            case .left:
                if other.position.row == block.position.row && other.position.col < block.position.col { return false }
            case .right:
                if other.position.row == block.position.row && other.position.col > block.position.col { return false }
            }
        }
        return true
    }

    private func getIconName(for direction: ArrowDirection) -> String {
        switch direction {
        case .up:    return "arrow.up"
        case .down:  return "arrow.down"
        case .left:  return "arrow.left"
        case .right: return "arrow.right"
        }
    }

    private func winLevel() {
        gameManager.complete(level: 2)
        dismiss()
    }
}

// MARK: – Попап Game Over

struct GameOverPopup: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("💔").font(.system(size: 80))
                Text("Жизни кончились!").font(.title).bold().foregroundColor(.white)
                Button("Понял") {
                    isPresented = false
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(15)
            }
            .padding()
        }
    }
}

