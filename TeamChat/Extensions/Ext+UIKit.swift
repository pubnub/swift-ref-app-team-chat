//
//  Ext+UIKit.swift
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

// MARK: Default Colors

extension Color {
  /// Adaptive color that matches the default Navigation Bar Tint Color
  static let barTintColor = { return Color("BarTintColor") }()

  /// Hex code: #E5E5EA
  static let athensGrey = { return Color("AthensGray") }()
  /// Hex code: #F8F8F8
  static let alabaster = { return Color("Alabaster") }()
  /// Hex code: #F2F6FF
  static let zircon = { return Color("Zircon") }()
  /// Hex code: #555770
  static var comet = { return Color("Comet") }()

  /// Hex code:  #E5E5EA
  static var whiteLilac = { return Color("WhiteLilac") }()
  /// Hex code: #22202B
  static var haiti = { return Color("Haiti") }()

  /// Hex code: # D02129
  static var pubnubRed = { return Color("PubNubRed") }()

  /// Hex code: #FFAB91
  static var roseBud = { return Color("RoseBud") }()
  /// Hex code: #80DEEA
  static var skyBlue = { return Color("SkyBlue") }()
  /// Hex code: #EF9A9A
  static var sweetPink = { return Color("SweetPink") }()
  /// Hex code: #CE93D8
  static var wisteria = { return Color("Wisteria") }()
  /// Hex code: #AED581
  static var feijoa = { return Color("Feijoa") }()
  /// Hex code: #9FA7DF
  static var echoBlue = { return Color("EchoBlue") }()
  /// Hex code: #BCAAA4
  static var martini = { return Color("Martini") }()
  /// Hex code: #FFE082
  static var goldenGlow = { return Color("GoldenGlow") }()
  /// Hex code: #F48FB1
  static var illusion = { return Color("Illusion") }()
  /// Hex code: #FCCC75
  static var grandis = { return Color("Grandis") }()
  /// Hex code: #5BAEFC
  static var mayaBlue = { return Color("MayaBlue") }()
  /// Hex code: #FDED72
  static let marigoldYellow = { return Color("MarigoldYellow") }()
  /// Hex code: #A9EFF2
  static let iceCold = { return Color("IceCold") }()
  /// Hex code: #D1D5DB
  static let mischka = { return Color("Mischka") }()
  /// Hex code: #FCCC75
  static let goldenrod = { return Color("Goldenrod") }()
  /// Hex code: #C7C9D9
  static let ghost = { return Color("Ghost") }()
  /// Hex code: #73DFE7
  static let turquoiseBlue = { return Color("TurquoiseBlue") }()
  /// Hex code: #DDA5E9
  static let frenchLilac = { return Color("FrenchLilac") }()
  /// Hex code: #9DBFF9
  static let malibu = { return Color("Malibu") }()
  /// Hex code:  #57EBA1
  static var turquoiseGreen = { return Color("TurquoiseGreen") }()
  /// Hex code:  #ADB3BC
  static var aluminium = { return Color("Aluminium") }()
  /// Hex code:  #FF8080
  static var vividTangerine = { return Color("VividTangerine") }()
  /// Hex code:  #39D98A
  static var shamrock = { return Color("Shamrock") }()
  /// Hex code:  #949494
  static var dustyGray = { return Color("DustyGray") }()
  /// Hex code: #8F90A6
  static var manatee = { return Color("Manatee") }()
  /// Hex code: #3E7BFA
  static let dodgerBlue = { return Color("DodgerBlue") }()
  /// Hex code: #FF3B30
  static let redOrange = { return Color("RedOrange") }()
  /// Hex code: #05A660
  static var greenHaze = { return Color("GreenHaze") }()
  /// Hex code: #007AFF
  static var azureRadiance = { return Color("AzureRadiance") }()
  /// Hex code:  #555770

  static var defaultAvatarColors: [Color] = {
    return [
      .roseBud, .skyBlue, .sweetPink, .wisteria, .feijoa,
      .echoBlue, .martini, .goldenGlow, .illusion, .grandis,
      .marigoldYellow, .iceCold, .mischka, .goldenrod, .ghost,
      .turquoiseBlue, .frenchLilac, .malibu, .aluminium, .vividTangerine,
      .shamrock, .dustyGray, .redOrange, . greenHaze, .azureRadiance
    ]
  }()
}

// MARK: - NetworkStatus Colors

extension NetworkStatus {
  var stroke: Color {
    switch self {
    case .notConnected:
      return Color.blue
    case .connecting:
      return Color.yellow
    case .connected:
      return Color.turquoiseGreen
    }
  }

  var fill: Color {
    switch self {
    case .notConnected:
      return Color.barTintColor
    case .connecting:
      return Color.yellow
    case .connected:
      return Color.turquoiseGreen
    }
  }
}

// MARK: - String

extension String {
  var defaultAvatarColor: Color {
    return Color.defaultAvatarColors.value(from: self)
  }

  fileprivate var charIntHash: Int {
    var hash = 0
    for (index, chunk) in self.reversed().enumerated() where index < 5 {
      hash = (hash << 5) - hash + Int(chunk.unicodeScalars.first?.value ?? UInt32(1))
      hash = hash & hash
    }

    return hash
  }
}

extension Array {
  /// Uses the hash value of the string to return an indexed value
  func value(from string: String) -> Element {
    return self[((string.charIntHash % count) + count) % count]
  }
}

// MARK: - Models

extension User {
  var defaultAvatarColor: Color {
    return id.defaultAvatarColor
  }
}

extension Conversation {
  var defaultAvatarColor: Color {
    return id.defaultAvatarColor
  }
}
