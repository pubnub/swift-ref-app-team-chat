//
//  UserView.swift
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
import PubNub

// MARK: Avatar View

extension CGSize {
  /// Returns the larger dimension CGFloat between width and height
  var largerDimension: CGFloat {
    return height > width ? height : width
  }

  /// Returns the smaller dimension CGFloat between width and height
  var smallerDimension: CGFloat {
    return height > width ? width : height
  }
}

/// Avatar associated with a User
struct AvatarCircleView: View {
  var user: User?

  var withPresence: Bool = false

  var body: some View {
    GeometryReader { proxy in
      Text(self.user?.initials ?? "")
        .font(.system(size: proxy.size.smallerDimension * 0.25))
        .bold()
        .foregroundColor(Color.white)
        .background(
          Circle()
            .fill(self.user?.defaultAvatarColor ?? .clear)
            .frame(
              width: proxy.size.smallerDimension * 0.75,
              height: proxy.size.smallerDimension * 0.75,
              alignment: .center
        ))
    }
  }
}

// MARK: - User Detail Cell

struct UserDetailCellView: View {

  @EnvironmentObject var store: AppStore

  var userId: String
  var conversationId: String

  var height: CGFloat

  var body: some View {
    HStack {
      AvatarCircleView(user: self.store.state.user.users[self.userId])
        .scaledToFit()

      VStack(alignment: .leading, spacing: 0) {
        HStack {
            Text(self.store.user(by: self.userId)?.name ?? "")
              .font(.headline)
            Circle()
              .fill(self.store.presence(for: self.userId, on: self.conversationId) ? Color.green : Color.clear)
              .overlay(
                Circle()
                  .stroke(self.store.presence(for: self.userId, on: self.conversationId) ? Color.green : Color.gray)
              )
              .frame(width: self.height * 0.2, height: self.height * 0.2)
        }
        Text(self.store.user(by: self.userId)?.title ?? "").font(.subheadline)
      }
    }
    .opacity(self.store.presence(for: self.userId, on: self.conversationId) ? 1.0 : 0.35)
  }
}

// MARK: - User Profile View

struct UserDetailProfileView: View {

  @EnvironmentObject var store: AppStore

  var userId: String
  var conversationId: String

  @State private var presenceDotHeight: CGFloat = .zero

  var body: some View {
    ZStack(alignment: .bottomLeading) {

      AvatarCircleView(user: self.store.state.user.users[self.userId])

      HStack(alignment: .center, spacing: 3) {
        Text(self.store.state.user.users[self.userId]?.name ?? "")
          .font(.largeTitle)
          .bold()
          .modifier(ViewHeightConstraintKey())
          .onPreferenceChange(ViewHeightConstraintKey.self) {
            if $0 > self.presenceDotHeight { self.presenceDotHeight = $0 }
          }
        Circle()
          .fill(self.store.senderConnectivityOrPresence(for: self.userId) ? Color.turquoiseGreen : Color.clear)
          .overlay(
            Circle()
              .stroke(self.store.senderConnectivityOrPresence(for: self.userId) ? Color.turquoiseGreen : Color.gray),
            alignment: .center
          )
          .frame(width: presenceDotHeight * 0.25,
                 height: presenceDotHeight * 0.25)
      }
      .padding(.leading)
    }
  }
}

// MARK: - User Detail View

struct UserDetailView: View {

  @EnvironmentObject var store: AppStore

  var userId: String
  var conversationId: String

  var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .center, spacing: 0) {
        UserDetailProfileView(userId: self.userId, conversationId: self.conversationId)
          .frame(width: geometry.size.width, height: geometry.size.height * 0.45)

        List {
          VStack(alignment: .leading) {
            Text("Title").foregroundColor(.primary).opacity(0.4).font(.subheadline)
            Text(self.store.state.user.users[self.userId]?.title ?? "")
              .font(.headline).foregroundColor(Color.secondary)
          }
          VStack(alignment: .leading) {
            Text("Email").foregroundColor(.black).opacity(0.4).font(.subheadline)
            Text(self.store.state.user.users[self.userId]?.email ?? "")
              .font(.headline).foregroundColor(Color.secondary)
          }
        }
        .scaledToFill()
        .listStyle(GroupedListStyle())
        .frame(width: geometry.size.width, height: geometry.size.height * 0.55)
      }
    }.navigationBarTitle("Profile", displayMode: .inline)
  }
}

#if DEBUG
// MARK: - Previews

struct AvatarCircleView_Previews: PreviewProvider {

  static let mockSender = User(name: "Crusty Dev", title: "Software Engineer")

  static var previews: some View {
    AvatarCircleView(user: mockSender)
    .previewLayout(.fixed(width: 48, height: 48))
  }
}

struct UserDetailCellView_Previews: PreviewProvider {

  static let store = AppStore(AppStore.makePreivewStore)

  static var previews: some View {
    UserDetailCellView(
      userId: store.senderIdOrEmptyString,
      conversationId: store.state.auth.defaultConverstaionId,
      height: 70
    )
      .environmentObject(store)
      .previewLayout(.fixed(width: 300, height: 70))
  }
}

struct UserDetailView_Previews: PreviewProvider {

  static let store = AppStore(AppStore.makePreivewStore)

  static var previews: some View {
    UserDetailView(
      userId: store.senderIdOrEmptyString,
      conversationId: store.state.auth.defaultConverstaionId
    )
    .environmentObject(store)
  }
}
#endif
