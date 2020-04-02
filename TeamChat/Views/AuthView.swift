//
//  AuthView.swift
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

// MARK: Connecting View

struct ConnectingView: View {

  @EnvironmentObject var store: AppStore

  @State private var logoWidth: CGFloat = .zero

  @State private var selectedUserIndex: Int = 0
  private var defaultUserIds: [String] = User.knownUsers.keys.map { $0 }

  @State private var selectedUser: String = ""
  @State private var password: String = "SomeRandomPassword"

  var body: some View {
    GeometryReader { geometry in
      HStack(alignment: .center) {
        VStack(alignment: .center) {
          Spacer()

          VStack(alignment: .leading, spacing: 0) {
            TextField("Username", text: self.$selectedUser)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .padding([.top, .leading, .trailing])
              .disabled(true)
              .onAppear {
                self.selectedUser = User.knownUsers[self.defaultUserIds[self.selectedUserIndex]] ?? ""
              }

            SecureField("Password", text: self.$password)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .padding([.leading, .trailing])
              .disabled(true)

            Button(
              action: {
                self.store.dispatch(AuthCommand.pubnub(login: self.defaultUserIds[self.selectedUserIndex] ))
              },
              label: {
                Text(self.store.state.auth.isLoggingIn ? "Connecting..." : "Login")
                  .font(.headline)
                  .fontWeight(.heavy)
                  .padding()
            })
              .foregroundColor(.white)
              .padding()
              .background(
                RoundedRectangle(cornerRadius: 10)
                  .fill(Color.greenHaze)
                  .padding()
                  .frame(width: geometry.size.width * 0.80)
              )
              .frame(width: geometry.size.width * 0.80)
              .disabled(self.store.state.auth.isLoggingIn)
          }
          .frame(width: geometry.size.width * 0.80)
          .navigationBarTitle("Select User")
          .padding()

          Spacer()

          VStack(spacing: 0) {
            Text("Powered By")
              .font(.subheadline)
              .foregroundColor(Color.pubnubRed)
              .frame(width: geometry.size.width * 0.20)
            Image("PubNubLogo")
              .resizable()
              .scaledToFit()
              .frame(width: geometry.size.width * 0.25)
          }
        }
      }
    }
    .background(
      Color.black
        .opacity(0.35)
        .edgesIgnoringSafeArea([.top, .bottom])
    )
    .background(
      Image("LaunchImage")
        .resizable()
        .edgesIgnoringSafeArea([.top, .bottom])
        .aspectRatio(contentMode: .fill)

    )
  }
}

#if DEBUG
// MARK: - Previews

struct ConnectingView_Previews: PreviewProvider {
  static var previews: some View {
    ConnectingView().environmentObject(AppStore())
  }
}
#endif
