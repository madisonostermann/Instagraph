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
//import SceneKit
import RealityKit

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
    let coachingOverlay = ARCoachingOverlayView()
    
    //Initialization
    init(ocrProperties: OCRProperties) {
        self.ocrProperties = ocrProperties
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //create ARSCNView & load it, set up some config variables
    var arView: ARView/*ARSCNView*/ {
        //return self.view as! ARSCNView
        return self.view as! ARView //works with CustomPoint, more realitykit centered stuff
    }
    
    override func loadView() {
        //self.view = ARSCNView(frame: .zero)
        self.view = ARView(frame: .zero) //works with CustomPoint, more realitykit centered stuff
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        arView.isUserInteractionEnabled = true
        //arView.delegate = self
        //arView.scene = SCNScene()
        //arView.showsStatistics = false
        //setupCoachingOverlay()
        
        //let snap = UITapGestureRecognizer(target: self, action: #selector(takeSnapshot(rec:)))
        //arView.addGestureRecognizer(snap)
        let tap = UITapGestureRecognizer(target: self, action: #selector(addPoint))
        arView.addGestureRecognizer(tap)
        //let pan = UIPanGestureRecognizer(target: self, action: #selector(movePoint(recognizer:)))
        //arView.addGestureRecognizer(pan)
    }
    
    @objc func addPoint(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: arView)
        let hitTestResults = arView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if !hitTestResults.isEmpty {
            guard let hitResult = hitTestResults.first else { return }
            //let point: Point = Point(position: SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z))
            //arView.scene.rootNode.addChildNode(point)
            let customPoint = CustomPoint(position: SIMD3<Float>(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z))
            arView.scene.anchors.append(customPoint)
        }
    }
    
    
    
//    @objc func movePoint(recognizer: UIPanGestureRecognizer) {
//        if (recognizer.state == .failed || recognizer.state == .cancelled) { return }
//
//        let initialTap = recognizer.location(in: arView)
//        //guard let pointTapped = arView.hitTest(initialTap, options: nil).first?.node else { return }
//        let newPosition = initialTap
//        let deltaX = Float(initialTap.x - newPosition.x)/700
//        let deltaY = Float(initialTap.y - newPosition.y)/700
//        //let deltaZ = Float(initialTap.z - newPosition.z)/700
//        //pointTapped.worldTransform(SCNVector3Make(deltaX, 0.0, deltaY))
//    }
    
//    @objc func movePoint(panGesture: UIPanGestureRecognizer) {
//      guard let view = view as? SCNView else { return }
//      let location = panGesture.location(in: self.view)
//      switch panGesture.state {
//      case .began:
//        // existing logic from previous approach. Keep this.
//        guard let hitNodeResult = view.hitTest(location, options: nil).first else { return }
//        //panStartZ = CGFloat(view.projectPoint(lastPanLocation!).z)
//        // lastPanLocation is new
//        let lastPanLocation = hitNodeResult.worldCoordinates
//        let panStartZ = CGFloat(view.projectPoint(lastPanLocation).z)
//      case .changed:
//        // This entire case has been replaced
//        let lastPanLocation = hitNodeResult.worldCoordinates
//        let worldTouchPosition = view.unprojectPoint(SCNVector3(location.x, location.y, panStartZ!))
//        let movementVector = SCNVector3(
//          worldTouchPosition.x - lastPanLocation!.x,
//          worldTouchPosition.y - lastPanLocation!.y,
//          worldTouchPosition.z - lastPanLocation!.z)
//        geometryNode.localTranslate(by: movementVector)
//        self.lastPanLocation = worldTouchPosition
//      default:
//        break
//      }
//    }
    
    @objc func takeSnapshot(rec: UITapGestureRecognizer){
        if rec.state == .ended {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            //ocrProperties.image = self.arView.snapshot()
            ImageProcessingEngine(ocrProperties: ocrProperties).performImageRecognition()
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
        //arView.delegate = self
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
