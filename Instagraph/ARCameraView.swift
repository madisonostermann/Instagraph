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

struct ARViewIndicator: UIViewControllerRepresentable {
    @ObservedObject var ocrProperties: OCRProperties
    typealias UIViewControllerType = ARCameraView
    
    func makeUIViewController(context: Context) -> ARCameraView {
        return ARCameraView(ocrProperties: ocrProperties)
    }
    func updateUIViewController(_ uiViewController: ARViewIndicator.UIViewControllerType, context: UIViewControllerRepresentableContext<ARViewIndicator>) { }
}

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
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        arView.addGestureRecognizer(tap)
    }
    
    //gesture recognizer that takes snapshot of arview when you tap anywhere
    @objc func handleTap(rec: UITapGestureRecognizer){
        if rec.state == .ended {
            //let location: CGPoint = rec.location(in: sceneView)
            //guard let hits = self.sceneView.hitTest(location, options: nil).first?.node else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            ocrProperties.image = self.arView.snapshot()
            ImageProcessingEngine(ocrProperties: ocrProperties).performImageRecognition()
            
            //present(UIHostingController(rootView: ContentView(ocrProperties: ocrProperties)), animated: true)
        }
    }
    
    //functions for standard ar handling
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      arView.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        arView.session.run(configuration)
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

