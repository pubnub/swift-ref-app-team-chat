//
//  AppState.swift
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
import PubNub

import ReSwift

struct AppState: StateType, Equatable {
  var auth = AuthState()

  var networkStatus = NetworkStatusState()
  var deviceNetworkStatus = DeviceNetworkStatusState()

  var user = UserState<User>()
  var membership = MembershipState<UserMembership>()

  var conversation = SpaceState<Conversation>()
  var member = MemberState<ConversationMember>()
  var presence = PresenceState<[String: AnyJSON]>()

  var messages = MessageState<Message>()
}

enum AppReducer {
  static func reducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()

    switch action {
    case let action as AuthActionType:
      AuthReducer.reducer(action, state: &state.auth)
    case let action as DeviceNetworkStatusActionType:
      DeviceNetworkStatusReducer.reducer(action, state: &state.deviceNetworkStatus)
    case let action as PubNubActionType:
      NetworkStatusReducer.reducer(action, state: &state.networkStatus)
      UserReducer.reducer(action, state: &state.user)
      SpaceReducer.reducer(action, state: &state.conversation)
      MembershipReducer.reducer(action, state: &state.membership)
      MemberReducer.reducer(action, state: &state.member)
      MessageReducer.reducer(action, state: &state.messages)
      PresenceReducer.reducer(action, state: &state.presence)

    default:
      break
    }

    return state
  }
}

final class AppStore: StoreSubscriber, DispatchingStoreType, ObservableObject {

  private let store: Store<AppState>
  public var dispatchFunction: DispatchFunction {
    return store.dispatchFunction
  }
  public var notification: NotificationCenterService

  @Published fileprivate(set) var state: AppState

  init(_ store: Store<AppState> = makeStore, notification: NotificationCenter = .default) {
    self.store = store
    self.state = store.state
    self.notification = NotificationCenterService(center: notification,
                                                  dispatch: self.store.dispatchFunction)

    store.subscribe(self)
  }

  deinit {
    store.unsubscribe(self)
  }

  func newState(state: AppState) {
    DispatchQueue.main.async {
      self.state = state
    }
  }

  func dispatch(_ action: Action) {
    DispatchQueue.main.async { [weak self] in
      self?.store.dispatch(action)
    }
  }

  static var makeStore: Store<AppState> {
    return Store(
      reducer: AppReducer.reducer,
      state: AppState(),
      middleware: [
        loggingMiddleware,
        PubNubStateChangeMiddlware.getMiddlware,
        ThunkAction.getMiddleware
      ]
    )
  }
}

let loggingMiddleware: Middleware<AppState> = { dispatch, getState in
  return { next in
    return { action in
      print("Action Executed: \(action)")
      return next(action)
    }
  }
}
