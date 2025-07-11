import SpriteKit

struct PhysicsCategory {
    static let bug: UInt32 = 0x1 << 0
    static let heart: UInt32 = 0x1 << 1
    static let enemy: UInt32 = 0x1 << 2
}

class BugGameScene: SKScene, SKPhysicsContactDelegate {
    private var bug: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var livesLabel: SKLabelNode!
    private var isTouchingBug = false

    private var score = 0
    private var lives = 3
    /// Number of hearts required to win. Should match the UI instructions.
    private let targetScore = 100

    private var hasStarted = false
    var onGameOver: ((Bool) -> Void)?

    override func didMove(to view: SKView) {
        removeAllChildren()
        removeAllActions()
        hasStarted = false
        score = 0
        lives = 3

        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

        setupBackground()
        setupBug()
        setupLabels()
    }

    func startGame() {
        guard !hasStarted else { return }
        hasStarted = true
        startSpawning()
    }

    func setupBackground() {
        // Светло-зеленый фон
        backgroundColor = SKColor(red: 0.7, green: 0.9, blue: 0.7, alpha: 1.0)
        
        // Добавляем траву внизу
        let grass = SKSpriteNode(color: SKColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1.0),
                                 size: CGSize(width: size.width, height: 150))
        grass.position = CGPoint(x: size.width / 2, y: 75)
        grass.zPosition = -10
        addChild(grass)
        
        // Добавляем облака
        for _ in 0..<3 {  // Используем _ если не нужна переменная i
            let cloud = SKShapeNode(ellipseOf: CGSize(width: 100, height: 50))
            cloud.fillColor = .white
            cloud.strokeColor = .clear
            cloud.alpha = 0.8
            cloud.position = CGPoint(
                x: CGFloat.random(in: 50...(size.width-50)),
                y: CGFloat.random(in: size.height * 0.6...size.height * 0.8)
            )
            cloud.zPosition = -5
            addChild(cloud)
        }
    }



    func setupBug() {
        bug = SKSpriteNode(imageNamed: "bug")
        bug.size = CGSize(width: 100, height: 100) // Фиксированный размер
        bug.position = CGPoint(x: size.width / 2, y: 100) // Внизу по центру
        bug.zPosition = 10
        bug.name = "bug"
        
        // Физическое тело жука
        bug.physicsBody = SKPhysicsBody(circleOfRadius: 40)
        bug.physicsBody?.isDynamic = false
        bug.physicsBody?.categoryBitMask = PhysicsCategory.bug
        bug.physicsBody?.contactTestBitMask = PhysicsCategory.heart | PhysicsCategory.enemy
        bug.physicsBody?.collisionBitMask = 0
        addChild(bug)
    }

    func setupLabels() {
        // Счет слева вверху с фоном
        let scoreBg = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 150, height: 40), cornerRadius: 20)
        scoreBg.fillColor = UIColor.black.withAlphaComponent(0.7)
        scoreBg.strokeColor = .clear
        scoreBg.position = CGPoint(x: 20, y: size.height - 60)
        scoreBg.zPosition = 99
        addChild(scoreBg)
        
        scoreLabel = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        scoreLabel.fontSize = 26
        scoreLabel.fontColor = .white
        scoreLabel.text = "❤️ 0/\(targetScore)"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: 30, y: size.height - 40)
        scoreLabel.zPosition = 100
        addChild(scoreLabel)

        // Жизни справа вверху с фоном
        let livesBg = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 100, height: 40), cornerRadius: 20)
        livesBg.fillColor = UIColor.black.withAlphaComponent(0.7)
        livesBg.strokeColor = .clear
        livesBg.position = CGPoint(x: size.width - 120, y: size.height - 60)
        livesBg.zPosition = 99
        addChild(livesBg)
        
        livesLabel = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        livesLabel.fontSize = 26
        livesLabel.fontColor = .white
        livesLabel.text = "💔 3"
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.verticalAlignmentMode = .center
        livesLabel.position = CGPoint(x: size.width - 110, y: size.height - 40)
        livesLabel.zPosition = 100
        addChild(livesLabel)

        updateLabels()
    }

    func updateLabels() {
        scoreLabel.text = "❤️ \(score)/\(targetScore)"
        livesLabel.text = "💔 \(lives)"
    }

    func startSpawning() {
        let spawn = SKAction.run { [weak self] in
            self?.spawnRandomFallingThing()
        }
        let delay = SKAction.wait(forDuration: 1.2)
        run(SKAction.repeatForever(SKAction.sequence([spawn, delay])), withKey: "spawning")
    }

    func spawnRandomFallingThing() {
        let isHeart = Bool.random()
        // Use only existing heart asset to avoid missing texture crash
        let textureName = isHeart ? "heart_1" : "enemy"
        let node = SKSpriteNode(imageNamed: textureName)
        
        // Одинаковый размер для всех падающих объектов
        node.size = CGSize(width: 50, height: 50)
        
        node.position = CGPoint(x: CGFloat.random(in: 50...(size.width - 50)), y: size.height + 50)
        node.zPosition = 5
        node.name = isHeart ? "heart" : "enemy"

        // Физическое тело
        node.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.velocity = CGVector(dx: 0, dy: -200)
        node.physicsBody?.linearDamping = 0
        node.physicsBody?.categoryBitMask = isHeart ? PhysicsCategory.heart : PhysicsCategory.enemy
        node.physicsBody?.contactTestBitMask = PhysicsCategory.bug
        node.physicsBody?.collisionBitMask = 0

        addChild(node)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Проверяем касание жука
        let distance = hypot(location.x - bug.position.x, location.y - bug.position.y)
        if distance < 80 {
            isTouchingBug = true
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isTouchingBug, let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Ограничиваем движение жука
        let margin: CGFloat = 50
        let clampedX = min(max(location.x, margin), size.width - margin)
        let clampedY = min(max(location.y, 80), size.height - 100)

        bug.position = CGPoint(x: clampedX, y: clampedY)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouchingBug = false
    }

    override func update(_ currentTime: TimeInterval) {
        guard hasStarted else { return }

        // Удаляем объекты, упавшие ниже экрана
        for node in children {
            if (node.name == "enemy" || node.name == "heart") && node.position.y < -50 {
                node.removeFromParent()
            }
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // Определяем что с чем столкнулось
        var bugBody: SKPhysicsBody?
        var otherBody: SKPhysicsBody?
        
        if bodyA.categoryBitMask == PhysicsCategory.bug {
            bugBody = bodyA
            otherBody = bodyB
        } else if bodyB.categoryBitMask == PhysicsCategory.bug {
            bugBody = bodyB
            otherBody = bodyA
        }
        
        guard let other = otherBody else { return }
        
        // Обрабатываем столкновение с сердечком
        if other.categoryBitMask == PhysicsCategory.heart {
            other.node?.removeFromParent()
            score += 1
            updateLabels()
            if score >= targetScore {
                endGame(won: true)
            }
        }
        
        // Обрабатываем столкновение с врагом
        if other.categoryBitMask == PhysicsCategory.enemy {
            other.node?.removeFromParent()
            lives -= 1
            updateLabels()
            if lives <= 0 {
                endGame(won: false)
            }
        }
    }

    func endGame(won: Bool) {
        removeAllActions()
        onGameOver?(won)
    }
}

