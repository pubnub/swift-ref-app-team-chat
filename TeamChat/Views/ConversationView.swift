//
//  RoomView.swift
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

import PubNubCSM

// MARK: User’s Spaces View (Master View)

/// List of rooms associated with the current sender (auth'd user)
struct SendersConversationListView: View {

  @EnvironmentObject var store: AppStore

  @State var selectedConversationId: String = ""

  @State var deepLinkActive = true
  @State var displayingJoinConversation = false

  var body: some View {
    VStack(alignment: .leading) {
      List {
        Section(header: Text("GROUP MESSAGING")) {
          VStack(alignment: .leading) {
            // Can be used to set message view deep links
            NavigationLink(
              destination: MessageListView(conversationId: self.selectedConversationId),
              isActive: self.$deepLinkActive
            ) {
              EmptyView()
                .frame(width: 0, height: 0)
                .disabled(true)
            }

            ConversationListViewCell(conversation: self.store.defaultConversation) {
              self.selectedConversationId = self.store.state.auth.defaultConverstaionId
              self.deepLinkActive = true
            }
          }

          // Non-default Conversation Memberships
          ForEach(store.conversationSelector) { conversation in
            ConversationListViewCell(conversation: conversation) {
              self.selectedConversationId = conversation.id
              self.deepLinkActive = true
            }
          }
          .onDelete { indexSet in
            let conversationIds = indexSet.map { self.store.conversationSelector[$0].id }
            if let request = self.store.modifyMembershipRequest(for: conversationIds) {
              self.store.dispatch(MembershipCommand.leave(request))
            }
          }
        }
      }
      .listStyle(GroupedListStyle())

      Spacer()
    }
    .navigationBarTitle(
      // We want to hide the title in next view, but currently there isn't a great way to do it
      Text("Conversations")
        .font(.title)
        .bold()
        .foregroundColor(Color.comet),
      displayMode: .inline
    )
    .navigationBarItems(
      leading:
        NavigationLink(
          destination: UserDetailView(
            userId: self.store.senderIdOrEmptyString,
            conversationId: self.store.state.auth.defaultConverstaionId)
        ) {
          ZStack {
            AvatarCircleView(user: self.store.sender)
              .frame(width: 48, height: 48, alignment: .center)
            Circle()
              .fill(Color.barTintColor)
              .frame(width: 48 * 0.25, height: 48 * 0.25)
              .offset(x: 13, y: 13)
            Circle()
              .fill(self.store.isConnected ? Color.turquoiseGreen : Color.barTintColor)
              .overlay(
                Circle().stroke(self.store.isConnected ? Color.turquoiseGreen : Color.gray, lineWidth: 2)
              )
              .frame(width: 48 * 0.12, height: 48 * 0.12)
              .offset(x: 13, y: 13)
          }
        },
      trailing:
        Button(
          action: {
            self.displayingJoinConversation.toggle()
          },
          label: {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $displayingJoinConversation) {
          AllConversationsListView().environmentObject(self.store)
        }
    )
    .onAppear {
      if let memberships = self.store.senderMembershipIds(), !memberships.isEmpty {
        if self.store.state.presence.totalOccupancy == 0 {
          self.store.dispatch(PresenceCommand.hereNow(.init(channels: memberships)))
        }

        if self.store.state.messages.messagesByChannel.isEmpty {
          self.store.dispatch(MessageCommand.fetchMessageHistory(.init(channels: memberships, limit: 500)))
        }
      }
    }
  }
}

struct ConversationListViewCell: View {

  @EnvironmentObject var store: AppStore

  var conversation: Conversation?
  var showDetail: Bool
  var action: () -> Void

  init(conversation: Conversation?, showDetail: Bool = false, action: @escaping () -> Void) {
    self.conversation = conversation
    self.showDetail = showDetail
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      VStack(alignment: .leading) {
        HStack {
          Image(systemName: "grid")
            .foregroundColor(Color.white)
            .padding()
            .background(
              Rectangle()
                .fill(self.conversation?.id.defaultAvatarColor ?? .pubnubRed)
                .cornerRadius(6)
                .scaledToFill()
            )
          VStack(alignment: .leading) {
            Text(conversation?.name ?? "")
              .font(.headline)
              .foregroundColor(Color.secondary)
            if showDetail {
              // Using "Placeholder"`" to keep consistent spacing when this field is not set on the Conversation
              Text(conversation?.purpose ?? "Placeholder")
                .lineLimit(nil)
                .font(.subheadline)
                .foregroundColor(conversation?.purpose != nil ? Color(UIColor.tertiaryLabel) : Color.clear)
              }
          }
        }
        Divider()
      }
    }
  }
}

// MARK: All Conversation List View

extension AppStore {

  var nonMembershipConversations: [Conversation] {
     guard let userId = state.auth.userId,
      let membershipIds = state.membership.membershipsByUserId[userId]?.map({ $0.id }) else {
        return []
    }

    return state.conversation.spaces.values.filter { !membershipIds.contains($0.id) }
  }
}

struct AllConversationsListView: View {

  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

  @EnvironmentObject var store: AppStore

  @State var tableDisabled = false

  var body: some View {
    VStack(alignment: .leading) {
      // Fake Navigation View
      HStack(alignment: .center, spacing: 0) {
        Button(
          action: { self.presentationMode.wrappedValue.dismiss() },
          label: {
            Text("Cancel")
              .font(.headline)
        })
        .padding([.leading, .trailing])

        Spacer()

        Text("Join a Conversation")
          .font(.headline)
          .scaledToFill()
          .padding(.trailing)

        Spacer()

        Button(
          action: { self.presentationMode.wrappedValue.dismiss() },
          label: {
            Image(systemName: "plus")
              .resizable()
              .scaledToFit()
              .frame(width: 24, height: 24)
        })
        .padding([.leading, .trailing])
        .hidden()
      }.padding(.top)

      List {
        Section(header: Text("GROUP MESSAGING").padding(.top)) {
          ForEach(self.store.nonMembershipConversations) { conversation in
            ConversationListViewCell(conversation: conversation, showDetail: true) {
              self.tableDisabled = true

              guard let userId = self.store.state.auth.userId  else {
                self.tableDisabled = false
                return
              }

              self.store.dispatch(
                MembershipCommand.join(.init(userId: userId, modifiedBy: [UserMembership(id: conversation.id)])) { _ in
                PubNubServiceProvider.shared.subscribe(conversation.id, presence: true)

                self.store.dispatch(MemberCommand.fetchMembers(.init(spaceId: conversation.id)))

                self.store.dispatch(PresenceCommand.hereNow(.init(channels: [conversation.id])))

                self.store.dispatch(MessageCommand.fetchMessageHistory(.init(channels: [conversation.id])) { _ in
                  self.tableDisabled = false
                  self.presentationMode.wrappedValue.dismiss()
                })}
              )
            }
          }
        }
      .listStyle(GroupedListStyle())
      .disabled(tableDisabled)
      }
    }
    .onAppear {
      self.store.dispatch(SpaceCommand.fetchPubNubSpaces(.init()))
    }
  }
}

// MARK: Membership List View

extension AppStore {
  func conversationUsers(for conversationId: String) -> [User] {
    return self.state.member.membersBySpaceId[conversationId]?.compactMap { member in
      if member.id == self.senderId {
        return nil
      }
      return self.state.user.users[member.id]
    }.sorted { $0.name < $1.name } ?? []
  }
}

extension AppStore {
  func conversationMembersByPresenceStatus(for conversationId: String) -> [User] {
    // Presence users
    let hereNow = state.presence.presenceByChannelId[conversationId]?
      .occupants.keys.compactMap { self.state.user.users[$0] }
      .sorted { $0.name < $1.name } ?? []

    let allUsers = state.member.membersBySpaceId[conversationId]?
      .compactMap { self.state.user.users[$0.id] }
      .filter { !hereNow.contains($0) }
      .sorted { $0.name < $1.name } ?? []

    return hereNow + allUsers
  }
}

/// A list of members for a space
struct ConversationDetailView: View {

  @EnvironmentObject var store: AppStore

  var conversationId: String

  var body: some View {
      VStack(alignment: .leading) {
        List {
          Section(header:
            Text("DESCRIPTION")
              .foregroundColor(Color.black.opacity(0.40))
              .font(.footnote)
              .padding(.top)
          ) {
            Text(store.state.conversation.spaces[conversationId]?.purpose ?? "")
              .font(.body)
              .lineLimit(nil)
              .padding([.top, .bottom], 1)
          }

          Section(header:
            Text("MEMBERS")
              .foregroundColor(Color.black.opacity(0.40))
              .font(.footnote)
          ) {
            ForEach(self.store.conversationMembersByPresenceStatus(for: conversationId)) { user in
              NavigationLink(
                destination: UserDetailView(userId: user.id, conversationId: self.conversationId)
              ) {
                VStack(alignment: .leading) {
                  UserDetailCellView(userId: user.id, conversationId: self.conversationId, height: 40.0)
                    .frame(height: 40)
                  Divider()
                }
              }
            }
          }
        }
        .listStyle(GroupedListStyle())
      }
      .navigationBarTitle(Text(""), displayMode: .inline)
  }
}

#if DEBUG
// MARK: - Previews

struct SendersConversationListView_Previews: PreviewProvider {

  static let store = AppStore(AppStore.makePreivewStore)

  static var previews: some View {
    NavigationView {
      SendersConversationListView()
        .environmentObject(store)
        .listSeparatorStyleNone()
    }
  }
}

struct AllConversationsListView_Previews: PreviewProvider {

  static let store = AppStore(AppStore.makePreivewStore)

  static var previews: some View {
    AllConversationsListView().environmentObject(store)
  }
}

struct ConversationDetailView_Previews: PreviewProvider {

  static let store = AppStore(AppStore.makePreivewStore)

  static var previews: some View {
    NavigationView {
      ConversationDetailView(conversationId: store.state.auth.defaultConverstaionId).environmentObject(store)
    }
  }
}
#endif
