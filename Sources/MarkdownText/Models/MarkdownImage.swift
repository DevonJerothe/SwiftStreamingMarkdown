//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License. See LICENSE in the project root for license information.
//

import Foundation
import SwiftUI

public struct MarkdownImage: Equatable, Sendable {
  public let source: URL
  public let alt: String?

  public init(source: URL, alt: String? = nil) {
    self.source = source
    self.alt = alt
  }
}

public typealias MarkdownImageRenderer = @MainActor @Sendable (MarkdownImage) -> AnyView
