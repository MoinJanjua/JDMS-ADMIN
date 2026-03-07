//
//  AppNavigator.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 21/02/2026.
//

import UIKit

struct AppNavigator {
    
    static func navigateToLogin() {
        DispatchQueue.main.async {
            // 1. Clear the invalid token
            UserDefaults.standard.removeObject(forKey: "userToken")
            
            // 2. Setup Login Screen
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            
            // 3. Get the active window and switch root
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = loginVC
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        }
    }
}
