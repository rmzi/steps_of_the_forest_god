//
//  ViewController.swift
//  steps_of_the_forest_god
//
//  Created by Ramzi Abdoch on 7/29/17.
//  Copyright © 2017 Ramzi Abdoch. All rights reserved.
//

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
        
        // Rotate the tree to be upright
        self.palmNode?.rotation = SCNVector4Make(-1, 0, 0, Float(Double.pi / 2))
        
        // Set scale of tree to 0
        self.palmNode?.scale = SCNVector3Make(0, 0, 0)
        
        // Animate tree
        let growTreeAction = SCNAction.scale(to: 0.1, duration: 5)
        let shrinkTreeAction = SCNAction.scale(to: 0, duration: 5)
        let treeSequence = SCNAction.sequence([growTreeAction, shrinkTreeAction])
        
        // TEMP: Repeat the action forever
        let repAction = SCNAction.repeatForever(treeSequence!)
        
        self.palmNode?.runAction(repAction!)
        
        // Create Palm Instance
        let palmInstance = self.palmNode?.clone()
        palmInstance?.position = SCNVector3Make(0, 0, 10)
        
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
}
