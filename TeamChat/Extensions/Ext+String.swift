//
//  Ext+String.swift
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

extension Character {
  /// A simple emoji is one scalar and presented to the user as an Emoji
  var isSimpleEmoji: Bool {
    guard let firstProperties = unicodeScalars.first?.properties else {
        return false
    }
    return unicodeScalars.count == 1 &&
        (firstProperties.isEmojiPresentation ||
            firstProperties.generalCategory == .otherSymbol)
  }

  /// Checks if the scalars will be merged into an emoji
  var isCombinedIntoEmoji: Bool {
    return (unicodeScalars.count > 1 &&
           unicodeScalars.contains { $0.properties.isJoinControl || $0.properties.isVariationSelector })
        || unicodeScalars.allSatisfy({ $0.properties.isEmojiPresentation })
  }

  var isEmoji: Bool {
    return isSimpleEmoji || isCombinedIntoEmoji
  }
}

extension String {
  var containsOnlyEmoji: Bool {
    return !isEmpty && !contains { !$0.isEmoji }
  }
}
