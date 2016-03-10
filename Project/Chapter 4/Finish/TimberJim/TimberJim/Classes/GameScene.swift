//
//  GameScene.swift
//  TimberJim
//
//  Created by Jeremy Novak on 3/4/16.
//  Copyright (c) 2016 Jeremy Novak. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Private class constants
    private let clouds = Clouds()
    private let birds = Birds()
    private let stackController = StackController()
    private let player = Player()
    
    // MARK: - Private class variables
    private var lastUpdateTime:NSTimeInterval = 0.0
    
    // MARK: - Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.setupScene()
    }
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
    }
    
    // MARK: - Setup
    private func setupScene() {
        self.addChild(self.clouds)
        
        self.addChild(self.birds)
        
        let forest = GameTextures.sharedInstance.spriteWithName(name: SpriteName.Forest)
        forest.anchorPoint = CGPointZero
        forest.position = CGPointZero
        self.addChild(forest)
        
        
        self.addChild(self.stackController)
        
        self.addChild(self.player)
    }
    
    // MARK: - Touch Events
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch:UITouch = touches.first! as UITouch
        let touchLocation = touch.locationInNode(self)
        
        
        if touchLocation.x < kViewSize.width * 0.5 {
            // Player tapped left side of the screen
            self.player.chopLeft()
            self.stackController.moveStack()
        } else if touchLocation.x > kViewSize.width * 0.5 {
            // Player tapped right side of the screen
            self.player.chopRight()
            self.stackController.moveStack()
        }
    }
    
    
    // MARK: - Update
    override func update(currentTime: NSTimeInterval) {
        let delta = currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        
        self.clouds.update(delta: delta)
        
        self.birds.update(delta: delta)
        
        //self.stackController.update(delta: delta)
    }
    
    // MARK: - Contact
    func didBeginContact(contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == Contact.Player ? contact.bodyB : contact.bodyA
        
        if other.categoryBitMask == Contact.Branch {
            self.player.gameOver()
        }
    }
    
    // MARK: - De-Init
    deinit {
        if kDebug {
            print("Destroying GameScene")
        }
    }
}
