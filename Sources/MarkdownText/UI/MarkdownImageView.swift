//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License. See LICENSE in the project root for license information.
//

import SwiftUI
import UIKit

struct MarkdownImageBlockView: View {
  @Environment(\.markdownConfig) var config: MarkdownRenderConfig

  let image: MarkdownImage

  var body: some View {
    if let imageRenderer = config.imageRenderer {
      imageRenderer(image)
    } else {
      DefaultMarkdownImageView(
        image: image,
        reservedAspectRatio: config.reservedImageAspectRatio
      )
    }
  }
}

public struct DefaultMarkdownImageView: View {
  public let image: MarkdownImage
  public let reservedAspectRatio: CGFloat
  @State private var phase: DefaultMarkdownImagePhase = .empty

  public init(image: MarkdownImage, reservedAspectRatio: CGFloat = MarkdownRenderConfig.defaultReservedImageAspectRatio) {
    self.image = image
    self.reservedAspectRatio = reservedAspectRatio
  }

  public var body: some View {
    Color.clear
      .frame(maxWidth: .infinity)
      .aspectRatio(phase.aspectRatio ?? reservedAspectRatio, contentMode: .fit)
      .overlay {
        phaseView
      }
      .task(id: image.source) {
        phase = .empty
        phase = await DefaultMarkdownImageStore.shared.image(from: image.source)
      }
      .accessibilityLabel(image.alt ?? "")
  }

  @ViewBuilder
  private var phaseView: some View {
    switch phase {
    case .empty:
      ProgressView()
    case .success(let image, _):
      image
        .resizable()
        .scaledToFit()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    case .failure:
      Image(systemName: "photo")
        .imageScale(.large)
        .foregroundStyle(.secondary)
    }
  }
}

private enum DefaultMarkdownImagePhase {
  case empty
  case success(Image, aspectRatio: CGFloat)
  case failure

  var aspectRatio: CGFloat? {
    switch self {
    case .success(_, let aspectRatio):
      return aspectRatio
    case .empty, .failure:
      return nil
    }
  }
}

@MainActor
private final class DefaultMarkdownImageStore {
  static let shared = DefaultMarkdownImageStore()

  private var cachedImages: [URL: DefaultMarkdownImagePhase] = [:]

  func image(from url: URL) async -> DefaultMarkdownImagePhase {
    if let image = cachedImages[url] {
      return image
    }

    do {
      let data = try await DefaultMarkdownImageLoader.shared.data(from: url)
      guard let cachedImage = CachedMarkdownImage(data: data) else {
        cachedImages[url] = nil
        return .failure
      }

      let phase = DefaultMarkdownImagePhase.success(cachedImage.image, aspectRatio: cachedImage.aspectRatio)
      cachedImages[url] = phase
      return phase
    } catch {
      return .failure
    }
  }
}

private actor DefaultMarkdownImageLoader {
  static let shared = DefaultMarkdownImageLoader()

  private var cachedData: [URL: Data] = [:]
  private var inFlightRequests: [URL: Task<Data, Error>] = [:]

  func data(from url: URL) async throws -> Data {
    if let data = cachedData[url] {
      return data
    }

    if let request = inFlightRequests[url] {
      return try await request.value
    }

    let request = Task<Data, Error> {
      let (data, response) = try await URLSession.shared.data(from: url)

      guard let httpResponse = response as? HTTPURLResponse else {
        return data
      }

      guard (200..<300).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
      }

      return data
    }

    inFlightRequests[url] = request

    do {
      let data = try await request.value
      cachedData[url] = data
      inFlightRequests[url] = nil
      return data
    } catch {
      inFlightRequests[url] = nil
      throw error
    }
  }
}

private struct CachedMarkdownImage {
  let image: Image
  let aspectRatio: CGFloat

  @MainActor
  init?(data: Data) {
    guard let image = UIImage(data: data), image.size.width > 0, image.size.height > 0 else {
      return nil
    }

    self.image = Image(uiImage: image)
    self.aspectRatio = image.size.width / image.size.height
  }
}
