//
//  KeyboardNotificationHandler.swift
//
//  PubNub Real-time Cloud-Hosted Push API and Push Notification Client Frameworks
//  Copyright © 2020 PubNub Inc.
//  https://www.pubnub.com/
//  https://www.pubnub.com/terms
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import SwiftUI

final class KeyboardNotificationHandler: ObservableObject {
  private var notificationCenter: NotificationCenter
  @Published var currentHeight: CGFloat = 0

  init(center: NotificationCenter = .default) {
    notificationCenter = center

    notificationCenter.addObserver(
      self,
      selector: #selector(keyBoardWillShow(notification:)),
      name: UIResponder.keyboardWillShowNotification, object: nil
    )

    notificationCenter.addObserver(
      self,
      selector: #selector(keyBoardWillHide(notification:)),
      name: UIResponder.keyboardWillHideNotification, object: nil
    )
  }

  deinit {
    notificationCenter.removeObserver(self)
  }

  @objc func keyBoardWillShow(notification: Notification) {
    if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {

      // curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
      guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
        currentHeight = keyboardSize.height
        return
      }

      withAnimation(.easeInOut(duration: duration)) {
        currentHeight = keyboardSize.height
      }
    }
  }

  @objc func keyBoardWillHide(notification: Notification) {
    guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
      currentHeight = 0
      return
    }

    withAnimation(.easeInOut(duration: duration)) {
      currentHeight = 0
    }
  }
}
