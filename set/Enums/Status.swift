//
//  Status.swift
//  set
//
//  Created by Genevieve Timms on 30/01/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

enum Status   {
    case cheated(noMoreSets: Bool)
    case matchFound
    case notAMatch(of: Attribute)
    case continuePlay
    case setMissed
}
