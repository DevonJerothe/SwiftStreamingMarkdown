//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License. See LICENSE in the project root for license information.
//

import SwiftUI
import UIKit

public struct RegexHighlight: Hashable, @unchecked Sendable {
  enum Style: Hashable, Sendable {
    case explicit
    case quotedSpeech
  }

  public let pattern: String
  public let font: UIFont
  public let foregroundColor: Color
  let style: Style

  public init(pattern: String, font: UIFont, foregroundColor: Color) {
    self.pattern = pattern
    self.font = font
    self.foregroundColor = foregroundColor
    self.style = .explicit
  }

  init(pattern: String, font: UIFont, foregroundColor: Color, style: Style) {
    self.pattern = pattern
    self.font = font
    self.foregroundColor = foregroundColor
    self.style = style
  }

  public static let standardQuotedSpeech = RegexHighlight(
    pattern: #""[^"]+"|“[^”]+”"#,
    font: .italicSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize),
    foregroundColor: .blue,
    style: .quotedSpeech
  )
}
