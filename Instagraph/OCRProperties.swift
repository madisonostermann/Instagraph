//
//  OCRProperties.swift
//  Instagraph
//
//  Created by Madison Gipson on 6/2/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class OCRProperties: ObservableObject {
    @Published var page: String = "Home"
    @Published var source = ""
    @Published var image: UIImage? = nil
    @Published var finalImage: Image? = nil
    @Published var text: String = ""
}
