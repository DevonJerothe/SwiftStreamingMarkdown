//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License. See LICENSE in the project root for license information.
//

import Foundation
import Markdown
import SwiftUI

extension Markdown.Document {

  func convert(with config: MarkdownRenderConfig) -> [MarkdownRenderable] {
    return self
      .blockConvertibleChildren
      .flatMap { block in
        if let paragraph = block as? Paragraph {
          return paragraph.convertRenderables(attributeContainer: NSAttributeContainer(), config: config)
        }

        return [block.convert(attributeContainer: NSAttributeContainer(), config: config)]
      }
  }
}
