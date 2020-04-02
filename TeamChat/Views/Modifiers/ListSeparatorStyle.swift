//
//  ListSeparatorStyleNone.swift
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

public struct ListSeparatorStyleNoneModifier: ViewModifier {
  public func body(content: Content) -> some View {
    content.onAppear {
      UITableView.appearance().separatorStyle = .none
      UITableView.appearance().tableFooterView = UIView()
      UITableView.appearance().tableFooterView?.backgroundColor = .clear
    }.onDisappear {
      UITableView.appearance().separatorStyle = .singleLine
      UITableView.appearance().tableFooterView = nil
    }
  }
}

public struct ListSeparatorStyleSingleModifier: ViewModifier {
  public func body(content: Content) -> some View {
    content.onAppear {
      UITableView.appearance().separatorStyle = .singleLine
    }
  }
}

extension View {
  public func listSeparatorStyleNone() -> some View {
    modifier(ListSeparatorStyleNoneModifier())
  }
  public func listSeparatorStyleSingle() -> some View {
    modifier(ListSeparatorStyleSingleModifier())
  }
}

public struct BottomSafeAreaOffsetPadding: ViewModifier {
  var length: CGFloat

  public func body(content: Content) -> some View {
    GeometryReader { geometry in
      content.padding(.bottom, self.length == 0 ? geometry.safeAreaInsets.bottom : 0)
    }
  }
}

extension View {
  public func bottomSafeAreaOffsetPadding(_ length: CGFloat) -> some View {
    return modifier(BottomSafeAreaOffsetPadding(length: length))
  }
}
