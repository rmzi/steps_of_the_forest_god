//
//  ViewController.swift
//  steps_of_the_forest_god
//
//  Created by Ramzi Abdoch on 7/29/17.
//  Copyright © 2017 Ramzi Abdoch. All rights reserved.
//

import AVFoundation
import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var palmNodes = [SCNNode?]()
    var pineNodes = [SCNNode?]()
    var treeNodes = [SCNNode?]()
    var trunkNodes = [SCNNode?]()
    
    // Store AVPlayer
    var audioPlayer:AVPlayer!
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Play BG Music
        audioPlayer = AVPlayer(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "art.scnassets/bg_music", ofType: "mp3")!) as URL)
        audioPlayer.play()
        
        ///////////
        // DEBUG //
        ///////////
        // Turn on debug options to show the world origin and also render all
        // of the feature points ARKit is tracking
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        self.sceneView.autoenablesDefaultLighting = true
        
        // Load all trees
        let allTreesScene = SCNScene(named: "art.scnassets/trees.scn")!
        
        // Find all tree / trunk / palm nodes
        
        // Palm
        for i in 1...2 {
            self.palmNodes.append(allTreesScene.rootNode.childNode(withName: "palm\(i)", recursively: true))
        }
        
        // Pine
        for i in 1...5 {
            self.pineNodes.append(allTreesScene.rootNode.childNode(withName: "pine\(i)", recursively: true))
        }
        
        // Tree
        for i in 1...5 {
            self.treeNodes.append(allTreesScene.rootNode.childNode(withName: "tree\(i)", recursively: true))
        }
        
        // Trunk
        for i in 1...3 {
            self.trunkNodes.append(allTreesScene.rootNode.childNode(withName: "trunk\(i)", recursively: true))
        }
        
        // Create Scene to hold everything
        // @Willie - I think this is the correct pattern for adding things from a .scn file (collection of meshes) to a new, separate scene that we can configure
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // Creates ring of trees around a specified point
    func createForestRing(position: SCNVector3, radius: Float, amount: Int) {
        // Calculate points along the circumfrence
        for i in 0...(amount-1) {
            // Use trigonometry to calculate coordinates #radians
            var treePosition: SCNVector3 = position
            treePosition.x = treePosition.x + (radius)*cos(2.0 * Float.pi / Float(amount) * Float(i))
            treePosition.z = treePosition.z - (radius)*sin(2.0 * Float.pi / Float(amount) * Float(i))

            createTree(position: treePosition, maxScale: 0.5, minScale: 0.2, maxDelay: 1.0)
        }
    }
    
    // Creates a copy of a random tree and randomizes the animation & rotation
    func createTree(position : SCNVector3, maxScale : Float, minScale: Float, maxDelay: Double) {
        let allTrees = [palmNodes, pineNodes, treeNodes, trunkNodes]
        let randTypeIndex = arc4random_uniform(UInt32(allTrees.count))
        let randType = allTrees[Int(randTypeIndex)]
        let randNodeIndex = arc4random_uniform(UInt32(randType.count))
        let randNode = randType[Int(randNodeIndex)]
        
        let treeClone = randNode!.clone()
        
        // Set scale of tree to 0
        treeClone.scale = SCNVector3Make(0, 0, 0)
        
        // Play tree creation sound (TODO: Find a better sound)
        let audioSource = SCNAudioSource(fileNamed: "art.scnassets/tree_sound.mp3")
        let playSound = SCNAction.playAudio(audioSource!, waitForCompletion: false)
        
        // Calculate a random scale between the provided min and max scale
        let scaleAmt = CGFloat(drand48()) * CGFloat(maxScale - minScale) + CGFloat(minScale)
        
        // Animate tree to grow then shrink
        let growTreeAction = SCNAction.scale(to: scaleAmt, duration: 0.5)
        let shrinkTreeAction = SCNAction.scale(to: 0, duration: 1.5)

        var delaySequence : SCNAction
        var treeSequence : SCNAction

        let delayAmt = drand48() * maxDelay
        delaySequence = SCNAction.wait(duration: delayAmt)
        
        // Randomize deletion (some elements won't be deleted after growing)
        let deletionChance = 0.67
        
        if (drand48() < deletionChance) {
            treeSequence = SCNAction.sequence([
                delaySequence,
                playSound,
                growTreeAction,
                shrinkTreeAction,
                SCNAction.removeFromParentNode()
                ])!
        } else {
            treeSequence = SCNAction.sequence([
                delaySequence,
                playSound,
                growTreeAction
                ])!
        }
        
        treeClone.runAction(treeSequence)
        
        // Set position of palm tree to position passed through parameter
        treeClone.position = position
        
        sceneView.scene.rootNode.addChildNode(treeClone)
    }
    
    // TEMP: Create trees on touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Compute the 3D position where the user tapped
        guard let touch = touches.first else { return }
        let results = sceneView.hitTest(touch.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
        guard let hitFeature = results.last else { return }
        let hitTransform = SCNMatrix4(hitFeature.worldTransform)
        let hitPosition = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)

        // Creates a forest ring at the location detected by touch
        createForestRing(position: hitPosition, radius: 0.25, amount: 8)
    }
}
