//
//  LoginStore.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 20.10.22.
//

import Foundation
import SwiftKeychainWrapper
import SwiftDevRant

final class LoginStore {
    static let shared = LoginStore()
    private init() {}
    
    private let keychainWrapper = KeychainWrapper(serviceName: "SwiftUIRant")
    
    private let tokenKey: KeychainWrapper.Key = "devRantToken"
    private let usernameKey: KeychainWrapper.Key = "username"
    private let passwordKey: KeychainWrapper.Key = "password"
    
    var isLoggedIn: Bool { token != nil }
    
    var token: AuthToken? {
        get {
            let encodedToken: AuthToken.CodingData? = keychainWrapper.decode(forKey: tokenKey.rawValue)
            return encodedToken?.decoded
        }
        set {
            if let encodedToken = newValue?.encoded {
                let success = keychainWrapper.encodeAndSet(
                    encodedToken,
                    forKey: tokenKey.rawValue,
                    withAccessibility: .whenUnlockedThisDeviceOnly
                )
                if !success {
                    dlog("Error: failed to store \(tokenKey.rawValue) in keychain")
                }
            } else {
                keychainWrapper.remove(forKey: tokenKey)
            }
        }
    }
    
    var username: String? {
        get {
            return keychainWrapper.decode(forKey: usernameKey.rawValue)
        }
        set {
            if let newValue {
                let success = keychainWrapper.encodeAndSet(
                    newValue,
                    forKey: usernameKey.rawValue,
                    withAccessibility: .whenUnlockedThisDeviceOnly
                )
                if !success {
                    dlog("Error: failed to store \(usernameKey.rawValue) in keychain")
                }
            } else {
                keychainWrapper.remove(forKey: usernameKey)
            }
        }
    }
    
    var password: String? {
        get {
            return keychainWrapper.decode(forKey: passwordKey.rawValue)
        }
        set {
            if let newValue {
                let success = keychainWrapper.encodeAndSet(
                    newValue,
                    forKey: passwordKey.rawValue,
                    withAccessibility: .whenUnlockedThisDeviceOnly
                )
                if !success {
                    dlog("Error: failed to store \(passwordKey.rawValue) in keychain")
                }
            } else {
                keychainWrapper.remove(forKey: passwordKey)
            }
        }
    }
}

private extension KeychainWrapper {
    func decode<T: Decodable>(forKey key: String) -> T? {
        if let object = data(forKey: key) {
            let decoder = JSONDecoder()
            
            if let decodedObject = try? decoder.decode(T.self, from: object) {
                return decodedObject
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func encodeAndSet<T: Encodable>(_ value: T, forKey key: String, withAccessibility accessibility: KeychainItemAccessibility?, isSynchronizable: Bool = false) -> Bool {
        let encoder = JSONEncoder()
        
        if let encoded = try? encoder.encode(value) {
            return set(encoded, forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
        } else {
            return false
        }
    }
}
