//
//  Selectors+AppStore.swift
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

import PubNubCSM

// MARK: Auth Selectors

extension AppStore {
  var sender: User? {
    guard let userId = state.auth.userId else {
      return nil
    }
    return state.user.users[userId]
  }

  var senderId: String? {
    return state.auth.userId
  }

  var senderIdOrEmptyString: String {
    return state.auth.userId ?? ""
  }
}

// MARK: Conversation Selectors

extension AppStore {
  var conversationSelector: [Conversation] {
    guard let userId = state.auth.userId else {
      return []
    }

    return state.membership.membershipsByUserId[userId]?
      .compactMap { state.conversation.spaces[$0.id] }
      .filter { $0.id != state.auth.defaultConverstaionId }
      .sorted { Conversation.sortedBy(lhs: $0, rhs: $1) } ?? []
  }

  func modifyMembershipRequest(for conversationIds: [String]) -> MembershipModifyRequest? {
    guard let userId = state.auth.userId,
      let memberships = state.membership.membershipsByUserId[userId]?.filter({ conversationIds.contains($0.id) }) else {
      return nil
    }

    return MembershipModifyRequest(userId: userId, modifiedBy: memberships)
  }

  func senderMembership(for conversationId: String) -> UserMembership? {
    return state.membership.membershipsByUserId[self.senderIdOrEmptyString]?.first { $0.id == conversationId }
  }

  func senderMembershipIds() -> [String]? {
    return state.membership.membershipsByUserId[self.senderIdOrEmptyString]?.map { $0.id }
  }

  var defaultConversation: Conversation? {
    return state.conversation.spaces[state.auth.defaultConverstaionId]
  }

  var initialConversationId: String {
    return state.auth.deepLinkConversationId ?? state.auth.defaultConverstaionId
  }

  var initialConversation: Conversation? {
    return state.conversation.spaces[self.initialConversationId]
  }

  var isConnected: Bool {
    return state.networkStatus.isConnected != .notConnected && state.deviceNetworkStatus.isConnected
  }
}

// MARK: Message Selectors

extension AppStore {
  func messages(for conversationId: String) -> [Message] {
    return state.messages.messagesByChannel[conversationId]?.sorted { $0.timetoken < $1.timetoken } ?? []
  }

  func conversation(by conversationId: String) -> Conversation? {
    return state.conversation.spaces[conversationId]
  }

  func user(by userId: String) -> User? {
    return state.user.users[userId]
  }

  func user(by message: Message) -> User? {
    return state.user.users[message.senderId]
  }
  func memberCount(for conversationId: String) -> Int {
    return state.member.membersBySpaceId[conversationId]?.count ?? 0
  }
  func occupancy(for conversationId: String) -> String {
    return state.presence.presenceByChannelId[conversationId]?.occupancy.description ?? "0"
  }
}

// MARK: User Selectors

extension AppStore {
  func presence(for userId: String, on conversationId: String) -> Bool {
    return self.state.presence.presenceByChannelId[conversationId]?.occupants.keys.contains { $0 == userId } ?? false
  }

  func senderConnectivityOrPresence(for userId: String, on conversationId: String = "") -> Bool {
    if userId == senderIdOrEmptyString {
      return state.networkStatus.isConnected == .connected
    }

    return presence(for: userId, on: conversationId)
  }
}
