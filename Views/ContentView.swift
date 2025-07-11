import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var gameManager: GameManager
    @State private var showIntro = true

    var body: some View {
        Group {
            // Если ещё не наступил день рождения
            if !gameManager.isHubUnlocked {
                LockedView()
            }
            // Иначе, если мы ещё не нажали «Начать»
            else if showIntro {
                IntroView(onStart: {
                    showIntro = false
                })
            }
            // Иначе — показываем хаб
            else {
                HubView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameManager())
}
