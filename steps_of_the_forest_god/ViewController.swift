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
        
        // Find palmNode
        self.palmNode = allTreesScene.rootNode.childNode(withName: "palm1", recursively: true)
        
        // Create Palm Instance
        let palmInstance = self.palmNode?.clone()
        palmInstance?.position = SCNVector3Make(0, 0, 1)
        
        // Create Scene to hold everything
        // @Willie - I think this is the correct pattern for adding things from a .scn file (collection of meshes) to a new, separate scene that we can configure
        let scene = SCNScene()
        
        // Add Palm
        scene.rootNode.addChildNode(palmInstance!)
        
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
}
