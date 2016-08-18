//
//  CollectionType+shuffle.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 18.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

extension MutableCollectionType where Index == Int {

    mutating func shuffleInPlace() {
        if count < 2 {
            return
        }

        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else {
                continue
            }
            swap(&self[i], &self[j])
        }
    }
    
}

extension CollectionType {

    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }

}
