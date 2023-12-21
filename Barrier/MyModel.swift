//
//  MyModel.swift
//  Barrier
//
//  Created by Jared Cassoutt on 10/24/23.
//

import Foundation
import FamilyControls
import ManagedSettings
import UIKit
import SwiftUI

private let _MyModel = MyModel()
class MyModel: ObservableObject {
    @Published var selectionToDiscourage: FamilyActivitySelection
    @AppStorage("categoryTokensData") private var categoryTokensData: Data?
    @AppStorage("applicationTokensData") private var applicationTokensData: Data?

    // Computed properties for tokens
    var categoryTokens: Set<ActivityCategoryToken>? {
        get {
            if let data = categoryTokensData {
                let decoder = JSONDecoder()
                if let decodedTokens = try? decoder.decode(Set<ActivityCategoryToken>.self, from: data) {
                    return decodedTokens
                }
            }
            return nil
        }
        set {
            if let newTokens = newValue {
                let encoder = JSONEncoder()
                if let encodedData = try? encoder.encode(newTokens) {
                    categoryTokensData = encodedData
                } else {
                    categoryTokensData = nil
                }
            } else {
                categoryTokensData = nil
            }
        }
    }
    
    var applicationTokens: Set<ApplicationToken>? {
        get {
            if let data = applicationTokensData {
                let decoder = JSONDecoder()
                if let decodedTokens = try? decoder.decode(Set<ApplicationToken>.self, from: data) {
                    return decodedTokens
                }
            }
            return nil
        }
        set {
            if let newTokens = newValue {
                let encoder = JSONEncoder()
                if let encodedData = try? encoder.encode(newTokens) {
                    applicationTokensData = encodedData
                } else {
                    applicationTokensData = nil
                }
            } else {
                applicationTokensData = nil
            }
        }
    }

    init() {
        selectionToDiscourage = FamilyActivitySelection()
        
        if let applicationTokens = applicationTokens {
            selectionToDiscourage.applicationTokens = applicationTokens
        }
        
        if let categoryTokens = categoryTokens {
            selectionToDiscourage.categoryTokens = categoryTokens
        }
    }
    
    class var shared: MyModel {
        return _MyModel
    }
    
    func setShieldRestrictions(store: ManagedSettingsStore) {
        applicationTokens = selectionToDiscourage.applicationTokens
        categoryTokens = selectionToDiscourage.categoryTokens
        
        store.shield.applications = selectionToDiscourage.applicationTokens
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(selectionToDiscourage.categoryTokens)
    }
}

