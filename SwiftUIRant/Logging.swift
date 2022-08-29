//
//  Logging.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 24.08.22.
//

import Foundation

func dlog(_ message: String) {
    print(message + "\n")
}

func dlog(_ error: Error) {
    dlog("\(error)")
}
