//
//  Card.swift
//  set
//
//  Created by Genevieve Timms on 10/01/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

struct SetCard: Equatable {
    
    static func ==(lhs: SetCard, rhs: SetCard) -> Bool {
        return lhs.color == rhs.color &&
            lhs.number == rhs.number &&
            lhs.shading == rhs.shading &&
            lhs.symbol == rhs.symbol ? true : false
    }
    
    let symbol: Attribute
    let number: Attribute
    let shading: Attribute
    let color: Attribute
    
    enum Attribute: Int {
        case one = 1
        case two = 2
        case three = 3
        
        static var all: [Attribute] {
            var allAttributes = [Attribute]()
            var rawValue = 1
            
            while let attribute = Attribute(rawValue: rawValue) {
                allAttributes.append(attribute)
                rawValue += 1
            }
            return allAttributes
        }
    }
}
