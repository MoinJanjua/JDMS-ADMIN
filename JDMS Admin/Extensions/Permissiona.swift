//
//  Permissiona.swift
//  JDMS Admin
//
//  Created by Moin Janjua on 17/03/2026.
//

import UIKit

enum PermissionAction {
    case addBanner
    case manageRoles
    case manageGeography    // Regions/Districts
    case editMembers
    case verifyMember
    case viewIjtimat
    case AddDawatTarbiah
    case addIjtimat
    case manageAmeerIntro   // New: Admin & SuperAdmin only
    case Adddesigination
    case AddNotification
}

class PermissionManager {
    static let shared = PermissionManager()
    
    private init() {} // Prevent multiple instances
    
    func saveUserRoles(_ roles: [String]) {
            UserDefaults.standard.set(roles, forKey: "userRoles")
        }
    
    func getUserRoles() -> [String] {
            return UserDefaults.standard.stringArray(forKey: "userRoles") ?? []
        }
    
    func canPerform(action: PermissionAction) -> Bool {
        let roles = UserDefaults.standard.stringArray(forKey: "userRoles") ?? []
        
        // 1. Super Admin: Full System Access
        if roles.contains(UserRole.superAdmin.rawValue) {
            return true
        }
        
        // 2. Admin: Full Access except promoting others to SuperAdmin (handled in UI)
        if roles.contains(UserRole.admin.rawValue) {
            return true
        }
        
        // 3. Election Officer: Restricted Access
        if roles.contains(UserRole.electionOfficer.rawValue) {
                    switch action {
                    case .editMembers, .viewIjtimat:
                        return true
                    case .verifyMember:
                        return false // Cannot verify members
                    case .addBanner, .manageRoles, .manageGeography, .addIjtimat, .manageAmeerIntro, .AddDawatTarbiah,.Adddesigination,.AddNotification :
                        return false
                    }
                }
        // 4. Standard User / Default
        return false
    }
}

enum UserRole: String {
    case superAdmin = "SuperAdmin"
    case admin = "Admin"
    case electionOfficer = "ElectionOfficer"
    case user = "User"
}
