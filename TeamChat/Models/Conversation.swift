//
//  Conversation.swift
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

public struct Conversation: Identifiable, Hashable, Codable {
  public let id: String
  public var name: String

  public var purpose: String?

  public var created: Date
  public var updated: Date
  public var eTag: String

  public init(
    id: String = UUID().uuidString,
    name: String,
    purpose: String? = nil,
    created: Date = Date(),
    updated: Date? = nil,
    eTag: String? = nil
  ) {
    self.id = id
    self.name = name
    self.purpose = purpose
    self.created = created
    self.updated = updated ?? created
    self.eTag = eTag ?? id
  }
}

extension Conversation: Comparable {
  public static func < (lhs: Conversation, rhs: Conversation) -> Bool {
    return lhs.name < rhs.name
  }
}

extension Conversation {
  static func sortedBy(
    name: String = "Introductions",
    descending: Bool = true,
    lhs: Conversation,
    rhs: Conversation
  ) -> Bool {
    if lhs.name == name {
      return true
    } else if rhs.name == name {
      return false
    }

    return (lhs.name < rhs.name) && descending
  }
}

extension Conversation: PubNubSpace {
  public init(from space: PubNubSpace) {
    self.init(
      id: space.id,
      name: space.name,
      purpose: space.spaceDescription,
      created: space.created,
      updated: space.updated,
      eTag: space.eTag
    )
  }

  public var spaceDescription: String? {
    return purpose
  }

  public var custom: [String: JSONCodableScalar]? {
    return nil
  }
}

// MARK: - Member

struct ConversationMember: Identifiable, Hashable, Codable {
  public let id: String

  public var created: Date
  public var updated: Date
  public var eTag: String

  public init(
    id: String,
    isFavorite: Bool = false,
    created: Date = Date(),
    updated: Date? = nil,
    eTag: String? = nil
  ) {
    self.id = id
    self.created = created
    self.updated = updated ?? created
    self.eTag = eTag ?? id
  }
}

// MARK: PubNub

extension ConversationMember: PubNubMember {
  var userId: String {
    return id
  }

  var user: PubNubUser? {
    get { return nil }
    set { _ = newValue }
  }

  var custom: [String: JSONCodableScalar]? {
    return nil
  }

  init(from membership: PubNubMember) throws {
    self.init(
      id: membership.userId,
      created: membership.created,
      updated: membership.updated,
      eTag: membership.eTag
    )
  }
}
