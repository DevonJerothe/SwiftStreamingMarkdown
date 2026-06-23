//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License. See LICENSE in the project root for license information.
//

import Foundation
import Markdown
import SwiftUI
import UIKit

/// A `MarkdownRenderConfig`-aware snapshot of a parsed markdown `Document`,
/// ready to be handed to a `MarkdownView` for rendering. Producing one is
/// the heavyweight step; rendering it is cheap.
public struct RenderableDocument: Equatable, Sendable {
  let renderables: [MarkdownRenderable]

  var containsCodeBlock: Bool {
    return renderables.contains(where: { $0.isCodeBlock })
  }

  var containsBlockQuote: Bool {
    return renderables.contains(where: { $0.isBlockQuote })
  }

  var isEmpty: Bool {
    return renderables.isEmpty
  }

  /// Convert a parsed `Document` into a `RenderableDocument` using the supplied config.
  /// - Parameters:
  ///   - document: The parsed markdown tree.
  ///   - config: Styling and behavior used during conversion.
  public init(document: Document, config: MarkdownRenderConfig) async {
    self.renderables = document.convert(with: config)
  }

  init(document: Document, config: MarkdownRenderConfig) {
    self.renderables = document.convert(with: config)
  }

  /// Construct a renderable wrapping a single plain-text paragraph styled
  /// with `config.paragraphStyle`. Useful for showing non-markdown text in a
  /// `MarkdownView` without round-tripping through the parser.
  public init(plainText: String, config: MarkdownRenderConfig) {
    var attributes: [NSAttributedString.Key: Any] = [
      .font: config.paragraphStyle.textFonts.normal,
      .foregroundColor: UIColor(config.paragraphStyle.textColor)
    ]
    if let kern = config.paragraphStyle.textFonts.preferredLetterSpacing {
      attributes[.kern] = kern
    }
    let content = NSMutableAttributedString(string: plainText, attributes: attributes)
    self.init(renderables: [.paragraph(id: UUID().uuidString, content: content)])
  }

  init(renderables: [MarkdownRenderable]) {
    self.renderables = renderables
  }

  /// An empty document, equivalent to `RenderableDocument(plainText: "", …)`
  /// but allocation-free.
  public static let empty = RenderableDocument(renderables: [])

  /// Synchronously parse and convert a completed Markdown string using a shared
  /// cache. Intended for completed chat bubbles where an empty first render can
  /// cause visible list relayout.
  public static func readSync(_ markdown: String, config: MarkdownRenderConfig = .default) -> RenderableDocument {
    RenderableDocumentCache.shared.readSync(markdown, config: config)
  }

  /// Asynchronously parse and convert a completed Markdown string using the same
  /// cache as `readSync`.
  public static func read(_ markdown: String, config: MarkdownRenderConfig = .default) async -> RenderableDocument {
    await RenderableDocumentCache.shared.read(markdown, config: config)
  }
}

extension RenderableDocument {
  var attributedStrings: [NSAttributedString] {
    return renderables.flatMap { $0.extractAttributedStrings() }
  }
}

extension MarkdownRenderable {
  func extractAttributedStrings() -> [NSAttributedString] {
    switch self {
    case .paragraph(_, let str):
      return [str]
    case .orderedList(_, let items):
      return items.flatMap { $0.attributedStrings() }
    case .unorderedList(_, let items, _):
      return items.flatMap { $0.attributedStrings() }
    case .table(_, let headers, let rows, _):
      return headers + rows.flatMap { $0 }
    default:
      return []
    }
  }
}

extension MarkdownListItem {
  func attributedStrings() -> [NSAttributedString] {
    return self.children.flatMap { $0.extractAttributedStrings() }
  }
}

private actor RenderableDocumentCache {
  static let shared = RenderableDocumentCache()

  private struct Key: Hashable {
    let markdown: String
    let config: MarkdownRenderConfig
  }

  private static let syncLock = NSLock()
  nonisolated(unsafe) private static var syncStorage: [Key: RenderableDocument] = [:]

  private var storage: [Key: RenderableDocument] = [:]

  func read(_ markdown: String, config: MarkdownRenderConfig) async -> RenderableDocument {
    let key = Key(markdown: markdown, config: config)

    if let cached = Self.cachedDocument(for: key) {
      return cached
    }

    if let cached = storage[key] {
      return cached
    }

    let document = MarkdownParserImpl().parseSync(text: markdown, config: config)
    storage[key] = document
    Self.store(document, for: key)
    return document
  }

  nonisolated func readSync(_ markdown: String, config: MarkdownRenderConfig) -> RenderableDocument {
    let key = Key(markdown: markdown, config: config)

    if let cached = Self.cachedDocument(for: key) {
      return cached
    }

    let document = MarkdownParserImpl().parseSync(text: markdown, config: config)
    Self.store(document, for: key)
    return document
  }

  private static func cachedDocument(for key: Key) -> RenderableDocument? {
    syncLock.lock()
    defer { syncLock.unlock() }
    return syncStorage[key]
  }

  private static func store(_ document: RenderableDocument, for key: Key) {
    syncLock.lock()
    defer { syncLock.unlock() }
    syncStorage[key] = document
  }
}
