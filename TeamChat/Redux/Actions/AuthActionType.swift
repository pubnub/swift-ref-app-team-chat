//
//  AuthActionType.swift
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
import Combine

import PubNub
import PubNubCSM
import ReSwift

// MARK: - Actions

public enum AuthActionType: Action {
  case performingLogin
  case loggedIn(userId: String)
  case loginFailed(Error)

  case syncingSenderData
  case dataSyncComplete
  case dataSyncFailed(Error)

  case deepLinkConversation(String)
}

// MARK: - Commands

public enum AuthCommand: Action {
  static func pubnub(login userId: String, completion: @escaping UserIdResultClosure = { _ in }) -> ThunkAction {
    return ThunkAction { dispatch, _, service in
      dispatch(AuthActionType.performingLogin)

      // Set the UUID of the current user to ensure that presence works correctly
      var config = PubNubConfiguration(publishKey: ENV.PubNub.publishKey, subscribeKey: ENV.PubNub.subscribeKey)
      config.uuid = userId
      PubNubServiceProvider.shared.set(service: PubNub(configuration: config))
      PubNubServiceProvider.shared.add(listener: PubNubListener.createListener(dispatch: dispatch))

      dispatch(UserCommand.fetchPubNubUser(.init(userId: userId)) { result in
        switch result {
        case .success(let user):

          dispatch(MembershipCommand.fetchPubNubMemberships(.init(userId: userId)) { result in
            switch result {
            case let .success(response):
              // Subscribe to user & user's memberships
              service()?.subscribe(.init(channels: [user.id] + response.response.memberships.map { $0.id },
                                         withPresence: true))

              // confirm login
              dispatch(AuthActionType.loggedIn(userId: user.id))
              completion(.success(user.id))
            case .failure(let error):
              dispatch(AuthActionType.loginFailed(error))
              completion(.failure(error))
            }
          })
        case .failure(let error):
          dispatch(AuthActionType.loginFailed(error))
          completion(.failure(error))
        }
      })
    }
  }

  static func syncSenderData() -> ThunkAction {
    return ThunkAction { dispatch, getState, service in
      dispatch(AuthActionType.syncingSenderData)

      guard let appState = getState() as? AppState, let userId = appState.auth.userId else {
        // User doesn't exist
        return
      }

      dispatch(MembershipCommand.fetchPubNubMemberships(.init(userId: userId)) { result in
        switch result {
        case let .success(response):
          let memberships = response.response.memberships.map { $0.id }
          // Subscribe to user & user's memberships
          service()?.subscribe(.init(channels: [userId] + memberships,
                                     withPresence: true))

          // Fetch Messages and Updated presence
          dispatch(MessageCommand.fetchMessageHistory(.init(channels: memberships)))
          dispatch(PresenceCommand.hereNow(.init(channels: memberships)))

          dispatch(AuthActionType.dataSyncComplete)
        case let .failure(error):
          dispatch(AuthActionType.dataSyncFailed(error))
        }
      })
    }
  }
}

// MARK: - State

public struct AuthState: StateType, Equatable {

  var isLoggingIn: Bool = false
  var userId: String?

  var defaultConverstaionId: String = "space_ac4e67b98b34b44c4a39466e93e"
  var deepLinkConversationId: String?
}

// MARK: - Reducer

public struct AuthReducer {
  public static func reducer(_ action: AuthActionType, state: inout AuthState) {
    switch action {
    case .performingLogin:
      state.isLoggingIn = true
    case .loggedIn(let userId):
      state.userId = userId
      state.isLoggingIn = false
    case .loginFailed:
      state.isLoggingIn = false
    case .deepLinkConversation(let conversationId):
      state.deepLinkConversationId = conversationId
    default:
      break
    }
  }
}
