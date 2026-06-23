//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License. See LICENSE in the project root for license information.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
  func applyingRegexHighlights(config: MarkdownRenderConfig) -> NSMutableAttributedString {
    guard !config.regexHighlights.isEmpty, length > 0 else {
      return self
    }

    let result = NSMutableAttributedString(attributedString: self)
    let fullRange = NSRange(location: 0, length: result.length)

    for highlight in config.regexHighlights {
      guard let regex = try? NSRegularExpression(pattern: highlight.pattern) else {
        continue
      }

      let matches = regex.matches(in: result.string, range: fullRange)
      for match in matches where result.canApplyRegexHighlight(in: match.range) {
        result.addAttributes(
          [
            .font: result.resolvedFont(for: highlight, config: config),
            .foregroundColor: result.resolvedForegroundColor(for: highlight, config: config)
          ],
          range: match.range
        )
      }
    }

    return result
  }

  private func canApplyRegexHighlight(in range: NSRange) -> Bool {
    guard range.location != NSNotFound, range.length > 0 else {
      return false
    }

    var canHighlight = true
    enumerateAttributes(in: range, options: []) { attributes, _, stop in
      if attributes[.attachment] != nil ||
         attributes[.link] != nil ||
         attributes[.markdownAllowsRegexHighlight] as? Bool == false {
        canHighlight = false
        stop.pointee = true
      }
    }
    return canHighlight
  }

  private func resolvedFont(for highlight: RegexHighlight, config: MarkdownRenderConfig) -> UIFont {
    switch highlight.style {
    case .explicit:
      return highlight.font
    case .quotedSpeech:
      return config.quoteHighlightFont
    }
  }

  private func resolvedForegroundColor(for highlight: RegexHighlight, config: MarkdownRenderConfig) -> UIColor {
    switch highlight.style {
    case .explicit:
      return UIColor(highlight.foregroundColor)
    case .quotedSpeech:
      return UIColor(config.quoteHighlightColor)
    }
  }
}
