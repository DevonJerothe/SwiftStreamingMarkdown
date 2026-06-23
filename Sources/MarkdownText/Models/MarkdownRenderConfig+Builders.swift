//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License. See LICENSE in the project root for license information.
//

import Foundation
import SwiftUI
import UIKit

extension MarkdownRenderConfig {
  /// Returns a copy with `shouldAnimateText` replaced.
  public func withShouldAnimateText(value: Bool) -> MarkdownRenderConfig {
    MarkdownRenderConfig(
      shouldAnimateText: value,
      blockQuoteStyle: blockQuoteStyle,
      headingStyle: headingStyle,
      orderedListStyle: orderedListStyle,
      paragraphStyle: paragraphStyle,
      tableStyle: tableStyle,
      inlineStyle: inlineStyle,
      textContextMenu: textContextMenu,
      citationConfig: citationConfig,
      blockSpacing: blockSpacing,
      regexHighlights: regexHighlights,
      quoteHighlightFont: quoteHighlightFont,
      quoteHighlightColor: quoteHighlightColor,
      imageRenderer: imageRenderer,
      reservedImageAspectRatio: reservedImageAspectRatio
    )
  }

  /// Returns a copy with `blockQuoteStyle` replaced.
  public func withBlockQuoteStyle(value: MarkdownTextStyle) -> MarkdownRenderConfig {
    MarkdownRenderConfig(
      shouldAnimateText: shouldAnimateText,
      blockQuoteStyle: value,
      headingStyle: headingStyle,
      orderedListStyle: orderedListStyle,
      paragraphStyle: paragraphStyle,
      tableStyle: tableStyle,
      inlineStyle: inlineStyle,
      textContextMenu: textContextMenu,
      citationConfig: citationConfig,
      blockSpacing: blockSpacing,
      regexHighlights: regexHighlights,
      quoteHighlightFont: quoteHighlightFont,
      quoteHighlightColor: quoteHighlightColor,
      imageRenderer: imageRenderer,
      reservedImageAspectRatio: reservedImageAspectRatio
    )
  }

  /// Returns a copy with `headingStyle` replaced.
  public func withHeadingStyle(value: MarkdownHeadingTextStyle) -> MarkdownRenderConfig {
    MarkdownRenderConfig(
      shouldAnimateText: shouldAnimateText,
      blockQuoteStyle: blockQuoteStyle,
      headingStyle: value,
      orderedListStyle: orderedListStyle,
      paragraphStyle: paragraphStyle,
      tableStyle: tableStyle,
      inlineStyle: inlineStyle,
      textContextMenu: textContextMenu,
      citationConfig: citationConfig,
      blockSpacing: blockSpacing,
      regexHighlights: regexHighlights,
      quoteHighlightFont: quoteHighlightFont,
      quoteHighlightColor: quoteHighlightColor,
      imageRenderer: imageRenderer,
      reservedImageAspectRatio: reservedImageAspectRatio
    )
  }

  /// Returns a copy with `orderedListStyle` replaced.
  public func withOrderedListStyle(value: MarkdownTextStyle) -> MarkdownRenderConfig {
    MarkdownRenderConfig(
      shouldAnimateText: shouldAnimateText,
      blockQuoteStyle: blockQuoteStyle,
      headingStyle: headingStyle,
      orderedListStyle: value,
      paragraphStyle: paragraphStyle,
      tableStyle: tableStyle,
      inlineStyle: inlineStyle,
      textContextMenu: textContextMenu,
      citationConfig: citationConfig,
      blockSpacing: blockSpacing,
      regexHighlights: regexHighlights,
      quoteHighlightFont: quoteHighlightFont,
      quoteHighlightColor: quoteHighlightColor,
      imageRenderer: imageRenderer,
      reservedImageAspectRatio: reservedImageAspectRatio
    )
  }

  /// Returns a copy with `paragraphStyle` replaced.
  public func withParagraphStyle(value: MarkdownTextStyle) -> MarkdownRenderConfig {
    MarkdownRenderConfig(
      shouldAnimateText: shouldAnimateText,
      blockQuoteStyle: blockQuoteStyle,
      headingStyle: headingStyle,
      orderedListStyle: orderedListStyle,
      paragraphStyle: value,
      tableStyle: tableStyle,
      inlineStyle: inlineStyle,
      textContextMenu: textContextMenu,
      citationConfig: citationConfig,
      blockSpacing: blockSpacing,
      regexHighlights: regexHighlights,
      quoteHighlightFont: quoteHighlightFont,
      quoteHighlightColor: quoteHighlightColor,
      imageRenderer: imageRenderer,
      reservedImageAspectRatio: reservedImageAspectRatio
    )
  }

  /// Returns a copy with `tableStyle` replaced.
  public func withTableStyle(value: MarkdownTableTextStyle) -> MarkdownRenderConfig {
    MarkdownRenderConfig(
      shouldAnimateText: shouldAnimateText,
      blockQuoteStyle: blockQuoteStyle,
      headingStyle: headingStyle,
      orderedListStyle: orderedListStyle,
      paragraphStyle: paragraphStyle,
      tableStyle: value,
      inlineStyle: inlineStyle,
      textContextMenu: textContextMenu,
      citationConfig: citationConfig,
      blockSpacing: blockSpacing,
      regexHighlights: regexHighlights,
      quoteHighlightFont: quoteHighlightFont,
      quoteHighlightColor: quoteHighlightColor,
      imageRenderer: imageRenderer,
      reservedImageAspectRatio: reservedImageAspectRatio
    )
  }

  /// Returns a copy with `inlineStyle` replaced.
  public func withInlineStyle(value: MarkdownInlineTextStyle) -> MarkdownRenderConfig {
    MarkdownRenderConfig(
      shouldAnimateText: shouldAnimateText,
      blockQuoteStyle: blockQuoteStyle,
      headingStyle: headingStyle,
      orderedListStyle: orderedListStyle,
      paragraphStyle: paragraphStyle,
      tableStyle: tableStyle,
      inlineStyle: value,
      textContextMenu: textContextMenu,
      citationConfig: citationConfig,
      blockSpacing: blockSpacing,
      regexHighlights: regexHighlights,
      quoteHighlightFont: quoteHighlightFont,
      quoteHighlightColor: quoteHighlightColor,
      imageRenderer: imageRenderer,
      reservedImageAspectRatio: reservedImageAspectRatio
    )
  }

  /// Returns a copy with `textContextMenu` replaced. Pass `nil` to remove the
  /// custom context menu and fall back to the system menu.
  public func withTextContextMenu(value: TextContextMenu?) -> MarkdownRenderConfig {
    MarkdownRenderConfig(
      shouldAnimateText: shouldAnimateText,
      blockQuoteStyle: blockQuoteStyle,
      headingStyle: headingStyle,
      orderedListStyle: orderedListStyle,
      paragraphStyle: paragraphStyle,
      tableStyle: tableStyle,
      inlineStyle: inlineStyle,
      textContextMenu: value,
      citationConfig: citationConfig,
      blockSpacing: blockSpacing,
      regexHighlights: regexHighlights,
      quoteHighlightFont: quoteHighlightFont,
      quoteHighlightColor: quoteHighlightColor,
      imageRenderer: imageRenderer,
      reservedImageAspectRatio: reservedImageAspectRatio
    )
  }

  /// Returns a copy with `blockSpacing` replaced.
  public func withBlockSpacing(value: CGFloat) -> MarkdownRenderConfig {
    MarkdownRenderConfig(
      shouldAnimateText: shouldAnimateText,
      blockQuoteStyle: blockQuoteStyle,
      headingStyle: headingStyle,
      orderedListStyle: orderedListStyle,
      paragraphStyle: paragraphStyle,
      tableStyle: tableStyle,
      inlineStyle: inlineStyle,
      textContextMenu: textContextMenu,
      citationConfig: citationConfig,
      blockSpacing: value,
      regexHighlights: regexHighlights,
      quoteHighlightFont: quoteHighlightFont,
      quoteHighlightColor: quoteHighlightColor,
      imageRenderer: imageRenderer,
      reservedImageAspectRatio: reservedImageAspectRatio
    )
  }

  /// Returns a copy with regex highlights replaced.
  public func withRegexHighlights(value: [RegexHighlight]) -> MarkdownRenderConfig {
    MarkdownRenderConfig(
      shouldAnimateText: shouldAnimateText,
      blockQuoteStyle: blockQuoteStyle,
      headingStyle: headingStyle,
      orderedListStyle: orderedListStyle,
      paragraphStyle: paragraphStyle,
      tableStyle: tableStyle,
      inlineStyle: inlineStyle,
      textContextMenu: textContextMenu,
      citationConfig: citationConfig,
      blockSpacing: blockSpacing,
      regexHighlights: value,
      quoteHighlightFont: quoteHighlightFont,
      quoteHighlightColor: quoteHighlightColor,
      imageRenderer: imageRenderer,
      reservedImageAspectRatio: reservedImageAspectRatio
    )
  }

  /// Returns a copy with quote highlight styling replaced.
  public func withQuoteHighlightStyle(font: UIFont, color: Color) -> MarkdownRenderConfig {
    MarkdownRenderConfig(
      shouldAnimateText: shouldAnimateText,
      blockQuoteStyle: blockQuoteStyle,
      headingStyle: headingStyle,
      orderedListStyle: orderedListStyle,
      paragraphStyle: paragraphStyle,
      tableStyle: tableStyle,
      inlineStyle: inlineStyle,
      textContextMenu: textContextMenu,
      citationConfig: citationConfig,
      blockSpacing: blockSpacing,
      regexHighlights: regexHighlights,
      quoteHighlightFont: font,
      quoteHighlightColor: color,
      imageRenderer: imageRenderer,
      reservedImageAspectRatio: reservedImageAspectRatio
    )
  }

  /// Returns a copy with image rendering configuration replaced.
  public func withImageRenderer(
    value: MarkdownImageRenderer?,
    reservedAspectRatio: CGFloat? = nil
  ) -> MarkdownRenderConfig {
    MarkdownRenderConfig(
      shouldAnimateText: shouldAnimateText,
      blockQuoteStyle: blockQuoteStyle,
      headingStyle: headingStyle,
      orderedListStyle: orderedListStyle,
      paragraphStyle: paragraphStyle,
      tableStyle: tableStyle,
      inlineStyle: inlineStyle,
      textContextMenu: textContextMenu,
      citationConfig: citationConfig,
      blockSpacing: blockSpacing,
      regexHighlights: regexHighlights,
      quoteHighlightFont: quoteHighlightFont,
      quoteHighlightColor: quoteHighlightColor,
      imageRenderer: value,
      reservedImageAspectRatio: reservedAspectRatio ?? reservedImageAspectRatio
    )
  }
}
