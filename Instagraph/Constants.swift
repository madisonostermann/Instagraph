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
    static let NON_NUMBER_INFORMATION:[Character] = ["$", "£", "€", "%", " ", ","]
    static let SCREEN_WIDTH = UIScreen.main.bounds.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.height
    static let GRAPH_COLORS:[Color] = [Color.blue, Color.red, Color.purple, Color.yellow, Color.green, Color.orange]
    static let DARK_GREY:CGColor = CGColor(red: 44/255, green: 47/255, blue: 51/255, alpha: 1.0)
    //App Colors
    static let turquoise = Color(red:30, green:187, blue:215) //https://www.color-hex.com/color-palette/30415
    static let MONTHS:[String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    static let MONTHS_SHORT:[String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    static let ALL_MONTHS = MONTHS + MONTHS_SHORT
}
