// Файл: ArrowPuzzleModels.swift
import Foundation
import SwiftUI

enum ArrowDirection { case up, down, left, right }

struct ArrowBlock: Identifiable, Equatable {
    let id = UUID()
    var position: (row: Int, col: Int)
    let direction: ArrowDirection
    let color: Color
    
    static func == (lhs: ArrowBlock, rhs: ArrowBlock) -> Bool { lhs.id == rhs.id }
}

class ArrowPuzzleManager: ObservableObject {
    @Published var blocks: [ArrowBlock]
    @Published var lives: Int = 3
    @Published var currentSubLevel: Int = 0
    
    let boardSize = (width: 8, height: 8)
    
    let allSubLevels: [[ArrowBlock]]
    
    init() {
        // --- УРОВЕНЬ 1 (ТВОЯ ВЕРСИЯ, ПРОВЕРЕНА) ---
        let level1 = [
            ArrowBlock(position: (row: 2, col: 2), direction: .up, color: .purple), ArrowBlock(position: (row: 2, col: 3), direction: .up, color: .purple),
            ArrowBlock(position: (row: 5, col: 4), direction: .down, color: .purple), ArrowBlock(position: (row: 5, col: 5), direction: .down, color: .purple),
            ArrowBlock(position: (row: 2, col: 4), direction: .down, color: .pink), ArrowBlock(position: (row: 2, col: 5), direction: .down, color: .pink),
            ArrowBlock(position: (row: 5, col: 2), direction: .up, color: .pink), ArrowBlock(position: (row: 5, col: 3), direction: .up, color: .pink),
            ArrowBlock(position: (row: 3, col: 2), direction: .left, color: .yellow), ArrowBlock(position: (row: 4, col: 2), direction: .left, color: .yellow),
            ArrowBlock(position: (row: 3, col: 5), direction: .right, color: .orange), ArrowBlock(position: (row: 4, col: 5), direction: .right, color: .orange),
        ]
        
        // --- УРОВЕНЬ 2 (ИСПРАВЛЕННАЯ ВЕРСИЯ) ---
        let level2 = [
            ArrowBlock(position: (row: 0, col: 1), direction: .up, color: .pink), ArrowBlock(position: (row: 0, col: 2), direction: .up, color: .pink),
            ArrowBlock(position: (row: 0, col: 3), direction: .up, color: .pink), ArrowBlock(position: (row: 1, col: 0), direction: .left, color: .yellow),
            ArrowBlock(position: (row: 1, col: 2), direction: .down, color: .purple), ArrowBlock(position: (row: 1, col: 4), direction: .left, color: .yellow),
            ArrowBlock(position: (row: 2, col: 0), direction: .right, color: .orange), ArrowBlock(position: (row: 2, col: 1), direction: .right, color: .orange),
            ArrowBlock(position: (row: 2, col: 2), direction: .right, color: .orange), ArrowBlock(position: (row: 2, col: 3), direction: .right, color: .orange),
            ArrowBlock(position: (row: 3, col: 1), direction: .up, color: .pink), ArrowBlock(position: (row: 3, col: 2), direction: .left, color: .yellow),
            ArrowBlock(position: (row: 3, col: 3), direction: .left, color: .yellow), ArrowBlock(position: (row: 3, col: 4), direction: .left, color: .yellow),
            ArrowBlock(position: (row: 4, col: 1), direction: .left, color: .yellow), ArrowBlock(position: (row: 4, col: 2), direction: .right, color: .orange),
            ArrowBlock(position: (row: 4, col: 3), direction: .right, color: .orange), ArrowBlock(position: (row: 4, col: 4), direction: .right, color: .orange),
            ArrowBlock(position: (row: 5, col: 1), direction: .down, color: .purple), ArrowBlock(position: (row: 5, col: 2), direction: .left, color: .yellow),
            ArrowBlock(position: (row: 5, col: 3), direction: .right, color: .orange), ArrowBlock(position: (row: 6, col: 2), direction: .down, color: .purple),
            ArrowBlock(position: (row: 6, col: 3), direction: .down, color: .purple), ArrowBlock(position: (row: 6, col: 4), direction: .down, color: .purple),
            ArrowBlock(position: (row: 2, col: 5), direction: .up, color: .pink), ArrowBlock(position: (row: 3, col: 5), direction: .up, color: .pink),
            ArrowBlock(position: (row: 4, col: 5), direction: .up, color: .pink),
        ]
        
        // --- УРОВЕНЬ 3 (ИСПРАВЛЕННАЯ ВЕРСИЯ) ---
        let level3 = [
            ArrowBlock(position: (row: 0, col: 1), direction: .right, color: .orange), ArrowBlock(position: (row: 0, col: 2), direction: .up, color: .pink),
            ArrowBlock(position: (row: 1, col: 0), direction: .up, color: .pink), ArrowBlock(position: (row: 1, col: 2), direction: .up, color: .pink),
            ArrowBlock(position: (row: 1, col: 3), direction: .left, color: .yellow), ArrowBlock(position: (row: 2, col: 1), direction: .left, color: .yellow),
            ArrowBlock(position: (row: 2, col: 2), direction: .up, color: .pink), ArrowBlock(position: (row: 3, col: 1), direction: .right, color: .orange),
            ArrowBlock(position: (row: 3, col: 2), direction: .up, color: .pink), ArrowBlock(position: (row: 4, col: 0), direction: .up, color: .pink),
            ArrowBlock(position: (row: 4, col: 2), direction: .left, color: .yellow), ArrowBlock(position: (row: 4, col: 3), direction: .up, color: .pink),
            ArrowBlock(position: (row: 5, col: 0), direction: .up, color: .pink),
            ArrowBlock(position: (row: 5, col: 2), direction: .left, color: .yellow), ArrowBlock(position: (row: 6, col: 2), direction: .down, color: .purple),
            ArrowBlock(position: (row: 6, col: 3), direction: .right, color: .orange), ArrowBlock(position: (row: 7, col: 0), direction: .right, color: .orange),
            ArrowBlock(position: (row: 7, col: 1), direction: .up, color: .pink), ArrowBlock(position: (row: 7, col: 2), direction: .down, color: .purple),
            ArrowBlock(position: (row: 7, col: 3), direction: .up, color: .pink),
        ]
        
        self.allSubLevels = [level1, level2, level3]
        self.blocks = allSubLevels[0]
    }
    
    func loseLife() {
        if lives > 0 { lives -= 1 }
    }
    
    func restartGame() {
        lives = 3
        currentSubLevel = 0
        blocks = allSubLevels[0]
    }
    
    func advanceToNextSubLevel() {
        if currentSubLevel < allSubLevels.count - 1 {
            currentSubLevel += 1
            blocks = allSubLevels[currentSubLevel]
        }
    }
}

