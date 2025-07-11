import SwiftUI
import SpriteKit

struct BugGameView: UIViewRepresentable {
    let size: CGSize
    @Binding var gameState: BugGameFlowState
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        let scene = BugGameScene(size: size)
        scene.scaleMode = .resizeFill
        
        // Связываем scene с нашим gameState
        scene.onGameOver = { didWin in
            gameState = .gameOver(didWin: didWin)
        }
        
        skView.presentScene(scene)
        
        // Запускаем игру когда состояние меняется на playing
        context.coordinator.scene = scene
        
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        if case .playing = gameState {
            context.coordinator.scene?.startGame()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var scene: BugGameScene?
    }
}
