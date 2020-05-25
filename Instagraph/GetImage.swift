//
//  GetImage.swift
//  Instagraph
//
//  Created by Madison Gipson on 5/25/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI

struct GetImage: View {
    @Binding var isShown: Bool
    @Binding var source: String
    @Binding var image: Image?
    @Binding var finalImage: Image?
    @Binding var text: String
    
    var body: some View {
        VStack{
            if source == "Photo" {
                ImagePicker(isShown: $isShown, source: source, image: $image, finalImage: $finalImage, text: $text)
            } else if source == "Camera" {
                ImagePicker(isShown: $isShown, source: source, image: $image, finalImage: $finalImage, text: $text)
            } else if source == "Document" {
                Text("Document Finder not implemented yet")
                //will probably implement in ImagePicker as well
                //DocumentFinder(isShown: $showDocumentFinder, image: $image)
            }
        }
    }
}
