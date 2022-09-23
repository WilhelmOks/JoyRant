//
//  UserSettings.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 06.09.22.
//

import Foundation

struct UserSettings {
    @UserDefaultsBackedDefaulting(key: "test_dummy", defaultValue: false)
    var testDummy
}

@propertyWrapper private struct UserDefaultsBacked<Value> {
    let key: String
    var storage: UserDefaults = .standard
    
    var wrappedValue: Value? {
        get {
            storage.value(forKey: key) as? Value
        }
        nonmutating set {
            storage.setValue(newValue, forKey: key)
        }
    }
}

@propertyWrapper private struct UserDefaultsBackedDefaulting<Value> {
    let key: String
    var storage: UserDefaults = .standard
    var defaultValue: Value
    
    var wrappedValue: Value {
        get {
            (storage.value(forKey: key) as? Value) ?? defaultValue
        }
        nonmutating set {
            storage.setValue(newValue, forKey: key)
        }
    }
}
