//
//  SceneDelegate.swift
//  Instagraph
//
//  Created by Madison Gipson on 5/25/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var ocrProperties: OCRProperties!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // DALTON TESTING //
        
        var tables:[[[String]]] = []
        
        let bar:[[String]] = [["Student Scores", "Student", "Maddie", "Dalton", "Aaron"], ["Student Scores", "Score", "5", "1", "3"]]
        tables.append(bar)
        let line:[[String]] = [["The Graph", "Salt Concentration", "3", "6", "9"], ["The Graph", "Transmittance", "85.43", "50", "33.45"]]
        tables.append(line)
        let scatter:[[String]] = [["Size", "Height", "5", "4", "1"], ["Size", "Width", "2.2", "3.3", "5"]]
        tables.append(scatter)
        print(tables.count)
        for table in tables {
            print(table)
        }
        
        for table in tables {
            let g:GraphEngine = GraphEngine(table: table)
            let result = g.determineGraphType()
            print("RESULT (SUCCESS/FAILURE): ", result.0)
            for x in result.1 {
                switch x {
                case is LineGraph:
                    print("GRAPH TYPE: LINE")
                    print("TITLE: ", x.title)
                    print("X-LABEL: ", x.xAxisLabel)
                    print("Y-LABEL: ", x.yAxisLabel)
                    print("X-VALS: ", (x as! LineGraph).xAxisValues)
                    print("DATA: ", (x as! LineGraph).data)
                case is BarGraph:
                    print("GRAPH TYPE: BAR")
                    print("TITLE: ", x.title)
                    print("X-LABEL: ", x.xAxisLabel)
                    print("Y-LABEL: ", x.yAxisLabel)
                    print("X-VALS: ", (x as! BarGraph).xAxisValues)
                    print("DATA: ", (x as! BarGraph).data)
                case is ScatterPlot:
                    print("GRAPH TYPE: SCATTER")
                    print("TITLE: ", x.title)
                    print("X-LABEL: ", x.xAxisLabel)
                    print("Y-LABEL: ", x.yAxisLabel)
                    print("DATA: ", (x as! ScatterPlot).data)
                default:
                    print("GRAPH TYPE: NONE")
                }
            }
        }
        
        // DALTON TESTING END //
        
        
        self.ocrProperties = OCRProperties()
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(ocrProperties: ocrProperties)//GraphView()

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

