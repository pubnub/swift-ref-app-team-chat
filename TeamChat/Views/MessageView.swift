//
//  MessageView.swift
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

import PubNub
import PubNubCSM

// MARK: Message List View

/// List of Messages
struct MessageListView: View {

  // External State
  @EnvironmentObject var store: AppStore
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  @State var presentingConversationDetail = false

  @State var messageInput: String = ""
  @ObservedObject var keyboard = KeyboardNotificationHandler()

  var conversationId: String

  @State var listHeight: CGFloat = .zero
  @State var viewHeight: CGFloat = .zero

  var body: some View {
    VStack(alignment: .leading, spacing: .none) {
      AutoScrollView(
        didScroll: { contentHeight, viewHeight in
          self.listHeight = contentHeight
          self.viewHeight = viewHeight
        },
        content: {
          ForEachAround(self.store.messages(for: self.conversationId)) { previous, current, next in
            MessageCellView(previous: previous, current: current, next: next)
          }
          // Workaround so it will scroll inside empty space on right side of short messages
          .background(Color(UIColor.systemBackground))
      })
      .padding(.top)
      .offset(y: self.keyboardOffset())

      // Text Input
      MessageInputView(
        userInput: self.$messageInput,
        conversation: self.store.conversation(by: self.conversationId)
      ) {
        if !self.messageInput.isEmpty {
          self.sendMessage(self.messageInput)
          // Clear the input bar
          self.messageInput = ""

          self.dismissKeyboard(true)
        }
      }
      .offset(y: -self.keyboard.currentHeight)
      .resignKeyboardOnDragGesture()
    }
    // Only ignore bottom safe area when keyboard is visible
    .edgesIgnoringSafeArea(self.keyboard.currentHeight == .zero ? [] : .bottom)
    .navigationBarTitle(
      Text(store.conversation(by: conversationId)?.name ?? ""),
      displayMode: .inline
    )
    .navigationBarBackButtonHidden(true)
    .navigationBarItems(
      leading:
        Button(
          action: { self.presentationMode.wrappedValue.dismiss() },
          label: {
            // Hides button on macos
            if UIDevice.current.userInterfaceIdiom != .pad {
              Image(systemName: "chevron.left")
                .font(.system(size: 24, weight: .medium, design: .default))
            }
        })
        .removedOnMacCatalyst(),

      trailing:
      HStack(spacing: .zero) {
        NavigationLink(
          destination: ConversationDetailView(conversationId: self.conversationId),
          isActive: self.$presentingConversationDetail
        ) {
          EmptyView()
            .frame(width: 0, height: 0)
            .disabled(true)
        }
        Button(
          action: { self.presentingConversationDetail = true },
          label: {
            VStack {
              Image(systemName: "person.2")
              // swiftlint:disable:next line_length
              Text("\(self.store.occupancy(for: self.conversationId))/\(self.store.memberCount(for: self.conversationId))")
                .font(.caption)
            }
        })
      }
    )
    .onAppear {
      if self.store.memberCount(for: self.conversationId) == 0 {
        self.store.dispatch(MemberCommand.fetchMembers(.init(spaceId: self.conversationId)))
      }
    }
  }

  func keyboardOffset() -> CGFloat {
    if self.keyboard.currentHeight == .zero || self.emptyListSpace >= self.keyboard.currentHeight {
      return 0
    }

    if self.emptyListSpace < .zero {
      return -self.keyboard.currentHeight
    }

    if self.emptyListSpace < self.keyboard.currentHeight {
      return -(self.keyboard.currentHeight - self.emptyListSpace)
    }

    return .zero
  }

  var emptyListSpace: CGFloat {
    return self.viewHeight - self.listHeight
  }

  func sendMessage(_ message: String) {
    let message = MessagePayload(content: .text(message), senderId: self.store.senderIdOrEmptyString)

    self.store.dispatch(
      MessageCommand.sendMessage(.init(content: message, channel: self.conversationId, storeInHistory: true))
    )
  }

  func dismissKeyboard(_ force: Bool) {
    UIApplication.shared.windows.forEach { $0.endEditing(force) }
  }
}

struct MessageInputView: View {

  @Binding var userInput: String
  var conversation: Conversation?
  var onCommit: () -> Void

  var body: some View {
    HStack(spacing: 0) {
      TextField("Message #\(conversation?.name ?? "")",
        text: self.$userInput,
        onCommit: onCommit
      )
      .padding(.leading, 10)
      .padding(.top, 4)
      .padding(.bottom, 2)
      .lineLimit(nil)
      .fixedSize(horizontal: false, vertical: true)

      Button(action: onCommit) {
        Image(systemName: "arrow.up.circle.fill")
          .resizable()
          .frame(width: 25.0, height: 25.0)
          .foregroundColor(
            self.userInput.isEmpty ? Color.comet : Color.dodgerBlue
          )
      }
      .padding(.trailing, 4)

      .disabled(self.userInput.isEmpty)
      .removedOnMacCatalyst()
    }
    .padding([.bottom, .top], 2)
    .overlay(
      RoundedRectangle(cornerRadius: 15)
      .stroke(Color.secondary, lineWidth: 1)
    )
    .padding([.leading, .trailing])
  }

  func dismissKeyboard(_ force: Bool) {
    UIApplication.shared.windows.forEach { $0.endEditing(force) }
  }
}

// MARK: Message View

/// Details of a message to be used as list cell
struct MessageCellView: View {

  @EnvironmentObject var store: AppStore
  var previous: Message?
  var current: Message
  var next: Message?
  var messageDateFormatter: DateFormatter?

  var body: some View {
    VStack(alignment: .leading) {
      if shouldDisplayTime(between: previous, current: current, and: next) {
        VStack(alignment: .leading, spacing: 1) {
          Text(top(date: self.current.timetoken.timetokenDate))
            .font(.subheadline)
            .bold()
            .padding(.leading)
          Divider()
        }
      }

      HStack(alignment: .top, spacing: 5) {
        AvatarCircleView(user: self.store.user(by: self.current))
        .frame(width: 50.0, height: 50.0, alignment: .center)

        VStack(alignment: .leading) {
          HStack {
            Text(self.store.user(by: self.current)?.name ?? "")
              .foregroundColor(Color.comet)
              .font(.headline)
            Text(
              (self.messageDateFormatter ?? DateFormatter.deafultMessage)
                .string(from: self.current.timetoken.timetokenDate)
            )
            .foregroundColor(Color.manatee)
            .font(.caption)
          }

          Group {
            // Switch is not currently supported, so we chain ifs
            if self.current.ofContent(type: .text) {
              TextMessageView(content: self.current.message.content)
            } else if self.current.ofContent(type: .emoji) {
              EmojiMessageView(content: self.current.message.content)
            }
          }
          .padding([.top], 2)
        }

        Spacer()
      }
    }
  }

  // Display a time space above messages if they're from different days
  private func shouldDisplayTime(between previous: Message?, current: Message, and next: Message?) -> Bool {
    guard let previous = previous else {
      return true
    }

    return RelativeDateTimeFormatter.daysDiffer(between: current.timetoken.timetokenDate,
                                                and: previous.timetoken.timetokenDate)
  }

  private func top(date: Date) -> String {
    let formatter = RelativeDateTimeFormatter.shared
    if formatter.calendar.isDateInToday(date) {
      return "Today"
    }
    if formatter.calendar.isDateInYesterday(date) {
      return "Yesterday"
    }
    let dateString: String
    switch formatter.calendar.component(.day, from: date) {
    case 1, 21, 31:
      dateString = "\(DateFormatter.shortDate.string(from: date))st"
    case 2, 22:
      dateString = "\(DateFormatter.shortDate.string(from: date))nd"
    case 3, 23:
      dateString = "\(DateFormatter.shortDate.string(from: date))rd"
    default:
      dateString = "\(DateFormatter.shortDate.string(from: date))th"
    }

    if formatter.calendar.component(.year, from: date) != formatter.calendar.component(.year, from: Date()) {
      return "\(dateString), \(formatter.calendar.component(.year, from: date))"
    }

    return dateString
  }
}

// MARK: Message Content Views

struct TextMessageView: View {
  @Environment(\.colorScheme) var colorScheme: ColorScheme

  var content: MessageType

  var body: some View {
    Text(content.description)
      .lineLimit(nil)
      .font(.body)
      .multilineTextAlignment(.leading)
      .padding()
      .background(
        ChatBubble(alignment: .trailing)
          .rotation(Angle(degrees: 180.0))
          .fill(colorScheme == .light ? Color.whiteLilac : Color.haiti)
      )
      // Allows lineLimit to work inside stacked views https://stackoverflow.com/a/56604599
      .fixedSize(horizontal: false, vertical: true)
  }
}

struct EmojiMessageView: View {
  var content: MessageType

  var body: some View {
    Text(content.description)
      .font(.largeTitle)
  }
}

#if DEBUG
// MARK: - Previews

struct MessageListView_Previews: PreviewProvider {

  static var store = AppStore(AppStore.makePreivewStore)

  static var previews: some View {
    MessageListView(conversationId: "test")
      .environmentObject(store)
      .listSeparatorStyleNone()
  }
}
#endif
