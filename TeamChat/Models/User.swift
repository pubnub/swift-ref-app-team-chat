//
//  User.swift
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
import ReSwift

public struct User: Identifiable, Hashable, Codable {
  public let id: String
  public var name: String

  public var email: String?
  public var profileURL: String?
  public var externalId: String?

  public var title: String?

  public var created: Date
  public var updated: Date
  public var eTag: String

  public init(
    id: String = UUID().uuidString,
    name: String, title: String?,
    email: String? = nil,
    profileURL: String? = nil,
    externalId: String? = nil,
    created: Date = Date(),
    updated: Date? = nil,
    eTag: String? = nil
  ) {
    self.id = id
    self.name = name
    self.title = title

    self.email = email
    self.profileURL = profileURL
    self.externalId = externalId

    self.created = created
    self.updated = updated ?? created
    self.eTag = eTag ?? id
  }
}

extension User: Comparable {
  public static func < (lhs: User, rhs: User) -> Bool {
    return lhs.name < rhs.name
  }
}

// MARK: PubNubUser

extension User: PubNubUser {
  public init(from user: PubNubUser) {
    self.init(
      id: user.id,
      name: user.name,
      title: user.customValue(for: "title"),
      email: user.email,
      profileURL: user.profileURL,
      externalId: user.externalId,
      created: user.created,
      updated: user.updated,
      eTag: user.eTag
    )
  }

  public var custom: [String: JSONCodableScalar]? {
    guard let title = title else {
      return nil
    }
    return ["title": title]
  }
}

// MARK: View Helpers

extension User {
  var initials: String {
    return name.split(separator: " ").map { $0.first?.uppercased() ?? "" }.joined()
  }
}

// MARK: - Membership

struct UserMembership: Identifiable, Hashable, Codable {
  public let id: String

  public var created: Date
  public var updated: Date
  public var eTag: String

  public init(
    id: String = UUID().uuidString,
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

extension UserMembership: PubNubMembership {
  var spaceId: String {
    return id
  }

  var space: PubNubSpace? {
    get { return nil }
    set { _ = newValue }
  }

  var custom: [String: JSONCodableScalar]? {
    return nil
  }

  init(from membership: PubNubMembership) {
    self.init(
      id: membership.spaceId,
      created: membership.created,
      updated: membership.updated,
      eTag: membership.eTag
    )
  }
}
