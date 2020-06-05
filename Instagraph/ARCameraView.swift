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
//import ARCL

struct ARViewIndicator: UIViewControllerRepresentable {
    @ObservedObject var ocrProperties: OCRProperties
    typealias UIViewControllerType = ARCameraView
    
    func makeUIViewController(context: Context) -> ARCameraView {
        return ARCameraView(ocrProperties: ocrProperties)
    }
    func updateUIViewController(_ uiViewController: ARViewIndicator.UIViewControllerType, context: UIViewControllerRepresentableContext<ARViewIndicator>) { }
}

class ARCameraView: UIViewController, ARSCNViewDelegate {
    var sceneView = ARView()
    @ObservedObject var ocrProperties: OCRProperties
    init(ocrProperties: OCRProperties) {
        self.ocrProperties = ocrProperties
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*@Binding var isShown: Bool?
    var source: String?
    @Binding var image: Image?
    @Binding var finalImage: Image?
    @Binding var text: String?
    init(isShown: Bool?, source: String?, image: Image?, finalImage: Image?, text: String?) {
        self.isShown = isShown
        self.source = source
        self.image = image
        self.finalImage = finalImage
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }*/
    
    /*@IBAction func tookSnapshot(_ sender: UIButton) {
        //shutterView.alpha = 1.0
        //shutterView.isHidden = false
        
        UIView.animate(withDuration: 1.0, animations: {
            //self.shutterView.alpha = 0.0
        }) { (finished) in
            //self.shutterView.isHidden = true
            UIImageWriteToSavedPhotosAlbum(self.sceneView.snapshot(), nil, nil, nil)
        }
    }*/

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: /*mode == "navigation" ? nil : */#selector(handleTap(rec:)))
        sceneView.addGestureRecognizer(tap)
        sceneView.run()
        view.addSubview(sceneView)
    }
    
    @objc func handleTap(rec: UITapGestureRecognizer){
        if rec.state == .ended {
            //let location: CGPoint = rec.location(in: sceneView)
            //guard let hits = self.sceneView.hitTest(location, options: nil).first?.node else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            //let image = self.sceneView.snapshot()
            //present(UIHostingController(rootView: ContentView()), animated: true)
            //UIImageWriteToSavedPhotosAlbum(self.sceneView.snapshot(), nil, nil, nil)
            ocrProperties.image = Image(uiImage: self.sceneView.snapshot())
            //ImageProcessingEngine(ocrProperties: ocrProperties)
            print(ocrProperties.image!)
            present(UIHostingController(rootView: ContentView(ocrProperties: ocrProperties)), animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      sceneView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Run the view's session
        sceneView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.pause()
    }

    // MARK: - ARSCNViewDelegate
    
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

