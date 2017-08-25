//
//  CLTokenInputViewDelegate.swift
//  PrezentorMobile
//
//  Created by Dmitry Kurochka on 25.08.17.
//  Copyright © 2017 Prezentor. All rights reserved.
//

import UIKit

protocol CLTokenInputViewDelegate: class {
  func tokenInputViewDidEndEditing(_ aView: CLTokenInputView)
  func tokenInputViewDidBeginEditing(_ aView: CLTokenInputView)
  func tokenInputView(_ aView: CLTokenInputView, didChangeText text: String)
  func tokenInputView(_ aView: CLTokenInputView, didAddToken token: CLToken)
  func tokenInputView(_ aView: CLTokenInputView, didRemoveToken token: CLToken)
  func tokenInputView(_ aView: CLTokenInputView, tokenForText text: String) -> CLToken?
  func tokenInputView(_ aView: CLTokenInputView, didChangeHeightTo height: CGFloat)
  func tokenInputView(_ aView: CLTokenInputView, didSelectToken token: CLToken)
  func tokenInputView(_ aView: CLTokenInputView, didHandleLongPressureForToken token: CLToken, tokenView: CLTokenView)
}
