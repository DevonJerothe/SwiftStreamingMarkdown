//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License. See LICENSE in the project root for license information.
//

import Foundation
import Markdown
import SwiftUI
import UIKit

extension Paragraph: BlockConvertible {

  func convert(attributeContainer: NSAttributeContainer, config: MarkdownRenderConfig) -> MarkdownRenderable {
    convertParagraph(attributeContainer: attributeContainer, config: config, id: id, children: Array(children))
  }

  func convertRenderables(attributeContainer: NSAttributeContainer, config: MarkdownRenderConfig) -> [MarkdownRenderable] {
    if let image = standaloneImageRenderable {
      return [image]
    }

    let splitRenderables = imageSplitRenderables(attributeContainer: attributeContainer, config: config)
    if !splitRenderables.isEmpty {
      return splitRenderables
    }

    return [convert(attributeContainer: attributeContainer, config: config)]
  }

  private func convertParagraph(
    attributeContainer: NSAttributeContainer,
    config: MarkdownRenderConfig,
    id: String,
    children: [Markup]
  ) -> MarkdownRenderable {
    var container = attributeContainer
    container[.font] = config.paragraphStyle.textFonts.normal
    container[.typography] = config.paragraphStyle.textFonts
    if let kern = config.paragraphStyle.textFonts.preferredLetterSpacing {
      container[.kern] = kern
    }
    container[.foregroundColor] = UIColor(config.paragraphStyle.textColor)
    let paragraphContent = self.buildParagraphContent(children: children, container: container, config: config)
    return MarkdownRenderable.paragraph(id: id, content: paragraphContent)
  }

  private func imageSplitRenderables(attributeContainer: NSAttributeContainer, config: MarkdownRenderConfig) -> [MarkdownRenderable] {
    var pendingChildren: [Markup] = []
    var renderables: [MarkdownRenderable] = []
    var segmentIndex = 0
    var foundLoadableImage = false

    func flushParagraph() {
      guard !pendingChildren.isEmpty else {
        return
      }

      let paragraph = convertParagraph(
        attributeContainer: attributeContainer,
        config: config,
        id: "\(id)-paragraph-\(segmentIndex)",
        children: pendingChildren
      )

      if case let .paragraph(_, content) = paragraph, content.length > 0 {
        renderables.append(paragraph)
        segmentIndex += 1
      }

      pendingChildren.removeAll()
    }

    for child in children {
      guard let image = child as? Markdown.Image,
            let renderable = image.renderableImage(id: "\(id)-image-\(segmentIndex)")
      else {
        pendingChildren.append(child)
        continue
      }

      foundLoadableImage = true
      flushParagraph()
      renderables.append(renderable)
      segmentIndex += 1
    }

    guard foundLoadableImage else {
      return []
    }

    flushParagraph()
    return renderables
  }

  private var standaloneImageRenderable: MarkdownRenderable? {
    var iterator = children.makeIterator()

    guard childCount == 1,
          let child = iterator.next(),
          iterator.next() == nil,
          let image = child as? Markdown.Image
    else {
      return nil
    }

    return image.renderableImage(id: id)
  }
}

extension BlockMarkup {

  func buildParagraphContent(container: NSAttributeContainer, config: MarkdownRenderConfig) -> NSMutableAttributedString {
    buildParagraphContent(children: Array(children), container: container, config: config)
  }

  func buildParagraphContent(children: [Markup], container: NSAttributeContainer, config: MarkdownRenderConfig) -> NSMutableAttributedString {
    let result = NSMutableAttributedString()

    for child in children {
      guard let convertible = child as? InlineConvertible else {
        continue
      }

      let coder = config.citationConfig.coder
      if config.citationConfig.isEnabled,
         let link = child as? Markdown.Link,
         let destination = link.destination,
         link.isInlineCitation(coder: coder) {

        // Create citation attachment directly during parsing (as suggested by @hanzhouli_microsoft)
        let attachmentData = coder.decode(linkDestination: destination)
        if let attachmentData = attachmentData,
           let attachment = InlineCitationAttachment(citationData: attachmentData, citationConfig: config.citationConfig) {
          let attachmentString = NSMutableAttributedString(attachment: attachment)
          attachmentString.addAttribute(
            .markdownAllowsRegexHighlight,
            value: false,
            range: NSRange(location: 0, length: attachmentString.length)
          )

          // Add link attribute for accessibility activation (space key)
          let url = attachmentData.url
          attachmentString.addAttribute(
            .link,
            value: url,
            range: NSRange(location: 0, length: attachmentString.length)
          )

          // Apply baseline offset to the attachment using the font from config
          attachmentString.addAttribute(
            .baselineOffset,
            value: config.paragraphStyle.textFonts.normal.descender,
            range: NSRange(location: 0, length: attachmentString.length)
          )

          // Add the citation directly to result
          result.append(attachmentString)
        }
      } else {
        let stringPart = convertible.convert(attributeContainer: container, config: config)
        result.append(stringPart)
      }
    }

    return result.applyingRegexHighlights(config: config)
  }
}

private extension Markdown.Image {
  func renderableImage(id: String) -> MarkdownRenderable? {
    guard let source,
          let url = URL.fromMixedEncodingString(source),
          url.scheme != nil
    else {
      return nil
    }

    let alt = plainText
    return .image(id: id, source: url, alt: alt.isEmpty ? nil : alt)
  }
}
