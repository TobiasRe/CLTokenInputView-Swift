//
//  CLBackspaceDetectingTextField.swift
//  CLTokenInputView
//
//  Created by Dmitry Kurochka on 23.08.17.
//  Copyright © 2017 Prezentor. All rights reserved.
//

import UIKit

protocol CLBackspaceDetectingTextFieldDelegate: UITextFieldDelegate {
  func textFieldDidDeleteBackwards(_ textField: UITextField)
}

class CLBackspaceDetectingTextField: UITextField {

  var myDelegate: CLBackspaceDetectingTextFieldDelegate? {
    get { return delegate as? CLBackspaceDetectingTextFieldDelegate }
    set { delegate = newValue }
  }

  override func deleteBackward() {
    if text?.isEmpty ?? false {
      textFieldDidDeleteBackwards(self)
    }
    super.deleteBackward()
  }

  private func textFieldDidDeleteBackwards(_ textField: UITextField) {
    myDelegate?.textFieldDidDeleteBackwards(textField)
  }
}
