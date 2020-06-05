//
//  ARDelegate.swift
//  Instagraph
//
//  Created by Madison Gipson on 6/5/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import ARKit

//ARSCNViewDelegate
extension ARView: ARSCNViewDelegate {

    public func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        return arDelegate?.renderer?(renderer, nodeFor: anchor) ?? nil
    }

    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        arDelegate?.renderer?(renderer, didAdd: node, for: anchor)
    }

    public func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        arDelegate?.renderer?(renderer, willUpdate: node, for: anchor)
    }

    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        arDelegate?.renderer?(renderer, didUpdate: node, for: anchor)
    }

    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        arDelegate?.renderer?(renderer, didRemove: node, for: anchor)
    }

}

//ARSessionObserver: manages session state (failed, interrupted, ended, camera tracking)
extension ARView {

    public func session(_ session: ARSession, didFailWithError error: Error) {
        defer { arDelegate?.session?(session, didFailWithError: error) }
        print("session failed with error: \(error)")
        arTrackingDelegate?.session(session, didFailWithError: error)
    }

    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        defer { arDelegate?.session?(session, cameraDidChangeTrackingState: camera) }
        switch camera.trackingState {
        case .limited(.insufficientFeatures):
            print("camera changed tracking state: limited, insufficient features")
        case .limited(.excessiveMotion):
            print("camera changed tracking state: limited, excessive motion")
        case .limited(.initializing):
            print("camera changed tracking state: limited, initializing")
        case .normal:
            print("camera changed tracking state: normal")
        case .notAvailable:
            print("camera changed tracking state: not available")
        case .limited(.relocalizing):
            print("camera changed tracking state: limited, relocalizing")
        default:
            print("camera changed tracking state: unknown...")
        }
        arTrackingDelegate?.session(session, cameraDidChangeTrackingState: camera)
    }

    public func sessionWasInterrupted(_ session: ARSession) {
        defer { arDelegate?.sessionWasInterrupted?(session) }
        print("session was interrupted")
        arTrackingDelegate?.sessionWasInterrupted(session)
    }

    public func sessionInterruptionEnded(_ session: ARSession) {
        defer { arDelegate?.sessionInterruptionEnded?(session) }
        print("session interruption ended")
        arTrackingDelegate?.sessionInterruptionEnded(session)
    }

    public func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return arDelegate?.sessionShouldAttemptRelocalization?(session) ?? true
    }

    public func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {
        arDelegate?.session?(session, didOutputAudioSampleBuffer: audioSampleBuffer)
    }

}
