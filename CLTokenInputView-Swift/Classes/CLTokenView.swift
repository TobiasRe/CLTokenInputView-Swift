//
//  CLTokenView.swift
//  CLTokenInputView
//
//  Created by Dmitry Kurochka on 23.08.17.
//  Copyright © 2017 Prezentor. All rights reserved.
//

import Foundation
import UIKit

protocol CLTokenViewDelegate: class {
  func tokenViewDidRequestDelete(_ tokenView: CLTokenView, replaceWithText replacementText: String?)
  func tokenViewDidRequestSelection(_ tokenView: CLTokenView)
  func tokenViewDidHandeLongPressure(_ tokenView: CLTokenView)
}

class CLTokenView: UIView, UIKeyInput {
  weak var delegate: CLTokenViewDelegate?
  var selected: Bool! {
    didSet {
      if oldValue != selected {
        setSelectedNoCheck(selected, animated: false)
      }
    }
  }
  var hideUnselectedComma: Bool! {
    didSet {
      if oldValue != hideUnselectedComma {
        updateLabelAttributedText()
      }
    }
  }

  var backgroundView: UIView?
  var label: UILabel!
  var selectedBackgroundView: UIView!
  var selectedLabel: UILabel!
  var displayText: String!

  let paddingX = 4.0
  let paddingY = 2.0
  //    let UNSELECTED_LABEL_FORMAT = "%@, "
  //    let UNSELECTED_LABEL_NO_COMMA_FORMAT = "%@"

  init(frame: CGRect, token: CLToken, font: UIFont?) {
    super.init(frame: frame)
    var tintColor: UIColor = UIColor(red: 0.08, green: 0.49, blue: 0.98, alpha: 1.0)
    tintColor = self.tintColor
    label = UILabel(frame: CGRect(x: paddingX, y: paddingY, width: 0.0, height: 0.0))
    if font != nil {
      label.font = font
    }
    label.textColor = tintColor
    label.backgroundColor = UIColor.clear
    addSubview(label)

    selectedBackgroundView = UIView(frame: CGRect.zero)
    selectedBackgroundView.backgroundColor = tintColor
    selectedBackgroundView.layer.cornerRadius = 3.0
    addSubview(selectedBackgroundView)
    selectedBackgroundView.isHidden = true

    selectedLabel = UILabel(frame: CGRect(x: paddingX, y: paddingY, width: 0.0, height: 0.0))
    selectedLabel.font = label.font
    selectedLabel.textColor = UIColor.white
    selectedLabel.backgroundColor = UIColor.clear
    addSubview(selectedLabel)
    selectedLabel.isHidden = true

    selected = false

    displayText = token.displayText
    hideUnselectedComma = false
    updateLabelAttributedText()
    selectedLabel.text = token.displayText

    let tapSelector = #selector(CLTokenView.handleTapGestureRecognizer(_:))
    let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                       action: tapSelector)
    addGestureRecognizer(tapRecognizer)

    let longPressSelector = #selector(handleLongPressGestureRecognizer(_:))
    let longPressRecognizer = UILongPressGestureRecognizer(target: self,
                                                           action: longPressSelector)
    addGestureRecognizer(longPressRecognizer)

    setNeedsLayout()
  }

  convenience init(token: CLToken, font: UIFont?) {
    self.init(frame: CGRect.zero, token: token, font: font)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var intrinsicContentSize: CGSize {
    let labelIntrinsicSize: CGSize = selectedLabel.intrinsicContentSize
    return CGSize(width: Double(labelIntrinsicSize.width)+(2.0*paddingX),
                  height: Double(labelIntrinsicSize.height)+(2.0*paddingY))
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let fittingSize = CGSize(width: Double(size.width)-(2.0*paddingX), height:Double(size.height)-(2.0*paddingY))
    let labelSize = selectedLabel.sizeThatFits(fittingSize)
    return CGSize(width: Double(labelSize.width)+(2.0*paddingX), height:Double(labelSize.height)+(2.0*paddingY))
  }

  override func tintColorDidChange() {
    super.tintColorDidChange()

    label.textColor = tintColor
    selectedBackgroundView.backgroundColor = tintColor
    updateLabelAttributedText()
  }

  func handleTapGestureRecognizer(_ sender: UIGestureRecognizer) {
    delegate?.tokenViewDidRequestSelection(self)
  }

  func handleLongPressGestureRecognizer(_ sender: UIGestureRecognizer) {
    guard sender.state == .began else {return}
    delegate?.tokenViewDidHandeLongPressure(self)
  }

  func setSelected(_ selectedBool: Bool, animated: Bool) {
    if selected == selectedBool {
      return
    }

    selected = selectedBool

    setSelectedNoCheck(selectedBool, animated: animated)
  }

  func setSelectedNoCheck(_ selectedBool: Bool, animated: Bool) {
    if selectedBool == true && !isFirstResponder {
      _ = becomeFirstResponder()
    } else if !selectedBool && isFirstResponder {
      _ = resignFirstResponder()
    }

    var selectedAlpha: CGFloat = 0.0
    if selectedBool == true {
      selectedAlpha = 1.0
    }

    if animated == true {
      if selected == true {
        selectedBackgroundView.alpha = 0.0
        selectedBackgroundView.isHidden = false
        selectedLabel.alpha = 0.0
        selectedLabel.isHidden = false
      }

      UIView.animate(withDuration: 0.25, animations: { [weak self] in
        self?.selectedBackgroundView.alpha = selectedAlpha
        self?.selectedLabel.alpha = selectedAlpha
      }) { [weak self] _ in
        if self?.selected == false {
          self?.selectedBackgroundView.isHidden = true
          self?.selectedLabel.isHidden = true
        }
      }
    } else {
      selectedBackgroundView.isHidden = !selected
      selectedLabel.isHidden = !selected
    }
  }

  func updateLabelAttributedText() {
    var labelString: String

    if hideUnselectedComma == true {
      labelString = "\(displayText ?? "")"
    } else {
      labelString = "\(displayText ?? ""),"
    }

    let attributes: [String:Any] = [NSFontAttributeName: label.font,
         NSForegroundColorAttributeName: UIColor.lightGray]
    let attrString = NSMutableAttributedString(string: labelString, attributes: attributes)

    let tintRange = (labelString as NSString).range(of: displayText)

    attrString.setAttributes([NSForegroundColorAttributeName: tintColor], range: tintRange)
    label.attributedText = attrString
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let bounds: CGRect = self.bounds

    backgroundView?.frame = bounds
    selectedBackgroundView.frame = bounds

    var labelFrame = bounds.insetBy(dx: CGFloat(paddingX), dy: CGFloat(paddingY))
    selectedLabel.frame = labelFrame
    labelFrame.size.width += CGFloat(paddingX * 2.0)
    label.frame = labelFrame
  }

  var hasText: Bool {
    return true
  }

  func insertText(_ text: String) {
    delegate?.tokenViewDidRequestDelete(self, replaceWithText: text)
  }

  func deleteBackward() {
    delegate?.tokenViewDidRequestDelete(self, replaceWithText: nil)
  }

  override var canBecomeFirstResponder: Bool {
    return true
  }

  override func resignFirstResponder() -> Bool {
    let didResignFirstResponder = super.resignFirstResponder()
    setSelected(false, animated: false)
    return didResignFirstResponder
  }

  override func becomeFirstResponder() -> Bool {
    let didBecomeFirstResponder = super.becomeFirstResponder()
    setSelected(true, animated: false)
    return didBecomeFirstResponder
  }

}
