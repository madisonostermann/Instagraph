//
//  CustomPoint.swift
//  Instagraph
//
//  Created by Madison Gipson on 6/11/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import RealityKit
import UIKit

class CustomPoint: Entity, HasModel, HasAnchoring, HasCollision {
    required init() {
        super.init()
        self.components[ModelComponent] = ModelComponent(
            mesh: .generatePlane(width: 0.01, depth: 0.01, cornerRadius: 50),
            materials: [SimpleMaterial(
                color: UIColor.white,
                isMetallic: false)
            ]
        )
    }
    convenience init(position: SIMD3<Float>) {
        self.init()
        self.position = position
    }
}
