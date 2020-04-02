//
//  ForEachAround.swift
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

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ForEachAround<Data, ID, Content>: View where
  Data: RandomAccessCollection,
  Data.Index: Hashable,
  ID == Data.Element.ID,
  Content: View,
  Data.Element: Identifiable
{

  public var data: Data
  public var content: (Data.Element?, Data.Element, Data.Element?) -> Content

  public init(_ data: Data, @ViewBuilder content: @escaping (Data.Element?, Data.Element, Data.Element?) -> Content) {
    self.data = data
    self.content = content
  }

  public var body: some View {
    ForEach(data.indices, id: \.self) { index -> Content in
      switch true {
      case self.data.count == 1:
        return self.content(nil, self.data[index], nil)
      case self.data.startIndex == index:
        return self.content(nil, self.data[index], self.data[self.data.index(after: index)])
      case self.data.endIndex == self.data.index(after: index):
        return self.content(self.data[self.data.index(before: index)], self.data[index], nil)
      default:
        return self.content(
          self.data[self.data.index(before: index)],
          self.data[index],
          self.data[self.data.index(after: index)]
        )
      }
    }
  }
}
