import SpriteKit

class ChickenGameScene: SKScene {
    // Свойства
    var chicken: SKSpriteNode!
    let audioManager = AudioManager()
    private var isGameRunning = false
    private var background: SKSpriteNode?
    
    var completionHandler: ((_ didWin: Bool) -> Void)?
    
    var lastTileX: CGFloat = 0
    var worldNode = SKNode()
    var hasReachedCenter = false
    var stepCount = 0
    var targetSteps = 100
    var scoreLabel: SKLabelNode!
    var totalGapsGenerated = 5

    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        addChild(worldNode)

        setupBackground()
        setupChicken(isDynamic: false)
        setupScoreLabel()
        spawnInitialBridge()
    }
    
    func startGame() {
        guard !isGameRunning else { return }
        isGameRunning = true
        chicken.physicsBody?.isDynamic = true
        
        audioManager.onLoudSound = { [weak self] db in
            self?.handleSound(db: db)
        }
        audioManager.startMonitoring()
        
        // Небольшой стартовый импульс
        handleSound(db: -15)
    }
    
    // MARK: - Анимация
    func startRunningAnimationWithTimer() {
        guard chicken.action(forKey: "runningAnimation") == nil else { return }
        
        let runTextures = [
            SKTexture(imageNamed: "chicken_1"),
            SKTexture(imageNamed: "chicken_2")
        ]
        let runAnimation = SKAction.animate(with: runTextures, timePerFrame: 0.15)
        chicken.run(SKAction.repeatForever(runAnimation), withKey: "runningAnimation")
    }
    
    func stopRunningAnimation() {
        chicken.removeAction(forKey: "runningAnimation")
        chicken.removeAction(forKey: "stopAnimationTimer")
        chicken.texture = SKTexture(imageNamed: "chicken_1")
    }

    // MARK: - Основная логика
    func handleSound(db: Float) {
        guard isGameRunning else { return }
        
        let stepDistance: CGFloat = 20
        let jumpPower: CGFloat
        
        if db > -10 {
            jumpPower = 300
        } else if db > -20 {
            jumpPower = 200
        } else if db > -40 {
            jumpPower = 100
        } else {
            return
        }
        
        startRunningAnimationWithTimer()
        
        let stopAction = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [weak self] in
                self?.stopRunningAnimation()
            }
        ])
        chicken.run(stopAction, withKey: "stopAnimationTimer")

        chickenJump(power: jumpPower)
        moveForward(by: stepDistance)
        
        stepCount += 1
        scoreLabel.text = "Шагов: \(stepCount) / \(targetSteps)"
        
        if stepCount >= targetSteps {
            triggerVictory()
        }
        
        if !hasReachedCenter && chicken.position.x >= frame.midX {
            hasReachedCenter = true
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameRunning else { return }
        if hasReachedCenter {
            chicken.position.x = frame.midX // На всякий случай фиксируем
        }
        if chicken.position.y < frame.minY - 100 {
            triggerGameOver()
        }
        let referenceX = hasReachedCenter ? frame.midX - worldNode.position.x : chicken.position.x
        while lastTileX < referenceX + frame.width {
            spawnBridgeTile(at: lastTileX)
            lastTileX += 60
        }
    }
    
    func triggerGameOver() {
        guard isGameRunning else { return }
        isGameRunning = false
        audioManager.stop()
        stopRunningAnimation()
        completionHandler?(false)
    }
    
    func triggerVictory() {
        guard isGameRunning else { return }
        isGameRunning = false
        audioManager.stop()
        stopRunningAnimation()
        completionHandler?(true)
    }
    
    // MARK: - Setup методы
    func setupBackground() {
        if background == nil {
            background = SKSpriteNode(imageNamed: "bg_hills_sky")
            background!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            background!.zPosition = -1
            addChild(background!)
        }
        background!.position = CGPoint(x: frame.midX, y: frame.midY)
        background!.size = self.size
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        setupBackground()
    }
    
    func setupChicken(isDynamic: Bool) {
        chicken = SKSpriteNode(imageNamed: "chicken_1")
        chicken.position = CGPoint(x: frame.midX - 150, y: frame.midY - 80)
        chicken.zPosition = 1
        chicken.setScale(0.08)
        
        chicken.physicsBody = SKPhysicsBody(rectangleOf: chicken.size)
        chicken.physicsBody?.isDynamic = isDynamic
        chicken.physicsBody?.allowsRotation = false
        chicken.physicsBody?.affectedByGravity = true
        chicken.physicsBody?.categoryBitMask = 1
        chicken.physicsBody?.contactTestBitMask = 2
        chicken.physicsBody?.collisionBitMask = 1 << 1
        
        addChild(chicken)
        lastTileX = chicken.position.x - 60
    }
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        scoreLabel.fontSize = 32
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 80)
        scoreLabel.zPosition = 10
        scoreLabel.text = "Шагов: 0 / \(targetSteps)"
        addChild(scoreLabel)
    }
    
    func spawnInitialBridge() {
        // Place tiles starting from slightly behind the chicken to
        // ensure there is ground immediately under and in front of it
        let initialTiles = 10
        for i in -1..<(initialTiles - 1) {
            let x = chicken.position.x + CGFloat(i * 60)
            spawnBridgeTile(at: x, force: true)
        }
        lastTileX = chicken.position.x + CGFloat((initialTiles - 1) * 60)
    }
    
    func moveForward(by distance: CGFloat) {
        if !hasReachedCenter {
            chicken.position.x += distance
            if chicken.position.x >= frame.midX {
                hasReachedCenter = true
                chicken.position.x = frame.midX // Фиксируем курицу в центре
            }
        } else {
            worldNode.position.x -= distance
            chicken.position.x = frame.midX // Держим курицу в центре всегда
        }
    }
    
    func chickenJump(power: CGFloat) {
        chicken.physicsBody?.velocity.dy = 0
        chicken.physicsBody?.applyImpulse(CGVector(dx: 0, dy: power))
    }
    
    func spawnBridgeTile(at x: CGFloat, force: Bool = false) {
        let tileWidth: CGFloat = 60
        let tileHeight: CGFloat = 20
        let chickenWidth = chicken.size.width
        let isBigGap = totalGapsGenerated % 30 == 0
        let shouldSpawn = force || Bool.random(probability: 0.8)
        
        if shouldSpawn {
            let tile = SKSpriteNode(color: .brown, size: CGSize(width: tileWidth, height: tileHeight))
            tile.position = CGPoint(x: x, y: frame.midY - 100)
            tile.physicsBody = SKPhysicsBody(rectangleOf: tile.size)
            tile.physicsBody?.isDynamic = false
            tile.physicsBody?.categoryBitMask = 2
            tile.zPosition = 1
            worldNode.addChild(tile)
        } else {
            let gapSize = isBigGap ? chickenWidth * 3 : chickenWidth + 60
            lastTileX += gapSize
            totalGapsGenerated += 1
        }
    }
}

extension ChickenGameScene: SKPhysicsContactDelegate {}

extension Bool {
    static func random(probability: Double) -> Bool {
        return Double.random(in: 0...1) < probability
    }
}
