//
//  CLToken.swift
//  CLTokenInputView
//
//  Created by Dmitry Kurochka on 23.08.17.
//  Copyright © 2017 Prezentor. All rights reserved.
//

import Foundation

struct CLToken {
  let displayText: String
  let context: AnyObject?
}

extension CLToken: Equatable {
  static func == (lhs: CLToken, rhs: CLToken) -> Bool {
    if lhs.displayText == rhs.displayText, lhs.context?.isEqual(rhs.context) == true {
      return true
    }
    return false
  }
}
