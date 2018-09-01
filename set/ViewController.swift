//
//  ViewController.swift
//  set
//
//  Created by Genevieve Timms on 10/01/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIDynamicAnimatorDelegate {
    
    //MARK: - MODEL
    private var game = Set()
    
    //MARK: - VIEWS
    private var cards = [SetCardView]()
    lazy var setDeckView = createDeckView(matched: false)
    lazy var matchedDeckView = createDeckView(matched: true)
    
    func createDeckView(matched isMatched: Bool) -> DeckView {
        let deckView = DeckView()
        deckView.backgroundColor = UIColor.white
        deckView.clipsToBounds = false
        
        if isMatched {
            deckView.label.text = "0 Sets"
            deckView.frame = CGRect(origin: leftDeckOrigin, size: deckViewSize)
            deckView.transform = CGAffineTransform.identity.rotated(by: deckViewAngle)
        } else {
            deckView.label.text = "Deck"
            deckView.frame = CGRect(origin: rightDeckOrigin, size: deckViewSize)
            deckView.transform = CGAffineTransform.identity.rotated(by: 2*CGFloat.pi-deckViewAngle)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(dealInitiated))
            deckView.addGestureRecognizer(tap)
        }
        view.addSubview(deckView)
        return deckView
    }
    
    @IBOutlet weak var dealtSetCardsView: DealtCardsView! {
        didSet {
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dealInitiated))
            swipeDown.direction = .down
            dealtSetCardsView.addGestureRecognizer(swipeDown)
            
            let rotation = UIRotationGestureRecognizer(target: self, action: #selector(shuffleCards(recognizer:)))
            dealtSetCardsView.addGestureRecognizer(rotation)
            
            dealtSetCardsView.clipsToBounds = false
            dealtSetCardsView.contentMode = .redraw
        }}
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var cheatButton: UIButton!
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        positionDeckViews()
        
        if cards.isEmpty {
            updateUIFromModel()
        }
    }
    
    private func positionDeckViews() {
        matchedDeckView.transform = .identity
        setDeckView.transform = .identity
        
        setDeckView.frame = CGRect(origin: rightDeckOrigin, size: deckViewSize)
        matchedDeckView.frame = CGRect(origin: leftDeckOrigin, size: deckViewSize)
        
        matchedDeckView.transform = CGAffineTransform.identity.rotated(by: deckViewAngle)
        setDeckView.transform = CGAffineTransform.identity.rotated(by: 2*CGFloat.pi-deckViewAngle)
        view.sendSubview(toBack: matchedDeckView)
        view.sendSubview(toBack: setDeckView)
    }
    
    //MARK: - ACTIONS
    @objc func touchCard(recognizer: UIGestureRecognizer) {
        if let cardTapped = recognizer.view as? SetCardView {
            if let index = cards.index(of: cardTapped), index < game.dealtCards.count {
                game.chooseCard(at: index)
                updateUIFromModel()
            }
        }
    }
    
    @objc @IBAction func dealInitiated() {
        guard dealtSetCardsView.dealingCards.isEmpty else {
            return
        }
        game.dealCards()
        updateUIFromModel()
    }
    
    @IBAction func cheatButtonPressed(_ sender: UIButton) {
        if dealtSetCardsView.dealingCards.isEmpty {
            game.cheat()
            updateUIFromModel()
        }
    }
    
    @objc func shuffleCards(recognizer: UIRotationGestureRecognizer) {
        if dealtSetCardsView.dealingCards.isEmpty {
            switch recognizer.state {
            case .ended:
                game.dealtCards = game.dealtCards.shuffled
                updateUIFromModel()
            default: break
            }
        }
    }
    
    @IBAction func startNewGame(_ sender: UIButton) {
        newGame()
    }
    
    private func newGame() {
        game = Set()
        cards = []
        matchedDeckView.backColor = UIColor.black
        matchedDeckView.label.text = "0 Sets"
        setDeckView.isHidden = false
        
        for view in view.subviews {
            if let card = view as? SetCardView {
                card.removeFromSuperview()
            }
        }
        updateUIFromModel()
    }
    
    //MARK: - UPDATE UI FROM MODEL
    func getCardViewForSetCard(_ card: SetCard) -> SetCardView {
        
        let setCard = SetCardView(shape: Shape(rawValue: card.symbol.rawValue)!,
                                  color: colors[card.color.rawValue - 1],
                                  shading: Shading(rawValue: card.shading.rawValue)!,
                                  number: card.number.rawValue)
 
        let viewForCard = cards.filter{ $0.shape == setCard.shape && $0.color == setCard.color && $0.shading == setCard.shading && $0.number == setCard.number }
        if !viewForCard.isEmpty {
            return viewForCard[0]
        } else {
            setCard.frame = view.convert(CGRect(origin: rightDeckOrigin, size: deckViewSize), to: dealtSetCardsView)
            setCard.transform = CGAffineTransform.identity.rotated(by: 2*CGFloat.pi-deckViewAngle)
            setCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchCard(recognizer:))))
            return setCard
        }
    }

    func updateUIFromModel() {
        //MARK: CARD VIEWS
        var newCards = [SetCardView]()
        let matchedCardViews = game.dealtCards.filter{game.matchedCards.contains($0)}.map{ getCardViewForSetCard($0) }
        
        if !matchedCardViews.isEmpty {
            flyAway(cards: matchedCardViews)
            game.replaceMatchedCards()
            cheatButton.isEnabled = true
        }
        
        for card in game.dealtCards {
            let setCard = getCardViewForSetCard(card)
            setCard.borderWidth = game.matchedCards.contains(card) ? 5 : game.selectedCards.contains(card) ? 3 : 1
            newCards.append(setCard)
        }
        
        cards = newCards
        dealtSetCardsView.cards = cards
    
        //MARK: GAME STATE
        switch game.status {
        case .cheated(let noMoreSets): statusLabel.text = "Cheater!! 😬"; cheatButton.isEnabled = !noMoreSets;
        case .matchFound: statusLabel.text = "Match!! 😀";
        case .notAMatch(let attribute): statusLabel.text = "\(attribute.rawValue)s 🙁"
        case .setMissed: statusLabel.text = "Missed a set! 😟"; cheatButton.isEnabled = true
        case .continuePlay: statusLabel.text = "Find a set"; cheatButton.isEnabled = true
        }
        
        //MARK: DECKVIEW
        //Wait a second for first card to deal if dealing
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: {  [unowned self] timer in
            if self.game.deck.isEmpty {
                self.setDeckView.isHidden = true
            } else {
                self.setDeckView.backColor = self.colors[self.game.deck.cards[0].color.rawValue - 1];
                self.setDeckView.label.text = "\(self.game.deck.cards.count) Cards" }})
        
        
        //MARK: GAME OVER
        if game.isOver {
            statusLabel.text = "Game Over!"
            cheatButton.isEnabled = false
        }
        
        //MARK: SCORE
        scoreLabel.text = (String(game.score))
    }
    
    //MARK: -  ANIMATION
    lazy var animator = UIDynamicAnimator(referenceView: view)
    lazy var flyawayBehavior = FlyawayBehavior(in: animator)
    private var flyingCards = [SetCardView]()
    
    func flyAway(cards: [SetCardView]) {
        
        for card in cards {
            view.addSubview(card)
            card.frame = view.convert(card.frame, from: dealtSetCardsView)
            flyawayBehavior.addItem(card)
            flyingCards.append(card)
        }
        
        Timer.scheduledTimer(withTimeInterval: 1,
                             repeats: false,
                             block: { timer in
                                cards.forEach {
                                    self.flyawayBehavior.removeItem($0)
                                    self.addSnapBehavior(item: $0)
                                    UIViewPropertyAnimator.runningPropertyAnimator(
                                        withDuration: 0.1,
                                        delay: 0,
                                        options: [],
                                        animations: {
                                            cards.forEach{
                                                $0.bounds.size = self.deckViewSize
                                            }},
                                        completion: nil)
                                }
        })
    }
    
    func addSnapBehavior(item: UIDynamicItem) {
        let snap = UISnapBehavior(item: item, snapTo: matchedDeckView.center)
        snap.damping = 0.5
        snap.action = { [unowned self] in
            item.transform = CGAffineTransform.identity.rotated(by: self.deckViewAngle)
        }
        animator.addBehavior(snap)
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        if let finalCard = flyingCards.last {
            UIView.transition(with: finalCard,
                              duration: 0.6,
                              options: .transitionFlipFromTop,
                              animations: {
                                finalCard.isFaceUp = false
            },
                              completion: { position in
                                self.matchedDeckView.backColor = finalCard.color
                                self.matchedDeckView.label.text = "\(self.game.matchedCards.count/3) Sets"
                                for card in self.flyingCards {
                                    self.flyawayBehavior.removeItem(card)
                                    card.isHidden = true
                                }
                                animator.removeAllBehaviors()
                                animator.addBehavior(self.flyawayBehavior)
                                self.flyingCards = []
            })
        }
    }
    
    //MARK: - STATICS
    private let colors = [UIColor.blue, #colorLiteral(red: 0.2174585164, green: 0.8184141517, blue: 0, alpha: 1), UIColor.red]
    
    //MARK: GEOMETRY
    private let deckViewHeight: CGFloat = 160
    private let deckViewAngle: CGFloat = CGFloat.pi/4.6
    private let deckViewYOffset: CGFloat = 5
    
    private var deckViewWidth: CGFloat {
        return deckViewHeight*DealtCardsView.LayoutConstants.cardAspectRatio
    }
    private var deckViewSize: CGSize {
        return CGSize(width: deckViewWidth, height: deckViewHeight)
    }
    private var leftDeckOrigin: CGPoint {
        return CGPoint(x: (0 - deckViewWidth/2), y: (view.bounds.height - deckViewHeight/2) + deckViewYOffset)
    }
    private var rightDeckOrigin: CGPoint {
        return CGPoint(x: (view.bounds.width - deckViewWidth/2), y: (view.bounds.height - deckViewHeight/2) + deckViewYOffset)
    }
}
