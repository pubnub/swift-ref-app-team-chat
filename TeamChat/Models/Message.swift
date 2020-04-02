//
//  Message.swift
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

import PubNub
import PubNubCSM

// MARK: Base Message

struct Message: MessageEnvelop, Codable, Hashable {

  let conversationId: String
  var timetoken: Timetoken

  var message: MessagePayload

  init(
    conversationId: String,
    timetoken: Timetoken,
    message: MessagePayload
  ) {
    self.conversationId = conversationId
    self.timetoken = timetoken
    self.message = message
  }

  init(channel: String, message: MessagePayload, at timetoken: Timetoken) {
    self.init(
      conversationId: channel,
      timetoken: timetoken,
      message: message
    )
  }
}

// MARK: Message Type Wrapper
/// The Message payload for all messages
///
/// JSON example of Text Message:
/// ```
/// {
///   "text": "Hello and good morning! :D",
///   "type": "text",
///   "sender": "user_a7f0471fb9c64a00af7b3029234cff99"
/// }
/// ```
struct MessagePayload: JSONCodable, Codable, Hashable {
  var content: MessageType
  var senderId: String

  enum CodingKeys: String, CodingKey {
    case senderId
    case type

    case text
  }

  init(content: MessageType, senderId: String) {
    self.content = content
    self.senderId = senderId
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.senderId = try container.decode(String.self, forKey: .senderId)

    let type = try container.decode(MessageType.KeyType.self, forKey: .type)
    switch type {
    case .text:
      let value = try container.decode(String.self, forKey: .text)
      if value.containsOnlyEmoji {
        self.content = .emoji(value)
      } else {
        self.content = .text(value)
      }
    case .emoji:
      let value = try container.decode(String.self, forKey: .text)
      self.content = .emoji(value)
    default:
      let value = try container.decode(AnyJSON.self, forKey: .text)
      self.content = .unknown(value)
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(senderId, forKey: .senderId)

    switch content {
    case .text(let value):
      try container.encode(MessageType.KeyType.text, forKey: .type)
      try container.encode(value, forKey: .text)
    case .emoji(let value):
      try container.encode(MessageType.KeyType.emoji, forKey: .type)
      try container.encode(value, forKey: .text)
    default:
      break
    }
  }
}

// MARK: Message Types

enum MessageType: Hashable, CustomStringConvertible {
  // Message Types
  case text(String)
  case emoji(String)

  case unknown(AnyJSON)

  enum KeyType: String, CaseIterable, Codable {
    case text
    case emoji
    case unknown
  }

  var description: String {
    switch self {
    case .text(let value):
      return value
    case .emoji(let value):
      return value
    case .unknown(let value):
      return value.description
    }
  }

  var keyType: KeyType {
    switch self {
    case .text:
      return .text
    case .emoji:
      return .emoji
    case .unknown:
      return .unknown
    }
  }
}

// MARK: - Extension Helpers

extension Message {
  var channel: String {
    return conversationId
  }

  var senderId: String {
    return message.senderId
  }

  func ofContent(type: MessageType.KeyType) -> Bool {
    return type == message.content.keyType
  }
}

extension Message: Identifiable {
  var id: Timetoken {
    return timetoken
  }
}

extension DateFormatter {
  static let deafultMessage: DateFormatter = {
    var formatter = DateFormatter()
    formatter.dateFormat = "h:mm a"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()

  static let shortDate: DateFormatter = {
    var formatter = DateFormatter()

    formatter.dateFormat = "MMM dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")

    return formatter
  }()
}

extension RelativeDateTimeFormatter {
  static let shared: RelativeDateTimeFormatter = {
    return RelativeDateTimeFormatter()
  }()

  static func daysDiffer(between lhs: Date, and rhs: Date) -> Bool {
    return RelativeDateTimeFormatter.shared.calendar.component(.day, from: lhs) !=
      RelativeDateTimeFormatter.shared.calendar.component(.day, from: rhs)
  }
}
