//
//  PreviewAppStore.swift
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

#if DEBUG
import Foundation

import PubNubCSM
import PubNub
import ReSwift

extension AppStore {
  static var makePreivewStore: Store<AppState> {
    let store = Store<AppState>(
      reducer: AppReducer.reducer,
      state: AppState(),
      middleware: [ThunkAction.getMiddleware, loggingMiddleware]
    )

    let mockSender = User(name: "Sender LastName", title: "Software Engineer")
    let otherUser = User(name: "Swifty Dev", title: "Some really long title that doesn't actually exist")

    let mockConversation = Conversation(
      id: "test", name: "Test Room",
      purpose: "Test purpose for the test room.\nAnother line of text?")
    let defaultConversation = Conversation(
      id: "space_ac4e67b98b34b44c4a39466e93e", name: "Default Room",
      purpose: "It's the default room")
    let swiftUIConversation = Conversation(
      id: "swiftUI", name: "SwiftUI",
      purpose: "Discuss SwiftUI and all it's pros and cons")
    let boardGamesConversation = Conversation(
      id: "boardGames", name: "Board Games",
      purpose: "Tabletop gaming is the best!")
    let programmingConversation = Conversation(id: "programming", name: "Programming", purpose: "if worthIt else cry")

    let senderkMember = ConversationMember(id: mockSender.id)
    let otherMember = ConversationMember(id: otherUser.id)

    let testMembership = UserMembership(id: mockConversation.id)
    let deafaultMembership = UserMembership(id: defaultConversation.id)
    let swiftUIMembership = UserMembership(id: swiftUIConversation.id)

    let mockMessage = Message(
      channel: "test",
      message: .init(
        content: .text("Hello!"),
        senderId: mockSender.id),
      at: 15841747354366664)

    let otherMessage = Message(
      channel: "test",
      message: .init(
        content: .text("TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest"),
        senderId: otherUser.id),
      at: 15843751028352367)

    let emojiMessage = Message(
      channel: "test",
      message: .init(
        content: .emoji("🤯"),
        senderId: otherUser.id),
      at: 15843750065497182)

    let test0Message = Message(
    channel: "space_ac4e67b98b34b44c4a39466e93e",
    message: .init(
      content: .text("Test"),
      senderId: "user_4ec689d24845466e93ee358c40358473"),
    at: 15843751028352360)

    let test1Message = Message(
    channel: "space_ac4e67b98b34b44c4a39466e93e",
    message: .init(
      content: .text("Test"),
      senderId: "user_4ec689d24845466e93ee358c40358473"),
    at: 15843751028352361)

    let test2Message = Message(
    channel: "space_ac4e67b98b34b44c4a39466e93e",
    message: .init(
      content: .text("Test"),
      senderId: "user_4ec689d24845466e93ee358c40358473"),
    at: 15843751028352362)

    let test3Message = Message(
    channel: "space_ac4e67b98b34b44c4a39466e93e",
    message: .init(
      content: .text("Test"),
      senderId: "user_4ec689d24845466e93ee358c40358473"),
    at: 15843751028352363)

    let test4Message = Message(
    channel: "space_ac4e67b98b34b44c4a39466e93e",
    message: .init(
      content: .text("TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest"),
      senderId: "user_4ec689d24845466e93ee358c40358473"),
    at: 15843751028352364)

    let memberResponse = PubNubMembersResponsePayload(
      status: 200, data: [senderkMember, otherMember],
      totalCount: 2, next: nil, prev: nil)

    store.dispatch(MemberActionType.membersAdded(
      spaceId: defaultConversation.id,
      response: memberResponse, users: [mockSender, otherUser]))

    let membershipResponse = PubNubMembershipsResponsePayload(
      status: 200, data: [testMembership, deafaultMembership, swiftUIMembership],
      totalCount: 3, next: nil, prev: nil)
    store.dispatch(MembershipActionType.spacesJoined(
      userId: mockSender.id, response: membershipResponse,
      spaces: [mockConversation, defaultConversation, swiftUIConversation]))

    store.dispatch(SpaceActionType.spaceCreated(boardGamesConversation))
    store.dispatch(SpaceActionType.spaceCreated(programmingConversation))

    store.dispatch(AuthActionType.loggedIn(userId: mockSender.id))
    store.dispatch(MessageActionType.messageHistoryRetrieved(
      messageByChannelId: ["test": [
        mockMessage, otherMessage, emojiMessage,
        test0Message, test1Message, test2Message,
        test3Message, test4Message]
    ]))

    return store
  }
}
#endif
