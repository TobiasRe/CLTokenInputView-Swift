//
//  CLTokenInputView.swift
//  CLTokenInputView
//
//  Created by Dmitry Kurochka on 23.08.17.
//  Copyright © 2017 Prezentor. All rights reserved.
//

import UIKit

class CLTokenInputView: UIView {
  weak var delegate: CLTokenInputViewDelegate?
  var fieldLabel: UILabel!
  var fieldView: UIView? {
    willSet {
      if fieldView != newValue {
        fieldView?.removeFromSuperview()
      }
    }

    didSet {
      if oldValue != fieldView {
        if fieldView != nil {
          addSubview(fieldView!)
        }
        repositionViews()
      }
    }
  }
  var fieldName: String? {
    didSet {
      if oldValue != fieldName {
        fieldLabel.text = fieldName
        fieldLabel.sizeToFit()
        let showField: Bool = fieldName!.characters.count > 0
        fieldLabel.isHidden = !showField
        if showField && fieldLabel.superview == nil {
          addSubview(fieldLabel)
        } else if !showField && fieldLabel.superview != nil {
          fieldLabel.removeFromSuperview()
        }

        if oldValue == nil || oldValue != fieldName {
          repositionViews()
        }
      }

    }
  }
  var fieldColor: UIColor? {
    didSet {
      fieldLabel.textColor = fieldColor
    }
  }
  var placeholderText: String? {
    didSet {
      if oldValue != placeholderText {
        updatePlaceholderTextVisibility()
      }
    }
  }
  var accessoryView: UIView? {
    willSet {
      if accessoryView != newValue {
        accessoryView?.removeFromSuperview()
      }
    }

    didSet {
      if oldValue != accessoryView {
        if accessoryView != nil {
          addSubview(accessoryView!)
        }
        repositionViews()
      }
    }
  }
  var keyboardType: UIKeyboardType! {
    didSet {
      textField.keyboardType = keyboardType
    }
  }
  var autocapitalizationType: UITextAutocapitalizationType! {
    didSet {
      textField.autocapitalizationType = autocapitalizationType
    }
  }
  var autocorrectionType: UITextAutocorrectionType! {
    didSet {
      textField.autocorrectionType = autocorrectionType
    }
  }
  var tokenizationCharacters = Set<String>()
  var drawBottomBorder: Bool = false {
    didSet {
      if oldValue != drawBottomBorder {
        setNeedsDisplay()
      }
    }
  }
  var paddingLeft: CGFloat = 0 {
    didSet {
      repositionViews()
    }
  }
  var inputTextFieldTint: UIColor! {
    didSet {
      textField.tintColor = inputTextFieldTint
    }
  }

  var tokens: [CLToken] = []
  var tokenViews: [CLTokenView] = []
  var textField: CLBackspaceDetectingTextField!
  var intrinsicContentHeight: CGFloat!
  var additionalTextFieldYOffset: CGFloat!
  var additionalTokenViewYOffset: CGFloat!

  let hSpace: CGFloat = 0.0
  let textFieldHSpace: CGFloat = 4.0 // Note: Same as CLTokenView.PADDING_X
  let vSpace: CGFloat = 4.0
  let minimumTextFieldWidth: CGFloat = 56.0
  let paddingTop: CGFloat = 10.0
  let paddingBottom: CGFloat = 10.0
  let paddingRight: CGFloat = 16.0
  let standardRowHeight: CGFloat = 24.0
  let fieldMarginX: CGFloat = 4.0

  private func commonInit() {
    textField = CLBackspaceDetectingTextField(frame: bounds)
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.backgroundColor = .clear
    textField.keyboardType = .emailAddress
    textField.autocorrectionType = .no
    textField.autocapitalizationType = .none
    textField.delegate = self
    //additionalTextFieldYOffset = 0.0
    additionalTextFieldYOffset = -2
    additionalTokenViewYOffset = -2
    textField.addTarget(self, action: #selector(CLTokenInputView.onTextFieldDidChange(_:)), for: .editingChanged)
    addSubview(textField)

    fieldLabel = UILabel(frame: CGRect.zero)
    fieldLabel.translatesAutoresizingMaskIntoConstraints = false
    fieldLabel.font = textField.font
    fieldLabel.textColor = fieldColor
    addSubview(fieldLabel)
    fieldLabel.isHidden = true

    fieldColor = .lightGray

    intrinsicContentHeight = standardRowHeight
    repositionViews()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIViewNoIntrinsicMetric, height: max(45, intrinsicContentHeight))
  }

  override func tintColorDidChange() {
    tokenViews.forEach { $0.tintColor = tintColor }
  }

  func addToken(_ token: CLToken) {
    guard !tokens.contains(token) else { return }

    tokens.append(token)

    let tokenView: CLTokenView = CLTokenView(token: token, font: textField.font)
    tokenView.translatesAutoresizingMaskIntoConstraints = false
    tokenView.tintColor = tintColor
    tokenView.delegate = self

    let intrinsicSize: CGSize = tokenView.intrinsicContentSize
    tokenView.frame = CGRect(x: 0.0, y: 0.0, width: intrinsicSize.width, height: intrinsicSize.height)
    tokenViews.append(tokenView)
    addSubview(tokenView)
    textField.text = ""
    delegate?.tokenInputView(self, didAddToken: token)
    onTextFieldDidChange(textField)

    updatePlaceholderTextVisibility()
    repositionViews()

  }

  func removeTokenAtIndex(_ index: Int) {
    guard index != -1 else { return }
    let tokenView = tokenViews[index]
    tokenView.removeFromSuperview()
    tokenViews.remove(at: index)
    let removedToken = tokens[index]
    tokens.remove(at: index)
    delegate?.tokenInputView(self, didRemoveToken: removedToken)
    updatePlaceholderTextVisibility()
    repositionViews()
  }

  func removeToken(_ token: CLToken) {
    if let index = tokens.index(of: token) {
      removeTokenAtIndex(index)
    }
  }

  var allTokens: [CLToken] {
    return Array(tokens)
  }

  func tokenizeTextfieldText() -> CLToken? {
    //print("tokenizeTextfieldText()")
    var token: CLToken? = nil

    if let text = textField.text, !text.isEmpty {
      token = delegate?.tokenInputView(self, tokenForText: text)
      if token != nil {
        addToken(token!)
        textField.text = ""
        onTextFieldDidChange(textField)
      }
    }
    return token
  }

  fileprivate func repositionViews() {
    let bounds: CGRect = self.bounds
    let rightBoundary: CGFloat = bounds.width - paddingRight
    var firstLineRightBoundary: CGFloat = rightBoundary
    var curX: CGFloat = paddingLeft//PADDING_LEFT
    var curY: CGFloat = paddingTop
    var totalHeight: CGFloat = standardRowHeight
    var isOnFirstLine: Bool = true

    // print("repositionViews curX=\(curX) curY=\(curY)")

    //print("frame=\(frame)")

    // Position field view (if set)
    if fieldView != nil {
      var fieldViewRect: CGRect = fieldView!.frame
      fieldViewRect.origin.x = curX + fieldMarginX
      fieldViewRect.origin.y = curY + ((standardRowHeight - fieldViewRect.height / 2.0)) - paddingTop
      fieldView?.frame = fieldViewRect

      curX = fieldViewRect.maxX + fieldMarginX
      // print("fieldViewRect=\(fieldViewRect)")
    }

    // Position field label (if field name is set)
    if !(fieldLabel.isHidden) {
      var fieldLabelRect: CGRect = fieldLabel.frame
      fieldLabelRect.origin.x = curX + fieldMarginX
      //+ ((standardRowHeight - CGRectGetHeight(fieldLabelRect) / 2.0)) - paddingTop
      fieldLabelRect.origin.y = curY

      fieldLabel.frame = fieldLabelRect

      curX = fieldLabelRect.maxX + fieldMarginX
      //print("fieldLabelRect=\(fieldLabelRect)")
    }

    // Position accessory view (if set)
    if accessoryView != nil {
      var accessoryRect: CGRect = accessoryView!.frame
      accessoryRect.origin.x = bounds.width - paddingRight - accessoryRect.width
      accessoryRect.origin.y = curY
      accessoryView!.frame = accessoryRect

      firstLineRightBoundary = accessoryRect.minX - hSpace
    }

    // Position token views
    var tokenRect: CGRect = CGRect.null
    for tokenView: CLTokenView in tokenViews {
      tokenRect = tokenView.frame

      let tokenBoundary: CGFloat = isOnFirstLine ? firstLineRightBoundary : rightBoundary
      if curX + tokenRect.width > tokenBoundary {
        // Need a new line
        curX = paddingLeft
        curY += standardRowHeight + vSpace
        totalHeight += standardRowHeight
        isOnFirstLine = false
      }

      tokenRect.origin.x = curX
      // Center our tokenView vertically within standardRowHeight
      // + ((standardRowHeight - CGRectGetHeight(tokenRect)) / 2.0) + additionalTokenViewYOffset
      tokenRect.origin.y = curY + additionalTokenViewYOffset
      tokenView.frame = tokenRect

      curX = tokenRect.maxX + hSpace
    }

    // Always indent textfield by a little bit
    curX += textFieldHSpace
    let textBoundary: CGFloat = isOnFirstLine ? firstLineRightBoundary : rightBoundary
    var availableWidthForTextField: CGFloat = textBoundary - curX
    if availableWidthForTextField < minimumTextFieldWidth ||
      availableWidthForTextField < textField.intrinsicContentSize.width + 5 {
      isOnFirstLine = false
      curX = paddingLeft + textFieldHSpace
      curY += standardRowHeight + vSpace
      totalHeight += standardRowHeight
      // Adjust the width
      availableWidthForTextField = rightBoundary - curX
    }

    var textFieldRect: CGRect = textField.frame
    textFieldRect.origin.x = curX
    textFieldRect.origin.y = curY + additionalTextFieldYOffset
    textFieldRect.size.width = availableWidthForTextField
    textFieldRect.size.height = standardRowHeight
    textField.frame = textFieldRect

    let oldContentHeight: CGFloat = intrinsicContentHeight
    intrinsicContentHeight = textFieldRect.maxY+paddingBottom
    invalidateIntrinsicContentSize()

    if oldContentHeight != intrinsicContentHeight {
      delegate?.tokenInputView(self, didChangeHeightTo: intrinsicContentSize.height)
    }
    setNeedsDisplay()
  }

  func updatePlaceholderTextVisibility() {
    textField.placeholder = tokens.count > 0 ? nil : placeholderText
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    repositionViews()
  }

  var textFieldDisplayOffset: CGFloat {
    return textField.frame.minY - paddingTop
  }

  var text: String? {
    return textField.text
  }

  func selectTokenView(_ tokenView: CLTokenView, animated aBool: Bool) {
    tokenView.setSelected(true, animated: aBool)
    for otherTokenView: CLTokenView in tokenViews where otherTokenView != tokenView {
      otherTokenView.setSelected(false, animated: aBool)
    }
  }

  func unselectAllTokenViewsAnimated(_ animated: Bool) {
    for tokenView: CLTokenView in tokenViews {
      tokenView.setSelected(false, animated: animated)
    }
  }

  var isEditing: Bool {
    return textField.isEditing
  }

  func beginEditing() {
    textField.becomeFirstResponder()
    unselectAllTokenViewsAnimated(false)
  }

  func endEditing() {
    textField.resignFirstResponder()
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    if drawBottomBorder {
      let context: CGContext? = UIGraphicsGetCurrentContext()
      context?.setStrokeColor(UIColor.lightGray.cgColor)
      context?.setLineWidth(0.5)

      context?.move(to: CGPoint(x: bounds.width, y: bounds.size.height))
      context?.addLine(to: CGPoint(x: bounds.width, y: bounds.size.height))
      context?.strokePath()
    }
  }
}

// MARK: CLBackspaceDetectingTextFieldDelegate
extension CLTokenInputView: CLBackspaceDetectingTextFieldDelegate {

  func textFieldDidDeleteBackwards(_ textField: UITextField) {
    DispatchQueue.main.async { [weak self] in
      if textField.text?.isEmpty == true, let tokenView = self?.tokenViews.last {
        self?.selectTokenView(tokenView, animated: true)
        self?.textField.resignFirstResponder()
      }
    }
  }

  func textFieldDidBeginEditing(_ textField: UITextField) {
    delegate?.tokenInputViewDidBeginEditing(self)

    tokenViews.last?.hideUnselectedComma = false
    unselectAllTokenViewsAnimated(true)
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    delegate?.tokenInputViewDidEndEditing(self)
    tokenViews.last?.hideUnselectedComma = true
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    _ = tokenizeTextfieldText()
    return false
  }

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    if !string.isEmpty, tokenizationCharacters.contains(string) {
      _ = tokenizeTextfieldText()
      return false
    }
    repositionViews()
    return true
  }

  func onTextFieldDidChange(_ sender: UITextField) {
    delegate?.tokenInputView(self, didChangeText: textField.text!)
  }
}

extension CLTokenInputView: CLTokenViewDelegate {

  func tokenViewDidHandeLongPressure(_ tokenView: CLTokenView) {
    if let index = tokenViews.index(of: tokenView), index < tokens.count {
      delegate?.tokenInputView(self, didHandleLongPressureForToken: tokens[index], tokenView: tokenView)
    }
  }

  func tokenViewDidRequestDelete(_ tokenView: CLTokenView, replaceWithText replacementText: String?) {
    textField.becomeFirstResponder()
    if replacementText?.isEmpty == false {
      textField.text = replacementText
    }
    if let index = tokenViews.index(of: tokenView) {
      removeTokenAtIndex(index)
    }
  }

  func tokenViewDidRequestSelection(_ tokenView: CLTokenView) {
    if tokenView.selected == true,
      let index = tokenViews.index(of: tokenView),
      index < tokens.count {
      delegate?.tokenInputView(self, didSelectToken: tokens[index])
    }
    selectTokenView(tokenView, animated:true)
  }
}
