//
//  ContentView.swift
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

import SwiftUI

import PubNubCSM
import PubNub

// MARK: - Views

// MARK: Root View

struct ContentView: View {

  // External State
  @EnvironmentObject var store: AppStore

  var body: some View {
    // More performant than type erasing with AnyView
    Group {
      if self.store.state.auth.userId != nil {
        NavigationView {
          // Master View (Main Scroll View)
          SendersConversationListView(selectedConversationId: store.initialConversationId)

          // Detail View (Used by Mac/Mac Catalyst)
          MessageListView(conversationId: store.initialConversationId)
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .listSeparatorStyleNone()
      } else {
        ConnectingView()
      }
    }.onAppear {
      // Start Device Reachability
      DeviceNetworkStatusListener.shared.start(self.store.dispatchFunction)
    }
  }
}

#if DEBUG
// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    // List of devices to preview:
    // https://developer.apple.com/documentation/swiftui/securefield/3289399-previewdevice
    ForEach(["iPhone 8", "iPhone Xs Max", "iPad Pro (11-inch)", "Mac"], id: \.self) { device in
      ContentView()
        .environmentObject(AppStore())
        .previewDisplayName(device)
        .previewDevice(PreviewDevice(rawValue: device))
    }
  }
}
#endif
