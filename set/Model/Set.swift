//
//  set.swift
//  set
//
//  Created by Genevieve Timms on 10/01/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

struct Set {
    
    //MARK: - VARIABLES
    var deck = SetDeck()
    var matchedCards = [SetCard]()
    var dealtCards = [SetCard]()
    var selectedCards = [SetCard]()
    
    var score = 0
    
    var isOver: Bool {
        return deck.isEmpty && findASet(of: dealtCards) == nil
    }
    
    var matchedCardsOnTable: Bool {
        for card in dealtCards {
            if matchedCards.contains(card) {
                return true
            }
        }
        return false
    }
    
    var status: Status = .continuePlay {
        didSet {
            switch status {
            case .matchFound: score += 5
            case .notAMatch: score -= 5
            case .cheated: score -= 5
            case .setMissed: score -= 5
            default: return
            }
        }
    }
    
    private let numberOfInitialDealtCards = 12
    
    init() {
        for _ in 0..<numberOfInitialDealtCards {
            dealtCards.append(deck.draw())
        }
    }
    
    //MARK: - GAME ACTIONS
    //SELECT A NEW CARD
    mutating func chooseCard(at index: Int) {
        let chosenCard = dealtCards[index]
        
        //IGNORE IF MATCHED
        guard !matchedCards.contains(chosenCard) else {
            return
        }
        
        //DESELECT IF < 3
        guard !(selectedCards.contains(chosenCard) && selectedCards.count < 3) else {
            selectedCards.remove(at: selectedCards.index(of: chosenCard)!)
            return
        }
        
        //SELECT CARD
        selectedCards.append(chosenCard)
        assert(selectedCards.count < 5, "Set.chooseCard(at \(index)) \(selectedCards) cards selected at once")
        
        if selectedCards.count == 3 {
            //CHECK FOR MATCH
            if let mismatch = isMismatch(of: selectedCards){
                status = .notAMatch(of: mismatch)
            } else {
                status = .matchFound
                matchCards(selectedCards)
            }
        }
        if selectedCards.count == 4 {
            //DESELECT CARDS
            status = .continuePlay
            selectedCards = [chosenCard]
        }
    }
    
    mutating func dealCards() {
        if !deck.isEmpty {
            status = .continuePlay
            
            if findASet(of: dealtCards) != nil {
                status = .setMissed
            }
            for _ in 1...3 {
                dealtCards.append(deck.draw())
            }
        }
    }
    
    mutating func cheat() {
        if let cards = findASet(of: dealtCards) {
            status = .cheated(noMoreSets: false)

            selectedCards = []
            selectedCards.append(contentsOf: cards)
            
            matchCards(cards)
        }
        else {
            status = .cheated(noMoreSets: true)
        }
    }
    
    mutating func replaceMatchedCards()  {
        for (index, card) in dealtCards.enumerated() {
            
            if matchedCards.contains(card) {
                if !deck.isEmpty {
                    dealtCards[index] = deck.draw()
                    
                } else {
                    for card in matchedCards {
                        if let dealtIndex = dealtCards.index(of: card) {
                            dealtCards.remove(at: dealtIndex)
                        }
                    }
                }
            }
        }
    }
    
    private mutating func matchCards(_ cards: [SetCard]) {
        assert(cards.count == 3, "Set.matchCards \(cards): Must be three cards to match")
        matchedCards.append(contentsOf: cards)
    }
    
    // MARK: - ALGORITHMS
    func findASet(of cards: [SetCard]) -> [SetCard]? {
        
        for (index, firstCard) in cards.enumerated() {
            if matchedCards.contains(firstCard) {
                continue
            }
            
            for secondCard in cards[(index + 1)...] {
                if matchedCards.contains(secondCard) {
                    continue
                }
                
                for thirdCard in cards[(index + 2)...] {
                    if matchedCards.contains(thirdCard) {
                        continue
                    }
                    
                    if isMismatch(of: [firstCard,secondCard,thirdCard]) == nil {
                        return [firstCard, secondCard, thirdCard]
                    }
                }
            }
        }
        return nil
    }
    
    //THREE CARDS ARE A SET
    func isMismatch(of cards: [SetCard]) -> Attribute? {
        if cards.count == 3 {
            if !isAnAttributeSet(of: cards.map({$0.symbol}))   {
                return .symbol
            }
            
            if !isAnAttributeSet(of: cards.map({$0.color}))   {
                return .color
            }
            
            if !isAnAttributeSet(of: cards.map({$0.number}))   {
                return .number
            }
            
            if !isAnAttributeSet(of: cards.map({$0.shading}))  {
                return .shading
            }
        }
        return nil
    }

    func isAnAttributeSet(of attributes: [SetCard.Attribute]) -> Bool {
        return attributes.allElementsMatch || attributes.allElementsDistinct
    }
}

