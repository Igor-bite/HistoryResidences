//
//  AppDelegate.swift
//  HistoryResidences
//
//  Created by Игорь Клюжев on 18.10.2021.
//

import UIKit
import YandexMapsMobile

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		if let token = getApiToken() {
			YMKMapKit.setApiKey(token)
		}
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

	private func getApiToken() -> String? {
		var resourceFileDictionary: NSDictionary?
			
		if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
			resourceFileDictionary = NSDictionary(contentsOfFile: path)
		}
		
		if let resourceFileDictionaryContent = resourceFileDictionary {
			let token = resourceFileDictionaryContent.object(forKey: "YandexMapsToken") as? String
			if token == "" {
				return nil
			}
			return token
		} else { return nil }
	}
}

