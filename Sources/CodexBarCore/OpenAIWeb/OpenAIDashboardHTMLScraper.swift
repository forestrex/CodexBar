#if !os(macOS)
import Foundation

struct OpenAIDashboardHTMLScraper {
    static func bodyText(from html: String) -> String {
        let withoutScripts = html
            .replacingOccurrences(
                of: #"(?is)<script[^>]*>.*?</script>"#,
                with: " ",
                options: .regularExpression)
            .replacingOccurrences(
                of: #"(?is)<style[^>]*>.*?</style>"#,
                with: " ",
                options: .regularExpression)

        var text = withoutScripts
            .replacingOccurrences(of: #"(?i)<br\s*/?>"#, with: "\n", options: .regularExpression)
            .replacingOccurrences(of: #"(?i)</p>"#, with: "\n", options: .regularExpression)
            .replacingOccurrences(of: #"(?i)</div>"#, with: "\n", options: .regularExpression)
            .replacingOccurrences(of: #"(?i)</li>"#, with: "\n", options: .regularExpression)
            .replacingOccurrences(of: #"(?i)</tr>"#, with: "\n", options: .regularExpression)
            .replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        text = Self.decodeHTMLEntities(text)
        text = text.replacingOccurrences(of: #"[ \t\r\f\v]+"#, with: " ", options: .regularExpression)
        text = text.replacingOccurrences(of: #"\n\s+"#, with: "\n", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func creditHistoryRows(from html: String) -> [[String]] {
        guard let tableHTML = self.extractCreditsTableHTML(from: html) else { return [] }
        return self.extractTableRows(from: tableHTML)
    }

    private static func extractCreditsTableHTML(from html: String) -> String? {
        let lower = html.lowercased()
        guard let markerRange = lower.range(of: "credits usage history") else { return nil }
        let searchStart = html.distance(from: html.startIndex, to: markerRange.lowerBound)
        let slice = String(html[html.index(html.startIndex, offsetBy: searchStart)...])
        let regex = try? NSRegularExpression(pattern: #"(?is)<table[^>]*>.*?</table>"#)
        guard let match = regex?.firstMatch(in: slice, range: NSRange(slice.startIndex..<slice.endIndex, in: slice)),
              let range = Range(match.range, in: slice)
        else {
            return nil
        }
        return String(slice[range])
    }

    private static func extractTableRows(from html: String) -> [[String]] {
        guard let rowRegex = try? NSRegularExpression(pattern: #"(?is)<tr[^>]*>(.*?)</tr>"#),
              let cellRegex = try? NSRegularExpression(pattern: #"(?is)<t[dh][^>]*>(.*?)</t[dh]>"#)
        else {
            return []
        }

        let range = NSRange(html.startIndex..<html.endIndex, in: html)
        let rows = rowRegex.matches(in: html, range: range)
        var output: [[String]] = []

        for row in rows {
            guard row.numberOfRanges > 1,
                  let rowRange = Range(row.range(at: 1), in: html)
            else { continue }
            let rowHTML = String(html[rowRange])
            let cellMatches = cellRegex.matches(
                in: rowHTML,
                range: NSRange(rowHTML.startIndex..<rowHTML.endIndex, in: rowHTML))
            let cells = cellMatches.compactMap { match -> String? in
                guard match.numberOfRanges > 1,
                      let cellRange = Range(match.range(at: 1), in: rowHTML)
                else { return nil }
                var text = rowHTML[cellRange]
                    .replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
                text = Self.decodeHTMLEntities(text)
                let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
                return cleaned.isEmpty ? nil : cleaned
            }
            if !cells.isEmpty {
                output.append(cells)
            }
        }

        return output
    }

    private static func decodeHTMLEntities(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&#10;", with: "\n")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&apos;", with: "'")
    }
}
#endif
