# Chat Renderer Usage

This package should be used as the single Markdown renderer for chat. Use
`SwiftStreamingMarkdown`'s streaming path for the one message that is actively
receiving tokens, and use the cache-backed completed-message path for all
previous messages.

## Build One Shared Render Config

Create one `MarkdownRenderConfig` from your app settings and pass it to every
chat bubble. Reusing the same config is important because completed-message
caching is keyed by the Markdown string and render config.

```swift
import SwiftUI
import UIKit
import SwiftStreamingMarkdown

struct ChatMarkdownSettings: Equatable {
  var bodyFont: UIFont
  var bodyColor: Color
  var quoteFont: UIFont
  var quoteColor: Color
  var linkColor: Color
  var inlineCodeFont: UIFont
  var inlineCodeColor: Color
  var inlineCodeBackgroundColor: Color
  var imageCornerRadius: CGFloat
  var reservedImageAspectRatio: CGFloat
  var highlightSpokenQuotes: Bool
  var customHighlights: [RegexHighlight]
}

extension MarkdownRenderConfig {
  static func chat(settings: ChatMarkdownSettings) -> MarkdownRenderConfig {
    let imageCornerRadius = settings.imageCornerRadius

    let paragraphStyle = MarkdownRenderConfig.MarkdownTextStyle(
      textFonts: TextFonts(
        normal: settings.bodyFont,
        italic: settings.bodyFont.withSymbolicTraits(.traitItalic),
        bold: settings.bodyFont.withSymbolicTraits(.traitBold),
        boldItalic: settings.bodyFont.withSymbolicTraits([.traitBold, .traitItalic]),
        preferredLetterSpacing: nil,
        preferredLineHeight: nil
      ),
      textColor: settings.bodyColor
    )

    let inlineStyle = MarkdownRenderConfig.MarkdownInlineTextStyle(
      boldTextColor: settings.bodyColor,
      linkTextFont: settings.bodyFont,
      linkTextColor: settings.linkColor,
      codeTextFont: settings.inlineCodeFont,
      codeTextColor: settings.inlineCodeColor,
      codeBackgroundColor: settings.inlineCodeBackgroundColor,
      codeUnderlineColor: .clear
    )

    var highlights = settings.customHighlights
    if settings.highlightSpokenQuotes {
      highlights.append(.standardQuotedSpeech)
    }

    return MarkdownRenderConfig.default
      .withParagraphStyle(value: paragraphStyle)
      .withInlineStyle(value: inlineStyle)
      .withRegexHighlights(value: highlights)
      .withQuoteHighlightStyle(
        font: settings.quoteFont,
        color: settings.quoteColor
      )
      .withImageRenderer(
        value: { image in
          AnyView(
            AsyncImage(url: image.source) { phase in
              switch phase {
              case .empty:
                ProgressView()
                  .frame(maxWidth: .infinity)
              case .success(let loadedImage):
                loadedImage
                  .resizable()
                  .scaledToFit()
                  .clipShape(RoundedRectangle(cornerRadius: imageCornerRadius))
              case .failure:
                Image(systemName: "photo")
                  .imageScale(.large)
                  .foregroundStyle(.secondary)
                  .frame(maxWidth: .infinity)
              @unknown default:
                EmptyView()
              }
            }
            .accessibilityLabel(image.alt ?? "")
          )
        },
        reservedAspectRatio: settings.reservedImageAspectRatio
      )
  }
}

private extension UIFont {
  func withSymbolicTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
    guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
      return nil
    }
    return UIFont(descriptor: descriptor, size: pointSize)
  }
}
```

If the default image behavior is enough, omit `withImageRenderer`. The built-in
renderer reserves layout using `reservedImageAspectRatio`, deduplicates in-flight
URL requests, caches decoded images by URL, and updates to the real aspect ratio
after decoding.

If you provide a custom renderer, keep it lightweight and main-actor friendly.
The hook is a `@MainActor @Sendable` closure, so avoid capturing mutable view
models or non-thread-safe services directly. Prefer a small SwiftUI image view
that owns its own loader state.

## Mapping Existing App Theme Values

If the host app currently has a `MarkdownStreamer.MarkdownTheme`, keep the
adapter local to the app target. Do not make `SwiftStreamingMarkdown` depend on
`MarkdownStreamer`.

```swift
extension MarkdownRenderConfig {
  static func chat(theme: MarkdownTheme, imageLoader: ChatImageLoader) -> MarkdownRenderConfig {
    let paragraphStyle = MarkdownRenderConfig.MarkdownTextStyle(
      textFonts: TextFonts(
        normal: theme.bodyFont,
        italic: theme.italicFont,
        bold: theme.boldFont,
        boldItalic: theme.boldItalicFont,
        preferredLetterSpacing: nil,
        preferredLineHeight: theme.lineHeight
      ),
      textColor: theme.bodyColor
    )

    let inlineStyle = MarkdownRenderConfig.MarkdownInlineTextStyle(
      boldTextColor: theme.boldColor,
      linkTextFont: theme.bodyFont,
      linkTextColor: theme.linkColor,
      codeTextFont: theme.inlineCodeFont,
      codeTextColor: theme.inlineCodeColor,
      codeBackgroundColor: theme.inlineCodeBackgroundColor,
      codeUnderlineColor: theme.inlineCodeUnderlineColor
    )

    return MarkdownRenderConfig.default
      .withParagraphStyle(value: paragraphStyle)
      .withInlineStyle(value: inlineStyle)
      .withBlockQuoteStyle(value: theme.blockQuoteStyle)
      .withHeadingStyle(value: theme.headingStyle)
      .withRegexHighlights(value: [.standardQuotedSpeech] + theme.customRegexHighlights)
      .withQuoteHighlightStyle(font: theme.spokenQuoteFont, color: theme.spokenQuoteColor)
      .withImageRenderer(
        value: { image in
          AnyView(ChatMarkdownImageView(image: image, loader: imageLoader))
        },
        reservedAspectRatio: theme.reservedImageAspectRatio
      )
  }
}
```

The exact property names above are illustrative. The important mapping is:

| Existing setting | New config destination |
| --- | --- |
| Body font and color | `MarkdownTextStyle` passed to `withParagraphStyle` |
| Heading fonts and color | `MarkdownHeadingTextStyle` passed to `withHeadingStyle` |
| Bold, link, inline code styling | `MarkdownInlineTextStyle` passed to `withInlineStyle` |
| Block quote font and color | `MarkdownTextStyle` passed to `withBlockQuoteStyle` |
| Spoken quote styling | `withRegexHighlights([.standardQuotedSpeech])` plus `withQuoteHighlightStyle` |
| Custom regex highlights | `withRegexHighlights` |
| Image loading and layout | `withImageRenderer(value:reservedAspectRatio:)` |

## Regex And Spoken Quote Highlighting

Regex highlighting is disabled by default. Add `.standardQuotedSpeech` to enable
spoken quote highlighting for straight and curly double quotes.

```swift
let config = MarkdownRenderConfig.default
  .withRegexHighlights(value: [
    .standardQuotedSpeech,
    RegexHighlight(
      pattern: #"(?i)\bimportant\b"#,
      font: UIFont.preferredFont(forTextStyle: .body),
      foregroundColor: .red
    )
  ])
  .withQuoteHighlightStyle(
    font: UIFont.preferredFont(forTextStyle: .body).withSymbolicTraits(.traitItalic)!,
    color: .purple
  )
```

Highlights are applied after inline Markdown conversion. They are intentionally
not applied inside inline code, links, citations, or LaTeX attachments.

## Chat View Selection

Use `CachedMarkdownView` for completed messages. It parses synchronously during
initialization through `RenderableDocument.readSync`, so existing chat bubbles
can render their first layout immediately and avoid the empty-first-layout pass
of `MarkdownView`.

Use `StreamedMarkdownView` only for the active assistant message that is
currently receiving text. The stream source must emit the full accumulated
Markdown string each time, not just the token delta.

```swift
struct ChatMessage: Identifiable, Equatable {
  enum Role {
    case user
    case assistant
  }

  let id: UUID
  let role: Role
  var markdown: String
  var isStreaming: Bool
}

struct ChatTranscriptView: View {
  let messages: [ChatMessage]
  let streamingSource: StreamedMarkdownSource?
  let markdownConfig: MarkdownRenderConfig
  let listener: MarkdownListener?

  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 12) {
        ForEach(messages) { message in
          ChatBubble(message: message) {
            if message.isStreaming, let streamingSource {
              StreamedMarkdownView(
                source: streamingSource,
                config: markdownConfig.withShouldAnimateText(value: true),
                listener: listener
              )
            } else {
              CachedMarkdownView(
                text: message.markdown,
                config: markdownConfig.withShouldAnimateText(value: false),
                listener: listener
              )
            }
          }
        }
      }
      .padding(.horizontal)
    }
  }
}
```

Recommended chat behavior:

1. Store completed messages as full Markdown strings.
2. Render every completed user and assistant bubble with `CachedMarkdownView`.
3. Render only the currently streaming assistant bubble with `StreamedMarkdownView`.
4. When streaming finishes, replace the streaming bubble with the completed
   Markdown string and let the next render use `CachedMarkdownView`.
5. Keep the same shared `MarkdownRenderConfig` instance or value for the chat
   screen whenever possible, so cache keys remain stable.

## Stream Source Contract

`StreamedMarkdownView` expects complete snapshots:

```swift
final class AssistantStreamSource: StreamedMarkdownSource {
  private let continuation: AsyncStream<String>.Continuation
  let text: AsyncStream<String>

  private var accumulated = ""

  init() {
    var continuation: AsyncStream<String>.Continuation!
    self.text = AsyncStream { continuation = $0 }
    self.continuation = continuation
  }

  func append(delta: String) {
    accumulated += delta
    continuation.yield(accumulated)
  }

  func finish() {
    continuation.finish()
  }
}
```

If the host app receives token updates faster than SwiftUI can animate, throttle
before yielding to the stream source. Keep the default unthrottled behavior until
profiling shows it is necessary.

## Prewarming Completed Messages

For long transcripts or freshly loaded chat history, prewarm completed messages
off the main interaction path by calling the async cache API before the list is
shown.

```swift
func prewarmMarkdown(messages: [ChatMessage], config: MarkdownRenderConfig) async {
  for message in messages where !message.isStreaming {
    _ = await RenderableDocument.read(message.markdown, config: config)
  }
}
```

`CachedMarkdownView` will still work without prewarming. Prewarming just moves
the parse cost earlier and lets the synchronous view initializer hit the shared
cache more often.

## Image Rules

Standalone Markdown images render as image blocks:

```markdown
![Alt text](https://example.com/image.png)
```

Loadable inline images inside a paragraph are split into their own image block.
Text before and after the image remains in paragraph blocks:

```markdown
The screenshot is ![dashboard](https://example.com/dashboard.png) here.
```

Invalid or empty image URLs fall back to alt text instead of crashing. This
keeps chat bubbles readable even when model output contains malformed Markdown.
