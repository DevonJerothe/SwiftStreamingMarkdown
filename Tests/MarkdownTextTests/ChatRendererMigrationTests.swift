//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License. See LICENSE in the project root for license information.
//

@testable import SwiftStreamingMarkdown
import SwiftUI
import UIKit
import XCTest

final class ChatRendererMigrationTests: XCTestCase {

  func testStandaloneMarkdownImageCreatesImageRenderable() {
    let document = RenderableDocument.readSync("![Wave](https://example.com/wave.png)")

    XCTAssertEqual(document.renderables.count, 1)
    guard case let .image(_, source, alt) = document.renderables[0] else {
      XCTFail("Expected standalone image markdown to produce an image renderable")
      return
    }

    XCTAssertEqual(source, URL(string: "https://example.com/wave.png"))
    XCTAssertEqual(alt, "Wave")
  }

  func testInvalidStandaloneImageFallsBackToAltText() {
    let document = RenderableDocument.readSync("![Wave]()")

    XCTAssertEqual(document.renderables.count, 1)
    guard case let .paragraph(_, content) = document.renderables[0] else {
      XCTFail("Expected invalid image markdown to fall back to paragraph alt text")
      return
    }

    XCTAssertEqual(content.string, "Wave")
  }

  func testInlineImageSplitsIntoImageBlock() {
    let document = RenderableDocument.readSync("Before ![Wave](https://example.com/wave.png) after")

    XCTAssertEqual(document.renderables.count, 3)
    guard case let .paragraph(_, content) = document.renderables[0] else {
      XCTFail("Expected text before inline image to remain a paragraph")
      return
    }

    XCTAssertEqual(content.string, "Before ")

    guard case let .image(_, source, alt) = document.renderables[1] else {
      XCTFail("Expected inline image markdown to produce an image block")
      return
    }

    XCTAssertEqual(source, URL(string: "https://example.com/wave.png"))
    XCTAssertEqual(alt, "Wave")

    guard case let .paragraph(_, trailingContent) = document.renderables[2] else {
      XCTFail("Expected text after inline image to remain a paragraph")
      return
    }

    XCTAssertEqual(trailingContent.string, " after")
  }

  func testInvalidInlineImageFallsBackToAltText() {
    let document = RenderableDocument.readSync("Before ![Wave]() after")

    XCTAssertEqual(document.renderables.count, 1)
    guard case let .paragraph(_, content) = document.renderables[0] else {
      XCTFail("Expected invalid inline image markdown to remain readable paragraph text")
      return
    }

    XCTAssertEqual(content.string, "Before Wave after")
  }

  func testRegexHighlightingDisabledByDefault() {
    let document = RenderableDocument.readSync(#"He said "hello"."#)

    guard case let .paragraph(_, content) = document.renderables.first else {
      XCTFail("Expected paragraph")
      return
    }

    XCTAssertNil(content.foregroundColor(for: #""hello""#))
  }

  func testStandardQuotedSpeechHighlightsStraightAndCurlyQuotes() {
    let config = MarkdownRenderConfig.default
      .withRegexHighlights(value: [.standardQuotedSpeech])
      .withQuoteHighlightStyle(font: .boldSystemFont(ofSize: 19), color: .green)
    let document = RenderableDocument.readSync(#"He said "hello" and “goodbye”."#, config: config)

    guard case let .paragraph(_, content) = document.renderables.first else {
      XCTFail("Expected paragraph")
      return
    }

    XCTAssertEqual(content.font(for: "hello"), config.quoteHighlightFont)
    XCTAssertEqual(content.foregroundColor(for: "hello"), UIColor(config.quoteHighlightColor))
    XCTAssertEqual(content.font(for: "goodbye"), config.quoteHighlightFont)
    XCTAssertEqual(content.foregroundColor(for: "goodbye"), UIColor(config.quoteHighlightColor))
  }

  func testInlineCodeQuotesAreNotHighlighted() {
    let config = MarkdownRenderConfig.default.withRegexHighlights(value: [.standardQuotedSpeech])
    let document = RenderableDocument.readSync(#"Run `"quotedCode"` before "speech"."#, config: config)

    guard case let .paragraph(_, content) = document.renderables.first else {
      XCTFail("Expected paragraph")
      return
    }

    XCTAssertNotEqual(content.foregroundColor(for: "quotedCode"), UIColor(config.quoteHighlightColor))
    XCTAssertEqual(content.foregroundColor(for: "speech"), UIColor(config.quoteHighlightColor))
  }

  func testCustomRegexHighlightAppliesToNormalText() {
    let highlight = RegexHighlight(
      pattern: #"@[A-Za-z0-9_]+"#,
      font: .boldSystemFont(ofSize: 17),
      foregroundColor: .purple
    )
    let config = MarkdownRenderConfig.default.withRegexHighlights(value: [highlight])
    let document = RenderableDocument.readSync("Hello @devon", config: config)

    guard case let .paragraph(_, content) = document.renderables.first else {
      XCTFail("Expected paragraph")
      return
    }

    XCTAssertEqual(content.font(for: "@devon"), highlight.font)
    XCTAssertEqual(content.foregroundColor(for: "@devon"), UIColor(highlight.foregroundColor))
  }

  func testSyncAndAsyncCachedReadsProduceEquivalentRenderables() async {
    let markdown = """
    # Title

    He said "hello".

    ![Wave](https://example.com/wave.png)
    """
    let config = MarkdownRenderConfig.default.withRegexHighlights(value: [.standardQuotedSpeech])

    let syncDocument = RenderableDocument.readSync(markdown, config: config)
    let asyncDocument = await RenderableDocument.read(markdown, config: config)
    let secondSyncDocument = RenderableDocument.readSync(markdown, config: config)

    XCTAssertEqual(syncDocument, asyncDocument)
    XCTAssertEqual(syncDocument, secondSyncDocument)
    XCTAssertFalse(syncDocument.isEmpty)
  }

  func testConfigStoresCustomImageRenderer() {
    let config = MarkdownRenderConfig.default.withImageRenderer(
      value: { image in
        AnyView(Text(image.alt ?? ""))
      },
      reservedAspectRatio: 4 / 3
    )

    XCTAssertNotNil(config.imageRenderer)
    XCTAssertEqual(config.reservedImageAspectRatio, 4 / 3)
  }
}

private extension NSAttributedString {
  func foregroundColor(for substring: String) -> UIColor? {
    guard let range = string.nsRange(of: substring) else {
      return nil
    }

    return attribute(.foregroundColor, at: range.location, effectiveRange: nil) as? UIColor
  }

  func font(for substring: String) -> UIFont? {
    guard let range = string.nsRange(of: substring) else {
      return nil
    }

    return attribute(.font, at: range.location, effectiveRange: nil) as? UIFont
  }
}

private extension String {
  func nsRange(of substring: String) -> NSRange? {
    let range = (self as NSString).range(of: substring)
    guard range.location != NSNotFound else {
      return nil
    }
    return range
  }
}
