//
//  GameScene.swift
//  TimberJim
//
//  Created by Jeremy Novak on 3/4/16.
//  Copyright (c) 2016 Jeremy Novak. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private enum GameState {
        case Waiting, Running, Paused, GameOver
    }
    
    // MARK: - Private class constants
    private let clouds = Clouds()
    private let birds = Birds()
    private let stackController = StackController()
    private let player = Player()
    private let tutorialButton = TutorialButton()
    private let playButton = PlayButton()
    
    // MARK: - Private class variables
    private var lastUpdateTime:NSTimeInterval = 0.0
    private var state = GameState.Waiting
    private var previousState = GameState.Waiting
    
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
        
        self.switchToWaiting()
    }
    

    // MARK: - Touch Events
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch:UITouch = touches.first! as UITouch
        let touchLocation = touch.locationInNode(self)
        
        switch self.state {
        case GameState.Waiting:
            self.switchToRunning()
            
            
        case GameState.Running:
            if touchLocation.x < kViewSize.width * 0.45 {
                
                self.player.chopLeft()
                
                self.stackController.moveStack()
                
            } else if touchLocation.x > kViewSize.width * 0.5 {
                
                self.player.chopRight()
                
                self.stackController.moveStack()
                
            }
            
            
        case GameState.Paused:
            return
            
        case GameState.GameOver:
            if self.playButton.containsPoint(touchLocation) {
                self.resetGame()
            }
        }
    }
    
    
    // MARK: - Update
    override func update(currentTime: NSTimeInterval) {
        
        switch self.state {
            
        case GameState.Waiting:
            let delta = currentTime - self.lastUpdateTime
            self.lastUpdateTime = currentTime
            
            self.clouds.update(delta: delta)
            self.birds.update(delta: delta)
            
        case GameState.Running:
            let delta = currentTime - self.lastUpdateTime
            self.lastUpdateTime = currentTime
            
            
            self.clouds.update(delta: delta)
            self.birds.update(delta: delta)
            
        case GameState.Paused:
            return
            
        case GameState.GameOver:
            let delta = currentTime - self.lastUpdateTime
            self.lastUpdateTime = currentTime
            
            self.clouds.update(delta: delta)
            self.birds.update(delta: delta)
        }
    }
    
    // MARK: - Contact
    func didBeginContact(contact: SKPhysicsContact) {
        if self.state != GameState.Running {
            return
        } else {
            let other = contact.bodyA.categoryBitMask == Contact.Player ? contact.bodyB : contact.bodyA
            
            if other.categoryBitMask == Contact.Branch {
                self.switchToGameOver()
            }
        }
    }
    
    // MARK: - State Functions
    private func switchToWaiting() {
        self.addChild(self.tutorialButton)
        
        self.tutorialButton.animateIn()
    }
    
    private func switchToRunning() {
        self.tutorialButton.animateOut()
        
        self.state = GameState.Running
    }
    
    private func switchToPaused() {
        self.previousState = self.state
        
        self.state = GameState.Paused
    }
    
    private func switchToResume() {
        self.state = self.previousState
    }
    
    private func switchToGameOver() {
        self.state = GameState.GameOver
        
        self.player.gameOver()
        
        self.displayGameOver()
    }
    
    private func displayGameOver() {
        self.runAction(SKAction.waitForDuration(0.5), completion: {
            self.addChild(self.playButton)
            self.playButton.animateIn()
        })
    }
    
    private func resetGame() {
        self.removeAllChildren()
        
        let scene = GameScene(size: kViewSize)
        let transition = SKTransition.fadeWithColor(SKColor.blackColor(), duration: 1.0)
        
        self.view?.presentScene(scene, transition: transition)
    }
    
    // MARK: - De-Init
    deinit {
        if kDebug {
            print("Destroying GameScene")
        }
    }
}
