//
//  GameViewController.swift
//  RacingSISeI
//
//  Created by Daniel Tejeda on 23/10/17.
//  Copyright © 2017 Daniel Tejeda. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    //Properties
    let screenWidth = 2048
    let screenHeight = 1536

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Crear una ventana
        let scene = GameScene(size: CGSize(width: screenWidth, height: screenHeight))
        
        //Configurar el SpriteKit View
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        
        //Mostrar escena
        skView.presentScene(scene)
        skView.showsPhysics = true
        
        
        
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
