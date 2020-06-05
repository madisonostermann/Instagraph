//
//  ARView.swift
//  Instagraph
//
//  Created by Madison Gipson on 6/5/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import ARKit

//open class required for public extensions
open class ARView: ARSCNView {
    public weak var arTrackingDelegate: ARTrackingDelegate?
    public weak var arDelegate: ARSCNViewDelegate?
    public var arTrackingConfig = ARWorldTrackingConfiguration()

    //Initialize: specify CGRect for frame (default .zero) & rendering options for ARView
    public override init(frame: CGRect = .zero, options: [String: Any]? = nil) {
        super.init(frame: frame, options: options)
        finishInitialization()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        finishInitialization()
    }

    private func finishInitialization() {
        delegate = self
        //add touchGestureRecognizer here
    }
}

public protocol ARTrackingDelegate: class {

    func sessionWasInterrupted(_ session: ARSession)

    func sessionInterruptionEnded(_ session: ARSession)

    func session(_ session: ARSession, didFailWithError error: Error)

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera)

}

public extension ARView {

    func run() {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.worldAlignment = .gravityAndHeading
            session.run(configuration)
    }

    func pause() {
        session.pause()
    }
}
