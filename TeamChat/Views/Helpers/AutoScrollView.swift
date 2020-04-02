//
//  AutoScrollView.swift
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

struct AutoScrollView<Content>: View where Content: View {
  var reversed: Bool
  var scrollToEnd: Bool
  var didScroll: ((CGFloat, CGFloat) -> Void)?
  var content: () -> Content

  @State private var contentHeight: CGFloat = .zero
  @State private var contentOffset: CGFloat = .zero
  @State private var scrollOffset: CGFloat = .zero

  init(
    reversed: Bool = false,
    scrollToEnd: Bool = true,
    didScroll: ((CGFloat, CGFloat) -> Void)? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.reversed = reversed
    self.scrollToEnd = scrollToEnd
    self.didScroll = didScroll
    self.content = content
  }

  var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .leading, spacing: 0) {
        self.content()
      }
      .modifier(ViewHeightKey())
      .onPreferenceChange(ViewHeightKey.self) {
        self.updateHeight(with: $0, outerHeight: geometry.size.height)
      }
      .frame(width: geometry.size.width,
             height: geometry.size.height,
             alignment: (self.reversed ? .bottom : .top)
      )
      .offset(y: self.contentOffset + self.scrollOffset)
      .animation(.easeInOut)
      .gesture(DragGesture()
        .onChanged { self.onDragChanged($0) }
        .onEnded { self.onDragEnded($0, outerHeight: geometry.size.height) }
      )
    }.clipped()
  }

  private func onDragChanged(_ value: DragGesture.Value) {
    self.scrollOffset = value.location.y - value.startLocation.y
  }

  private func onDragEnded(_ value: DragGesture.Value, outerHeight: CGFloat) {
    let scrollOffset = value.predictedEndLocation.y - value.startLocation.y

    self.updateOffset(with: scrollOffset, outerHeight: outerHeight)
    self.scrollOffset = 0
  }

  private func updateHeight(with height: CGFloat, outerHeight: CGFloat) {
    let delta = self.contentHeight - height
    self.contentHeight = height
    if scrollToEnd {
      self.contentOffset = self.reversed ? height - outerHeight - delta : outerHeight - height
    }
    if self.contentOffset.magnitude > .zero {
      self.updateOffset(with: delta, outerHeight: outerHeight)
    }
  }

  private func updateOffset(with delta: CGFloat, outerHeight: CGFloat) {
    let topLimit = self.contentHeight - outerHeight

    if topLimit < .zero {
      self.contentOffset = .zero
    } else {
      var proposedOffset = self.contentOffset + delta
      if (self.reversed ? proposedOffset : -proposedOffset) < .zero {
        proposedOffset = .zero
      } else if (self.reversed ? proposedOffset : -proposedOffset) > topLimit {
        proposedOffset = (self.reversed ? topLimit : -topLimit)
      }
      self.contentOffset = proposedOffset
    }

    self.didScroll?(self.contentHeight, outerHeight)
  }
}
