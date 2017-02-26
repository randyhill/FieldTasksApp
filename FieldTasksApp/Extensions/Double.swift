//
//  Double.swift
//  FieldTasksApp
//
//  Created by CRH on 2/15/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import Foundation

extension Double {
    // Convert to int without crashing or returning optional
    func toInt() -> Int {
        if self < Double(Int.min) {
            return Int.min
        }
        if self > Double(Int.max) {
            return Int.max
        }
        return Int(self)
    }
}
