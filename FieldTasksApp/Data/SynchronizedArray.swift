//
//  SynchronizedArray.swift
//  FieldTasksApp
//                  
//  This was taken from some sample StackOverflow code
//    http://stackoverflow.com/questions/28191079/create-thread-safe-array-in-swift
//
//  to fix problems when locations controller was trying to access locations list while it was being rebuilt from server refresh.
//  this particular implementaiton may still have issues with removeAtIndex, if called from seperatet threads? according to SO comment.
//  ATM we don't use removeAtIndex so not our problem. The Collection implementation is mine.
//
//  Created by CRH on 2/22/17.
//  Copyright © 2017 CRH. All rights reserved.
//

import Foundation

public class SynchronizedArray<T> : Collection {
    private var array: [T] = []
    private let accessQueue = DispatchQueue(label: "SynchronizedArrayAccess", attributes: .concurrent)

    var iteration: Int = 0
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return array.count - 1}
    public func index(after: Int) -> Int {
        return after + 1
    }

    public func append(newElement: T) {

        self.accessQueue.async(flags:.barrier) {
            self.array.append(newElement)
        }
    }

    public func removeAtIndex(index: Int) {
        self.accessQueue.async(flags:.barrier) {
            self.array.remove(at: index)
        }
    }

    public func removeAll() {
        self.accessQueue.async(flags:.barrier) {
            self.array.removeAll()
        }
    }

    public func replace(newArray: [T] ) {
        self.accessQueue.async(flags:.barrier) {
            self.array = newArray
        }
    }

    public var count: Int {
        var count = 0

        self.accessQueue.sync {
            count = self.array.count
        }

        return count
    }

    public func first() -> T? {
        var element: T?

        self.accessQueue.sync {
            if !self.array.isEmpty {
                element = self.array[0]
            }
        }

        return element
    }

    public subscript(index: Int) -> T {
        set {
            self.accessQueue.async(flags:.barrier) {
                self.array[index] = newValue
            }
        }
        get {
            var element: T!
            self.accessQueue.sync {
                element = self.array[index]
            }
            
            return element
        }
    }
}
