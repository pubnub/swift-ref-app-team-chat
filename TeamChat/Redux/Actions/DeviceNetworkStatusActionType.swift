//
//  DeviceNetworkStatusActionType.swift
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
import Network

import PubNubCSM
import ReSwift

// MARK: - Actions

public enum DeviceNetworkStatusActionType: Action {
  case monitoringDidStart
  case networkStatusChange(NWPath)
  case monitoringCancelled
}

// MARK: - State

public struct DeviceNetworkStatusState: StateType, Hashable {
  public var isConnected: Bool
  public var isExpensive: Bool
  public var interfaceType: NWInterface.InterfaceType?
  public var availableInterfacesTypes: [NWInterface.InterfaceType]

  public init(
    isConnected: Bool = false,
    isExpensive: Bool = false,
    interfaceType: NWInterface.InterfaceType? = nil,
    availableInterfacesTypes: [NWInterface.InterfaceType] = []
  ) {
    self.isConnected = isConnected
    self.isExpensive = isExpensive
    self.interfaceType = interfaceType
    self.availableInterfacesTypes = availableInterfacesTypes
  }
}

// MARK: - Reducers

public struct DeviceNetworkStatusReducer {
  public static func reducer(_ action: DeviceNetworkStatusActionType, state: inout DeviceNetworkStatusState) {
    switch action {
    case .networkStatusChange(let path):
      state.isConnected = path.isConnected
      state.isExpensive = path.isExpensive
      state.interfaceType = path.interfaceType
      state.availableInterfacesTypes = path.availableInterfacesTypes
    default:
      break
    }
  }
}

// MARK: Listener

class DeviceNetworkStatusListener {
  static let shared: DeviceNetworkStatusListener = {
    return DeviceNetworkStatusListener()
  }()

  var monitor: NWPathMonitor?
  var serviceStarted = false

  private init() {}

  deinit {
    stop()
  }

  func start(_ dispatch: @escaping DispatchFunction) {
    guard !serviceStarted else { return }

    monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetStatus_Monitor")
    monitor?.start(queue: queue)

    monitor?.pathUpdateHandler = { path in
      DispatchQueue.main.async {
        dispatch(DeviceNetworkStatusActionType.networkStatusChange(path))
      }
    }

    serviceStarted = true
    DispatchQueue.main.async {
      dispatch(DeviceNetworkStatusActionType.monitoringDidStart)
    }
  }

  func stop(_ dispatch: DispatchFunction? = nil) {
    guard serviceStarted, let monitor = monitor else { return }
    monitor.cancel()
    self.monitor = nil
    serviceStarted = false

    DispatchQueue.main.async {
      dispatch?(DeviceNetworkStatusActionType.monitoringCancelled)
    }
  }

  var isConnected: Bool {
    return monitor?.currentPath.isConnected ?? false
  }

  var isExpensive: Bool {
    return monitor?.currentPath.isExpensive ?? false
  }

  var interfaceType: NWInterface.InterfaceType? {
    return monitor?.currentPath.interfaceType
  }

  var availableInterfacesTypes: [NWInterface.InterfaceType] {
    return monitor?.currentPath.availableInterfacesTypes ?? []
  }
}

extension NWPath {
  var isConnected: Bool {
    return status == .satisfied || status == .requiresConnection
  }

  var availableInterfacesTypes: [NWInterface.InterfaceType] {
    return availableInterfaces.map { $0.type }
  }

  var interfaceType: NWInterface.InterfaceType? {
    return availableInterfaces.first(where: { usesInterfaceType($0.type) })?.type
  }
}
