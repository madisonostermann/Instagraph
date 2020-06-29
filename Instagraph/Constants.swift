//
//  Constants.swift
//  
//
//  Created by Lannie Hough on 6/1/20.
//

import Foundation
import UIKit
import SwiftUI

struct Constants {
    static let NON_NUMBER_INFORMATION:[Character] = ["$", "£", "€", "%", " "]
    static let SCREEN_WIDTH = UIScreen.main.bounds.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.height
    static let GRAPH_COLORS:[Color] = [Color.blue, Color.red, Color.purple, Color.yellow, Color.green, Color.orange]
    
    //App Colors
    static let turquoise = Color(red:30, green:187, blue:215) //https://www.color-hex.com/color-palette/30415
    static let MONTHS:[String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    static let MONTHS_SHORT:[String] = {
        var mS:[String] = []
        for month in MONTHS {
            let short:String = month.split(3).0
            mS.append(short)
        }
        return mS
    }()
    static let ALL_MONTHS = MONTHS + MONTHS_SHORT
}
