import SwiftUI
import SpriteKit

struct ChickenGameView: UIViewRepresentable {
    let size: CGSize
    @Binding var gameState: ChickenGameFlowState
    @Binding var stepCount: Int
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        let scene = ChickenGameScene(size: size)
        scene.scaleMode = .resizeFill
        scene.stepUpdateHandler = { count in
            DispatchQueue.main.async {
                stepCount = count
            }
        }
        
        // Связываем scene с нашим gameState
        scene.completionHandler = { didWin in
            DispatchQueue.main.async {
                gameState = .gameOver(didWin: didWin)
            }
        }
        
        skView.presentScene(scene)
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
        var scene: ChickenGameScene?
    }
}
