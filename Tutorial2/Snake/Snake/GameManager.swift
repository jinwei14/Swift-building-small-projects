//
//  GameManager.swift
//  Snake
//
//  Created by Jinwei Zhang on 08/01/2020.
//  Copyright © 2020 Jinwei Zhang. All rights reserved.
//

import SpriteKit
class GameManager {
    var scene: GameScene!
    //initialize two new variables. nextTime is the nextTime interval we will print a statement to the console, timeExtension is how long we will wait between each print (1 second).
    var nextTime: Double?
    var timeExtension: Double = 0.15
    //Create a variable that is used to determine the player’s current direction. In the code the variable is set to 1, in the gif in Figure Q I set the direction to 4. Change this variable to see all the different directions.
    var playerDirection: Int = 4 // 1==left 2==up  3==right 4==down
    
    //1
    var currentScore: Int = 0
    init(scene: GameScene) {
        self.scene = scene
    }
    
    //1: initGame() function. This adds 3 coordinates to the GameScene’s playerPositions array,
    func initGame() {
        //starting player position
        scene.playerPositions.append((10, 10))
        scene.playerPositions.append((10, 11))
        scene.playerPositions.append((10, 12))
        renderChange()
        //Call the function inside the initGame() function that will generate a new random point.
        generateNewPoint()
    }
    
    //This update function is called 60 times per second, we only want to update the player position once per second so that the game is not ridiculously fast. In order to accomplish this we check if nextTime has been set.
    func update(time: Double) {
        if nextTime == nil {
            nextTime = time + timeExtension
        } else {
            if time >= nextTime! {
                nextTime = time + timeExtension
                updatePlayerPosition()
                //Call the checkForScore() function inside the update function, this is called every time the player moves.
                checkForScore()
                //Call the checkForDeath() function.
                checkForDeath()
                //Call the finishAnimation() function.
                finishAnimation()
            }
        }
    }
    //This function checks if a scorePos has been set, if it has then it checks the head of the snake. If the snake is touching a point then the score is iterated, the text label showing the score is updated and a new point is generated.
    private func checkForScore() {
        if scene.scorePos != nil {
            let x = scene.playerPositions[0].0
            let y = scene.playerPositions[0].1
            if Int((scene.scorePos?.x)!) == y && Int((scene.scorePos?.y)!) == x {
                currentScore += 1
                scene.currentScore.text = "Score: \(currentScore)"
                generateNewPoint()
                scene.playerPositions.append(scene.playerPositions.last!)
                scene.playerPositions.append(scene.playerPositions.last!)
                scene.playerPositions.append(scene.playerPositions.last!)
            }
        }
    }
    
    //Check if the player’s head has collided with any of the tail positions. If player has died then set playerDirection to 0.
    private func checkForDeath() {
        if scene.playerPositions.count > 0 {
            var arrayOfPositions = scene.playerPositions
            let headOfSnake = arrayOfPositions[0]
            arrayOfPositions.remove(at: 0)
            if contains(a: arrayOfPositions, v: headOfSnake) {
                playerDirection = 0
            }
        }
    }
    
    //This function will check for the completion of the snake’s final animation when it closes in on itself. Once all positions in the playerPositions array match each other the snake has shrunk to one square. After this occurs we set the playerDirection to 4 (it was previously set to 0 indicating death) and then we show the menu objects. We also hide the currentScore label and gameBG object (the grid of squares).
    private func finishAnimation() {
        if playerDirection == 0 && scene.playerPositions.count > 0 {
            var hasFinished = true
            let headOfSnake = scene.playerPositions[0]
            for position in scene.playerPositions {
                if headOfSnake != position {
                    hasFinished = false
                }
            }
            if hasFinished {
                print("end game")
                updateScore()
                playerDirection = 4
                //animation has completed
                scene.scorePos = nil
                scene.playerPositions.removeAll()
                renderChange()
                //return to menu
                scene.currentScore.run(SKAction.scale(to: 0, duration: 0.4)) {
                    self.scene.currentScore.isHidden = true
                }
                scene.gameBG.run(SKAction.scale(to: 0, duration: 0.4)) {
                    self.scene.gameBG.isHidden = true
                    self.scene.gameLogo.isHidden = false
                    self.scene.gameLogo.run(SKAction.move(to: CGPoint(x: 0, y: (self.scene.frame.size.height / 2) - 200), duration: 0.5)) {
                        self.scene.playButton.isHidden = false
                        self.scene.playButton.run(SKAction.scale(to: 1, duration: 0.3))
                        self.scene.bestScore.run(SKAction.move(to: CGPoint(x: 0, y: self.scene.gameLogo.position.y - 50), duration: 0.3))
                    }
                }
            }
        }
    }
    
    //This function generates a random position within the bounds of the board (20/40), arrays start counting at 0 so we count from 0 to 19 and from 0 to 39, this is a 20x40 array.
    private func generateNewPoint() {
        var randomX = CGFloat(arc4random_uniform(19))
        var randomY = CGFloat(arc4random_uniform(39))
        // ensure that a point is not generated inside the body of the snake.
        while contains(a: scene.playerPositions, v: (Int(randomX), Int(randomY))) {
            randomX = CGFloat(arc4random_uniform(19))
            randomY = CGFloat(arc4random_uniform(39))
        }
        scene.scorePos = CGPoint(x: randomX, y: randomY)
    }
    
    //2: renderChange() function. We will call this method every time we move the “snake” or player. This renders all blank squares as clear and all squares where the player is located as cyan.
    func renderChange() {
        for (node, x, y) in scene.gameArray {
            if contains(a: scene.playerPositions, v: (x,y)) {
                node.fillColor = SKColor.cyan
            } else {
                node.fillColor = SKColor.clear
                //check if the current node’s position matches that of the randomly placed score, if we have a match then we set the color to red. You can modify the color to suit your liking. The variable that saves the score’s position is a CGPoint, this means we have to check the point.x and the point.y and compare it to the locations of the current node’s x and y. Note, the x/y positions are flipped in the array of nodes, that is why we are comparing x == y and y == x.
                if scene.scorePos != nil {
                    if Int((scene.scorePos?.x)!) == y && Int((scene.scorePos?.y)!) == x {
                        node.fillColor = SKColor.red
                    }
                }
            }
        }
        
    }
    //3: This is a simple function that checks if a tuple (a swift data structure that can contain an combination of types in the form of (Int, CGFloat, Int, String)…. etc) exists in an array of tuples. This function checks if the playerPositions array contains the inputted coordinates from the GameScene’s array of cells. This is not necessarily the most efficient way of doing things as we are checking every single cell during each update. If you want to challenge yourself, try to update the code so that it only modifies the squares from the playerPositions array!
    func contains(a:[(Int, Int)], v:(Int,Int)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a { if v1 == c1 && v2 == c2 { return true } }
        return false
    }
    
    // This method moves the player or “snake” around the screen
    private func updatePlayerPosition() {
        // Set variables to determine the change we should make to the x/y of the snake’s front.
        var xChange = -1
        var yChange = 0
        //This is a switch statement, it takes the input of the playerPosition and modifies the x/y variables according to wether the player is moving up, down, left or right.
        switch playerDirection {
        case 1:
            //left
            xChange = -1
            yChange = 0
            break
        case 2:
            //up
            xChange = 0
            yChange = -1
            break
        case 3:
            //right
            xChange = 1
            yChange = 0
            break
        case 4:
            //down
            xChange = 0
            yChange = 1
            break
        //4
        case 0:
            //dead
            xChange = 0
            yChange = 0
            break
        default:
            break
        }
        //6
        if scene.playerPositions.count > 0 {
            var start = scene.playerPositions.count - 1
            while start > 0 {
                scene.playerPositions[start] = scene.playerPositions[start - 1]
                start -= 1
            }
            scene.playerPositions[0] = (scene.playerPositions[0].0 + yChange, scene.playerPositions[0].1 + xChange)
        }
        //This code is fairly simple, it checks if the position of the head of the snake has passed the top, bottom, left side or right side and then moves the player to the other side of the screen.
        if scene.playerPositions.count > 0 {
            let x = scene.playerPositions[0].1
            let y = scene.playerPositions[0].0
            if y > 40 {
                scene.playerPositions[0].0 = 0
            } else if y < 0 {
                scene.playerPositions[0].0 = 40
            } else if x > 20 {
                scene.playerPositions[0].1 = 0
            } else if x < 0 {
                scene.playerPositions[0].1 = 20
            }
        }
        
        //7
        renderChange()
    }
    
    //If a swipe is not conflicting with the current direction, set the player’s direction to the swipe input. If you are moving down you can’t immediately move up. If you are moving left you can’t suddenly move right. In some versions of snake inputting an improper move like this would result in death, but in this version we are simply going to ignore extraneous inputs.
    func swipe(ID: Int) {
        if !(ID == 2 && playerDirection == 4) && !(ID == 4 && playerDirection == 2) {
            if !(ID == 1 && playerDirection == 3) && !(ID == 3 && playerDirection == 1) {
                if playerDirection != 0 {
                    playerDirection = ID
                }
            }
            
        }
    }
    
    //1
    private func updateScore() {
         if currentScore > UserDefaults.standard.integer(forKey: "bestScore") {
              UserDefaults.standard.set(currentScore, forKey: "bestScore")
         }
         currentScore = 0
         scene.currentScore.text = "Score: 0"
         scene.bestScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
    }
    
}
