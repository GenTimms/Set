//
//  SetDeck.swift
//  set
//
//  Created by Genevieve Timms on 17/01/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

struct SetDeck {
    
    private(set) var cards = [SetCard]()
    
    var isEmpty: Bool {
        return cards.isEmpty
    }

init() {
    for symbol in SetCard.Attribute.all {
        for number in SetCard.Attribute.all {
            for shading in SetCard.Attribute.all {
                for color in SetCard.Attribute.all {
                    cards.append(SetCard(symbol: symbol, number: number, shading: shading, color: color))
                }
            }
        }
    }
    cards = cards.shuffled
}
    
    mutating func draw() -> SetCard {
        return cards.removeFirst()
    }
}
