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

    var palmNode: SCNNode?
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Load all trees
        let allTreesScene = SCNScene(named: "art.scnassets/trees.scn")!
        
        // Find palmNode
        self.palmNode = allTreesScene.rootNode.childNode(withName: "palm1", recursively: true)
        
        // Set the scene to the view
        sceneView.scene = allTreesScene
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
    
    // Creates trees in a ring
    func createPalmTreeRing(position: SCNVector3, radius: Float, amount: Int) {
        // TODO: Calculate ring around touch point
        
        // TEMP: Create a singular palm tree at center of ring
        createPalmTree(position: position, maxScale: 0.5, minScale: 0.2)
    }
    
    // Creates a copy of the palm tree and randomizes the animation & rotation
    func createPalmTree(position : SCNVector3, maxScale : Float, minScale: Float) {
        // TODO: Randomize the palm tree's vertical rotation and the scale the trees grow to
        
        let palmClone = palmNode!.clone()
        
        // Rotate the palm tree to be upright
        palmClone.rotation = SCNVector4Make(-1, 0, 0, Float(Double.pi / 2))
        
        // Set scale of tree to 0
        palmClone.scale = SCNVector3Make(0, 0, 0)
        
        // Animate tree to grow then shrink
        let audioSource = SCNAudioSource(fileNamed: "art.scnassets/tree_sound.mp3")
        let playSound = SCNAction.playAudio(audioSource!, waitForCompletion: false)
        
        let growPalmAction = SCNAction.scale(to: 0.3, duration: 0.5)
        let shrinkPalmAction = SCNAction.scale(to: 0, duration: 1.5)
        let palmSequence = SCNAction.sequence([playSound, growPalmAction, shrinkPalmAction, SCNAction.removeFromParentNode()])
        
        palmClone.runAction(palmSequence!)
        
        // Set position of palm tree to position passed through parameter
        palmClone.position = position
        
        sceneView.scene.rootNode.addChildNode(palmClone)
    }
    
    // TEMP: Create trees on touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Compute the 3D position where the user tapped
        guard let touch = touches.first else { return }
        let results = sceneView.hitTest(touch.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
        guard let hitFeature = results.last else { return }
        let hitTransform = SCNMatrix4(hitFeature.worldTransform)
        let hitPosition = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
        
        // Creates a palm tree at the location detected by touch
        createPalmTreeRing(position: hitPosition, radius: 0.5, amount: 8)
    }
}
