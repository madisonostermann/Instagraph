//
//  ARCameraView.swift
//  Instagraph
//
//  Created by Madison Gipson on 6/2/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import UIKit
import SwiftUI
import ARKit
import SceneKit

// MARK: - ARViewIndicator (ties together AR UIKit & app SwiftUI)

struct ARViewIndicator: UIViewControllerRepresentable {
    @ObservedObject var ocrProperties: OCRProperties
    typealias UIViewControllerType = ARCameraView
    
    func makeUIViewController(context: Context) -> ARCameraView {
        return ARCameraView(ocrProperties: ocrProperties)
    }
    func updateUIViewController(_ uiViewController: ARViewIndicator.UIViewControllerType, context: UIViewControllerRepresentableContext<ARViewIndicator>) { }
}

// MARK: - ARCameraView

class ARCameraView: UIViewController, ARSCNViewDelegate {
    
    @ObservedObject var ocrProperties: OCRProperties
    
    //Initialization
    init(ocrProperties: OCRProperties) {
        self.ocrProperties = ocrProperties
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //create ARSCNView & load it, set up some config variables
    var arView: ARSCNView {
        return self.view as! ARSCNView
    }
    
    override func loadView() {
        self.view = ARSCNView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        arView.isUserInteractionEnabled = true
        arView.delegate = self
        arView.scene = SCNScene()
        arView.showsStatistics = false
        let snap = UITapGestureRecognizer(target: self, action: #selector(takeSnapshot(rec:)))
        arView.addGestureRecognizer(snap)
    }
    
    @objc func takeSnapshot(rec: UITapGestureRecognizer){
        if rec.state == .ended {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            self.ocrProperties.image = self.arView.snapshot()
            //correct perspective
            self.ocrProperties.image = PrepareImageBridge().deskew(self.ocrProperties.image)
            //crop
            Crop(ocrProperties: ocrProperties).setup()
        }
    }

    
    // MARK: - Functions for standard AR view handling
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      arView.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) { //setUpSceneView
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        arView.session.run(configuration)
        arView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func sessionWasInterrupted(_ session: ARSession) {} // Inform the user that the session has been interrupted, for example, by presenting an overlay

    func sessionInterruptionEnded(_ session: ARSession) {} // Reset tracking and/or remove existing anchors if consistent tracking is required

    func session(_ session: ARSession, didFailWithError error: Error) {} // Present an error message to the user

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {}
}
