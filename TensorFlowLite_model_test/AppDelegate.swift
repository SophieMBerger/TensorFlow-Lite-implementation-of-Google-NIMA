//
//  AppDelegate.swift
//  TensorFlowLite_model_test
//
//  Created by Sophie Berger on 12.07.19.
//  Copyright © 2019 SophieMBerger. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMLCommon

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // Load local models
        guard let aestheticModelPath = Bundle.main.path(forResource: "aesthetic_model", ofType: "tflite")
            else {
                // Invalid model path
                return false
        }
        let aestheticLocalModel = LocalModel(name: "aesthetic_model", path: aestheticModelPath)
        ModelManager.modelManager().register(aestheticLocalModel)
        
        guard let technicalModelPath = Bundle.main.path(forResource: "technical_model", ofType: "tflite")
            else {
                // Invalid model path
                return false
        }
        let technicalLocalModel = LocalModel(name: "technical_model", path: technicalModelPath)
        ModelManager.modelManager().register(technicalLocalModel)
        
        // Loading the remote aesthetic and technical models
        let initialConditions = ModelDownloadConditions(
            allowsCellularAccess: true,
            allowsBackgroundDownloading: true
        )

        let updateConditions = ModelDownloadConditions(
            allowsCellularAccess: false,
            allowsBackgroundDownloading: true
        )

        let aestheticModel = RemoteModel(
            name: "aesthetic_model",
            allowsModelUpdates: true,
            initialConditions: initialConditions,
            updateConditions: updateConditions
        )

        let technicalModel = RemoteModel(
            name: "technical_model",
            allowsModelUpdates: true,
            initialConditions: initialConditions,
            updateConditions: updateConditions
        )

        ModelManager.modelManager().register(aestheticModel)
        ModelManager.modelManager().register(technicalModel)
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

