//
//  AppDelegate.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/6.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        accentSetting()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    private func accentSetting() {
        let appearance = UINavigationBarAppearance()
        // 設置導航欄背景顏色
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .accent
        // 設置標題文字顏色
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        // 設置大標題文字顏色 (如果使用大標題)
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        // 應用於所有場景
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        // 設置按鈕顏色 (返回按鈕等)
        UINavigationBar.appearance().tintColor = .white
    }
}

