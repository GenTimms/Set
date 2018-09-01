//
//  DealtCardsView.swift
//  set
//
//  Created by Genevieve Timms on 02/02/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import UIKit

class DealtCardsView: UIView {
    
    var cards = [SetCardView]() { didSet { setNeedsLayout() } }
    var dealingCards = [SetCardView]()
    
    lazy private var grid = Grid(layout: Grid.Layout.aspectRatio(LayoutConstants.cardAspectRatio), frame: bounds)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        arrangeCards()
    }

    private func arrangeCards() {
        var cardsToDeal = [SetCardView]()
        
        let boundsChanged = grid.frame != bounds
        grid.frame = bounds
        grid.cellCount = cards.count
        
        for view in subviews {
            if let cardView = view as? SetCardView {
                if !cards.contains(cardView) {
                    view.removeFromSuperview()
                }
            }
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0,
            options: [],
            animations:  {
                for (index, card) in self.cards.enumerated() {
                    if !boundsChanged {
                        guard !self.dealingCards.contains(card) else {
                            continue
                        }
                    }
                    if !self.subviews.contains(card)  {
                        cardsToDeal.append(card)
                        self.dealingCards.append(card)
                        continue
                    }
                    if let frame = self.grid[index] {
                        card.frame = frame.insetBy(dx: LayoutConstants.spacing, dy: LayoutConstants.spacing) }
                }},
            completion: { finished in
                self.dealCards(cardsToDeal)
        })
    }
    
    private func dealCards(_ cardsToDeal: [SetCardView]) {
        for (index, card) in cardsToDeal.enumerated() {
            let timeDelay = 0.4*Double(index)
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.5,
                delay: timeDelay,
                options: [],
                animations:  {
                    if let cardIndex = self.cards.index(of: card), let frame = self.grid[cardIndex] {
                        self.addSubview(card)
                        self.sendSubview(toBack: card)
                        card.transform = .identity
                        card.frame = frame.insetBy(dx: LayoutConstants.spacing, dy: LayoutConstants.spacing)
                        
                    }
            },
                completion: { position in
                    UIView.transition(with: card,
                                      duration: 0.3,
                                      options: .transitionFlipFromLeft,
                                      animations: {
                                        card.isFaceUp = true },
                                      completion: { position in
                                        
                                        if let dealingIndex = self.dealingCards.index(of: card) {
                                            self.dealingCards.remove(at: dealingIndex)
                                        }
                    })
            })
        }
    }
    
    struct LayoutConstants {
        static let spacing: CGFloat = 5.0
        static let cardAspectRatio: CGFloat = 0.7
    }
}
