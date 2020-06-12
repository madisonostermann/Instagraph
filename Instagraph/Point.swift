//
//  Point.swift
//  Instagraph
//
//  Created by Madison Gipson on 6/11/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import ARKit
 
class Point: SCNNode {
    static let radius: CGFloat = 0.005
    let pointGeometry: SCNSphere
 
    required init?(coder aDecoder: NSCoder) {
        pointGeometry = SCNSphere(radius: Point.radius)
        super.init(coder: aDecoder)
    }
    
    init(position: SCNVector3) {
        self.pointGeometry = SCNSphere(radius: Point.radius)
        super.init()
        let pointNode = SCNNode(geometry: self.pointGeometry)
        pointNode.position = position
        self.addChildNode(pointNode)
    }
 
    func clear() {
        self.removeFromParentNode()
    }
}
