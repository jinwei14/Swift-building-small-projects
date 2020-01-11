//
//  GameScene.swift
//  Snake
//
//  Created by Jinwei Zhang on 08/01/2020.
//  Copyright © 2020 Jinwei Zhang. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    //1
    //    We create variables for the logos/buttons. The “!” after the variable name means that we must initialize the variables, they cannot be empty or “nil”
    var gameLogo: SKLabelNode!
    var bestScore: SKLabelNode!
    var playButton: SKShapeNode!
    var game: GameManager!
    //New variables! We are creating a label to show the current score, an array of all the positions that the “snake” or player currently has, a background for our game view and an array to track the positions of each cell in the game view.
    var currentScore: SKLabelNode!
    var playerPositions: [(Int, Int)] = []
    var gameBG: SKShapeNode!
    var gameArray: [(node: SKShapeNode, x: Int, y: Int)] = []
    // Initialize a variable for the random score position. The “ ? “ indicates that this is nil (empty or not set yet) until we set the variable later.
    var scorePos: CGPoint?
    
    override func didMove(to view: SKView) {
        //2
        //        We call the “initializeMenu()” function once the game view is loaded. didMove(to: view: SKView) is the function that is called once our GameScene has loaded.
        initializeMenu()
        game = GameManager(scene: self)
        //Call the initializeGameView() function.
        initializeGameView()
        //Add swipe gestures to the didMove(to view: SKView) function.
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeR))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeL))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeU))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeD))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    //Create functions that are called when the user enters a swipe gesture. The “@objc” before the function creates an objective-c function, this is necessary in order to be called via the #selector in the original UISwipeGestureRecognizer.
    //Once a swipe gesture is detected the gameManager class is notified.
    @objc func swipeR() {
        game.swipe(ID: 3)
    }
    @objc func swipeL() {
        game.swipe(ID: 1)
    }
    @objc func swipeU() {
        game.swipe(ID: 2)
    }
    @objc func swipeD() {
        game.swipe(ID: 4)
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        game.update(time: currentTime)
    }
    
    
    //3
    private func initializeMenu() {
        //4 Create game title
        gameLogo = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        gameLogo.zPosition = 1
        gameLogo.position = CGPoint(x: 0, y: (frame.size.height / 2) - 200)
        gameLogo.fontSize = 60
        gameLogo.text = "SNAKE"
        gameLogo.fontColor = SKColor.red
        self.addChild(gameLogo)
        //5Create best score label
        bestScore = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        bestScore.zPosition = 1
        bestScore.position = CGPoint(x: 0, y: gameLogo.position.y - 50)
        bestScore.fontSize = 40
        bestScore.text = "Best Score: 0"
        bestScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
        bestScore.fontColor = SKColor.white
        self.addChild(bestScore)
        //6 Create play button
        playButton = SKShapeNode()
        playButton.name = "play_button"
        playButton.zPosition = 1
        playButton.position = CGPoint(x: 0, y: (frame.size.height / -2) + 200)
        playButton.fillColor = SKColor.cyan
        //7 I chose to use SKShapeNodes for this project due to their simplicity, this is an alternative to creating your graphics in an image editor. This line of code creates a path in the shape of a triangle. Please note if you plan on building and publishing an app you should use SKSpriteNodes to load an image you have created, ShapeNodes can cause performance issues when used in large quantities as they are dynamically drawn once per frame.
        let topCorner = CGPoint(x: -50, y: 50)
        let bottomCorner = CGPoint(x: -50, y: -50)
        let middle = CGPoint(x: 50, y: 0)
        let path = CGMutablePath()
        path.addLine(to: topCorner)
        path.addLines(between: [topCorner, bottomCorner, middle])
        //8  Set the triangular path we created to the playButton sprite and add to the GameScene.
        playButton.path = path
        self.addChild(playButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.nodes(at: location)
            for node in touchedNode {
                if node.name == "play_button" {
                    startGame()
                }
            }
        }
    }
    
    
    private func startGame() {
        print("start game")
        //1: Move the gameLogo off the screen and then hide it from view. The brackets after the SKAction run once the action completes. For instance if we run an SKAction of duration 10, the code inside the bracket would run after 10 seconds
        gameLogo.run(SKAction.move(by: CGVector(dx: -50, dy: 600), duration: 0.5)) {
            self.gameLogo.isHidden = true
        }
        //2: Scale the playButton to 0; this action shrinks the button and then hides it from view.
        playButton.run(SKAction.scale(to: 0, duration: 0.3)) {
            self.playButton.isHidden = true
        }
        //3: Move the bestScore label to the bottom of the screen.
        let bottomCorner = CGPoint(x: 0, y: (frame.size.height / -2) + 20)
        bestScore.run(SKAction.move(to: bottomCorner, duration: 0.3)) {
            self.gameBG.setScale(0)
            self.currentScore.setScale(0)
            self.gameBG.isHidden = false
            self.currentScore.isHidden = false
            self.gameBG.run(SKAction.scale(to: 1, duration: 0.3))
            self.currentScore.run(SKAction.scale(to: 1, duration: 0.3))
            //new code
            self.game.initGame()
        }
    }
    
    //Initializes the game view.
    private func initializeGameView() {
        //Add the current score label to the screen, this is hidden until we leave our menu.
        currentScore = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        currentScore.zPosition = 1
        currentScore.position = CGPoint(x: 0, y: (frame.size.height / -2) + 60)
        currentScore.fontSize = 40
        currentScore.isHidden = true
        currentScore.text = "Score: 0"
        currentScore.fontColor = SKColor.white
        self.addChild(currentScore)
        //Create a ShapeNode to represent our game’s playable area. This is where the snake will be moving around in.
        let width = Int(frame.size.width - 200)
        let height = Int(frame.size.height - 233)
        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        gameBG = SKShapeNode(rect: rect, cornerRadius: 0.02)
        gameBG.fillColor = SKColor.darkGray
        gameBG.zPosition = 2
        gameBG.isHidden = true
        self.addChild(gameBG)
        //Create the game board. This function initializes a ton of square cells and adds them to the game board.
        createGameBoard(width: width, height: height)
    }
    
    //create a game board, initialize array of cells
    private func createGameBoard(width: Int, height: Int) {
        let cellWidth: CGFloat = 27.5
        let numRows = 40
        let numCols = 20
        var x = CGFloat(width / -2) + (cellWidth / 2)
        var y = CGFloat(height / 2) - (cellWidth / 2)
        //loop through rows and columns, create cells..This method loops through 40 rows and 20 columns, for each row/column position we create a new square box or “cellNode” and add this to the scene. We also add this cellNode into an array “gameArray” so that we can easily pin point a row and column to the appropriate cell.
        for i in 0...numRows - 1 {
            for j in 0...numCols - 1 {
                let cellNode = SKShapeNode(rectOf: CGSize(width: cellWidth, height: cellWidth))
                cellNode.strokeColor = SKColor.black
                cellNode.zPosition = 2
                cellNode.position = CGPoint(x: x, y: y)
                //add to array of cells -- then add to game board
                gameArray.append((node: cellNode, x: i, y: j))
                gameBG.addChild(cellNode)
                //iterate x
                x += cellWidth
            }
            //reset x, iterate y
            x = CGFloat(width / -2) + (cellWidth / 2)
            y -= cellWidth
        }
    }
}
