//
//  GameScene.swift
//  RacingSISeI
//
//  Created by Daniel Tejeda on 23/10/17.
//  Copyright © 2017 Daniel Tejeda. All rights reserved.
//

//https://github.com/danieltejeda1101/tallersisei


/*Bitwise operations
 
 
 let someBits: UInt8 = 0b10110010
 let moreBits: UInt8 = 0b01011110
 let combinedbits = someBits | moreBits  // equals 11111110
 
 
 */



import SpriteKit
import GameplayKit

struct PhysicsCategory{
    static let None:UInt32 = 0
    static let Car:UInt32 = 0b1
    static let CheckPoint: UInt32 = 0b10
    static let Bounds:UInt32 = 0b100
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    //MARK: - Properties
    let car = SKSpriteNode(imageNamed: "carro") //Crear el nodo del carro
    var lastUpdateInterval:TimeInterval = 0 //Auxiliar para nuestro timer
    var deltaTime:TimeInterval = 0 //Diferencia de tiempos
    var carVelocity = CGPoint(x: -1, y: 0) //Velocidad del carro
    var carMovePerSec:CGFloat = 400 //Movimiento de carro cada segundo
    var check1 = false, check2 = false, check3 = false //Checkpoints
    var firstTime = true //Primera vuelta
    var laps = 0 //Vueltas
    var crashes = 0 //Choques
    var hearts = 1 //Corazones
    let lapsLabel = SKLabelNode(fontNamed: "Avenir-Heavy") //Número de vueltas
    let crashedLabel = SKLabelNode(fontNamed: "Avenir-Heavy")//Número de choques
    let heartLabel = SKLabelNode(fontNamed: "Avenir-Heavy")//Número de vidas
    var heart = SKSpriteNode(imageNamed: "corazon_nextu")//Crear nodo de corazón
    var gameIsOver = false//Checar si el juego ha terminado
  
    
    //MARK: - Init. Crear el contenido de la view, se ejecuta antes de presentar la view.
    override func didMove(to view: SKView) {
        setBackground()//Establecer el background
        setCar()//Colocar nuestro carro
        setUpPhysicsBodies()//Colocar las paredes invisibles
        setCheckpoints()//Colocar los checkpoints
        setLabels()//Colocar las etiquetas necesarias
        setHeart()//Colocar los corazones
        physicsWorld.contactDelegate = self//Habilitar la física del juego
        
        
    
    }
    
    
    //MARK: - Touch events (Touch único)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        if gameIsOver{
            return
        }
        
        guard let touch = touches.first else{
            return
        }
        let touchLocation = touch.location(in: self)
        moveCar(touchLocation)
    }
    
    //(Mover el dedo)
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        if gameIsOver{
            return
        }
        
        guard let touch = touches.first else{
            return
        }
        carMovePerSec = 400
        let touchLocation = touch.location(in: self)
        moveCar(touchLocation)
        
    }
    
    //MARK: - Game loop (Se ejecuta cada frame) - Pero no sabemos cuantos segundos hay en cada frame.
    override func update(_ currentTime: TimeInterval) {
        //Si ya perdimos, entonces detenemos el juego.
        if gameIsOver{
            return
        }
        
        /* Called before each frame is rendered */
        if lastUpdateInterval > 0 {
            deltaTime = currentTime - lastUpdateInterval
        }
        else{
            deltaTime = 0
        }
        
        lastUpdateInterval = currentTime
        
        moveSprite(car, velocity: carVelocity)
        rotateSprite(car, direction: carVelocity)
    }
    
    //MARK: - Set Sprites
    func setBackground(){
        backgroundColor = SKColor.black
        let background = SKSpriteNode(imageNamed: "pista")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
    }
    
    //Posicionar el auto
    func setCar(){
        car.position = CGPoint(x: 900, y: 800)
        car.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        car.physicsBody = SKPhysicsBody(rectangleOf: car.frame.size)
        car.physicsBody!.isDynamic = true
        car.physicsBody!.affectedByGravity = false //No gravedad
        car.physicsBody!.categoryBitMask = PhysicsCategory.Car //001
        car.physicsBody!.collisionBitMask = PhysicsCategory.Bounds //100
        car.physicsBody!.contactTestBitMask = PhysicsCategory.CheckPoint | PhysicsCategory.Bounds //110
        carVelocity = CGPoint(x: -1, y: 0)
        addChild(car)
        
    }
    
    func setLabels(){
        lapsLabel.text = "Vueltas: 0"
        lapsLabel.fontColor = SKColor.black
        lapsLabel.fontSize = 50
        lapsLabel.zPosition = 100 /*Higher values place this layer visually closer to the viewer than layers with lower values */
        lapsLabel.horizontalAlignmentMode = .left
        lapsLabel.verticalAlignmentMode = .top
        lapsLabel.position = CGPoint(x: 300, y: 1310)
        addChild(lapsLabel)
        
        crashedLabel.text = "Golpes: 0"
        crashedLabel.fontColor = SKColor.black
        crashedLabel.fontSize = 50
        crashedLabel.zPosition = 100
        crashedLabel.horizontalAlignmentMode = .left
        crashedLabel.verticalAlignmentMode = .top
        crashedLabel.position = CGPoint(x: 300, y: 1240)
        addChild(crashedLabel)
        
        heartLabel.text = "1"
        heartLabel.fontColor = SKColor.black
        heartLabel.fontSize = 50
        heartLabel.zPosition = 100
        heartLabel.horizontalAlignmentMode = .left
        heartLabel.verticalAlignmentMode = .top
        heartLabel.position = CGPoint(x: 360, y: 1020)
        addChild(heartLabel)
        
    }
    
    func setHeart(){
        heart.position = CGPoint(x: 330, y: 1000)
        heart.size = CGSize(width: 50, height: 50)
        addChild(heart)
    }
    
    
    func setUpPhysicsBodies(){
        
        //Score display
        let scoreBoundary = SKNode()
        scoreBoundary.position = CGPoint(x: 550, y: 1100)
        addChild(scoreBoundary)
        scoreBoundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 600, height: 490))
        scoreBoundary.physicsBody?.isDynamic = false /*ignores all forces and */
        scoreBoundary.physicsBody?.categoryBitMask = PhysicsCategory.Bounds /*which is a mask that defines which categories a physics body belongs to:*/
        
        //Lake 1
        let innerBoundary1 = SKNode()
        innerBoundary1.position = CGPoint(x: 880, y: 535)
        addChild(innerBoundary1)
        innerBoundary1.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 700, height: 360))
        innerBoundary1.physicsBody?.isDynamic = false
        innerBoundary1.physicsBody?.categoryBitMask = PhysicsCategory.Bounds
        
        //Lake 2
        let innerBoundary2 = SKNode()
        innerBoundary2.position = CGPoint(x: 1280, y: 765)
        addChild(innerBoundary2)
        innerBoundary2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 620, height: 795))
        innerBoundary2.physicsBody?.isDynamic = false
        innerBoundary2.physicsBody?.categoryBitMask = PhysicsCategory.Bounds
        
        //Left
        let leftBoundary = SKNode()
        leftBoundary.position = CGPoint(x: 300, y: 500)
        addChild(leftBoundary)
        leftBoundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 700))
        leftBoundary.physicsBody?.isDynamic = false
        leftBoundary.physicsBody?.categoryBitMask = PhysicsCategory.Bounds
        
        //Bottom
        let bottomBoundary = SKNode()
        bottomBoundary.position = CGPoint(x: 1050, y: 180)
        addChild(bottomBoundary)
        bottomBoundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1400, height: 100))
        bottomBoundary.physicsBody?.isDynamic = false
        bottomBoundary.physicsBody?.categoryBitMask = PhysicsCategory.Bounds
        
        //Right
        let rightBoundary = SKNode()
        rightBoundary.position = CGPoint(x: 1820, y: 800)
        addChild(rightBoundary)
        rightBoundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 1200))
        rightBoundary.physicsBody?.isDynamic = false
        rightBoundary.physicsBody?.categoryBitMask = PhysicsCategory.Bounds
        
        //Top
        let topBoundary = SKNode()
        topBoundary.position = CGPoint(x: 1050, y: 1320)
        addChild(topBoundary)
        topBoundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1400, height: 50))
        topBoundary.physicsBody?.isDynamic = false
        topBoundary.physicsBody?.categoryBitMask = PhysicsCategory.Bounds
        
        
    }
    
    func setCheckpoints(){
        let checkPoint = SKNode()
        checkPoint.position = CGPoint(x: 610, y: 770)
        addChild(checkPoint)
        checkPoint.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 60, height: 200))
        checkPoint.physicsBody?.isDynamic = false
        checkPoint.physicsBody?.affectedByGravity = false
        checkPoint.physicsBody?.categoryBitMask = PhysicsCategory.CheckPoint
        checkPoint.name = "Checkpoint1"
        
        let checkPoint2 = SKNode()
        checkPoint2.position = CGPoint(x: 450, y: 530)
        addChild(checkPoint2)
        checkPoint2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 30))
        checkPoint2.physicsBody?.isDynamic = false
        checkPoint2.physicsBody?.affectedByGravity = false
        checkPoint2.physicsBody?.categoryBitMask = PhysicsCategory.CheckPoint
        checkPoint2.name = "Checkpoint2"
        
        let checkPoint3 = SKNode()
        checkPoint3.position = CGPoint(x: 1650, y: 890)
        addChild(checkPoint3)
        checkPoint3.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 30))
        checkPoint3.physicsBody?.isDynamic = false
        checkPoint3.physicsBody?.affectedByGravity = false
        checkPoint3.physicsBody?.categoryBitMask = PhysicsCategory.CheckPoint
        checkPoint3.name = "Checkpoint3"
        
    }
    
    //MARK: - Movement
    func moveSprite(_ sprite: SKSpriteNode, velocity:CGPoint){
        let amountToMove = CGPoint(x: velocity.x * CGFloat(deltaTime), y: velocity.y * CGFloat(deltaTime))
        sprite.position = CGPoint(x: sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
        
    }
    
    func moveCar(_ location:CGPoint){
        let offset = CGPoint(x: location.x - car.position.x, y: location.y - car.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        carVelocity = CGPoint(x: direction.x * carMovePerSec, y: direction.y * carMovePerSec)
    }
    
    func rotateSprite(_ sprite:SKSpriteNode, direction:CGPoint){
        sprite.zRotation = CGFloat(atan2(Double(direction.y), Double(direction.x)))
    }
    
    //MARK: - SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == PhysicsCategory.Car | PhysicsCategory.CheckPoint{
            let other = contact.bodyA.categoryBitMask == PhysicsCategory.Car ? contact.bodyB.node : contact.bodyA.node
            
            if other!.name == "Checkpoint1"{
                if firstTime{
                    firstTime = false
                }else{
                    check1 = true
                }
            }else if other!.name == "Checkpoint2"{
                check2 = true
                
            }else if other!.name == "Checkpoint3"{
                check3 = true
            }
            
            if check1 && check2 && check3 {
                laps += 1
                lapsLabel.text = "Vueltas: \(laps)"
                check1 = false
                check2 = false
                check3 = false
                hearts += 1
                heartLabel.text = "\(hearts)"
            }
            
        }
        else if collision == PhysicsCategory.Car | PhysicsCategory.Bounds{
            crashes += 1
            crashedLabel.text = "Golpes: \(crashes)"
            if crashes >= 6{
                checkGameOver()
            }
            
            
        }
    }
    
    
    func checkGameOver(){
        //Reset everything
        car.removeFromParent()
        setCar()
        hearts -= 1
        crashes = 0
        crashedLabel.text = "Golpes: \(crashes)"
        check1 = false
        check2 = false
        check3 = false
        heartLabel.text = "\(hearts)"
        
        //GameOver
        if hearts <= 0{
            heartLabel.text = "0"
            gameIsOver = true
            
            return
        }
        
        heartLabel.text = "\(hearts)"
        
    }
  
    
    
   
}
