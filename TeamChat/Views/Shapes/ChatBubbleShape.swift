//
//  ChatBubbleShape.swift
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

struct ChatBubble: Shape {

  enum ChatBubbleAlignment {
    case leading
    case trailing
  }

  var alignment: ChatBubbleAlignment

  init(alignment: ChatBubbleAlignment = .leading) {
    self.alignment = alignment
  }

  func path(in rect: CGRect) -> Path {
    switch alignment {
    case .leading:
      return leadingPath(in: rect)
    case .trailing:
      return trailingPath(in: rect)
    }
  }

  func trailingPath(in rect: CGRect) -> Path {
    var path = Path()

    path.move(to: CGPoint(x: rect.width - 22, y: rect.height))

    path.addLine(to: CGPoint(x: 17, y: rect.height))
    path.addCurve(to: CGPoint(x: 0, y: rect.height - 17),
                  control1: CGPoint(x: 7.61, y: rect.height),
                  control2: CGPoint(x: 0, y: rect.height - 7.61))
    path.addLine(to: CGPoint(x: 0, y: 17))

    // Top Trailing Corner
    path.addCurve(to: CGPoint(x: 17, y: 0),
                  control1: CGPoint(x: 0, y: 7.61),
                  control2: CGPoint(x: 7.61, y: 0))
    path.addLine(to: CGPoint(x: rect.width - 21, y: 0))
    path.addCurve(to: CGPoint(x: rect.width - 4, y: 17),
                  control1: CGPoint(x: rect.width - 11.61, y: 0),
                  control2: CGPoint(x: rect.width - 4, y: 7.61))

    // Leading Edge
    path.addLine(to: CGPoint(x: rect.width - 4, y: rect.height - 11))
    path.addCurve(to: CGPoint(x: rect.width, y: rect.height),
                  control1: CGPoint(x: rect.width - 4, y: rect.height - 1),
                  control2: CGPoint(x: rect.width, y: rect.height))

    // Bottom Edge
    path.addLine(to: CGPoint(x: rect.width + 0.05, y: rect.height - 0.01))
    path.addCurve(to: CGPoint(x: rect.width - 22, y: rect.height),
                  control1: CGPoint(x: rect.width - 16, y: rect.height),
                  control2: CGPoint(x: rect.width - 19, y: rect.height))
    return path
  }

  func leadingPath(in rect: CGRect) -> Path {
    var path = Path()

    path.move(to: CGPoint(x: 22, y: rect.height))

    path.addLine(to: CGPoint(x: rect.width - 17, y: rect.height))
    path.addCurve(to: CGPoint(x: rect.width, y: rect.height - 17),
                  control1: CGPoint(x: rect.width - 7.61, y: rect.height),
                  control2: CGPoint(x: rect.width, y: rect.height - 7.61))

    path.addLine(to: CGPoint(x: rect.width, y: 17))
    path.addCurve(to: CGPoint(x: rect.width - 17, y: 0),
                  control1: CGPoint(x: rect.width, y: 7.61),
                  control2: CGPoint(x: rect.width - 7.61, y: 0))

    path.addLine(to: CGPoint(x: 21, y: 0))
    path.addCurve(to: CGPoint(x: 4, y: 17),
                  control1: CGPoint(x: 11.61, y: 0),
                  control2: CGPoint(x: 4, y: 7.61))

    path.addLine(to: CGPoint(x: 4, y: rect.height - 11))
    path.addCurve(to: CGPoint(x: 0, y: rect.height),
                  control1: CGPoint(x: 4, y: rect.height - 1),
                  control2: CGPoint(x: 0, y: rect.height))

    path.addLine(to: CGPoint(x: -0.05, y: rect.height - 0.01))
    path.addCurve(to: CGPoint(x: 22, y: rect.height),
                  control1: CGPoint(x: 16, y: rect.height),
                  control2: CGPoint(x: 19, y: rect.height))

    return path
  }
}

#if DEBUG
// MARK: - Preview

struct ChatBubble_Previews: PreviewProvider {

  static let store = AppStore(AppStore.makePreivewStore)

  static var previews: some View {
    ChatBubble(alignment: .leading)
      .rotation(Angle(degrees: 180))
      .stroke()
      .frame(width: 300, height: 70)
      .previewLayout(.fixed(width: 400, height: 100))
  }
}
#endif
