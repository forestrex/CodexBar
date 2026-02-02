import CodexBarCore
import Foundation
import Testing

#if !os(macOS)
@Suite("OpenAI dashboard HTML scraper")
struct OpenAIDashboardHTMLScraperTests {
    @Test
    func bodyTextStripsMarkup() {
        let html = """
        <html><body>
        <div>Credits remaining 12.5</div>
        <div>5-hour limit 25% remaining</div>
        </body></html>
        """

        let text = OpenAIDashboardHTMLScraper.bodyText(from: html)
        let credits = OpenAIDashboardParser.parseCreditsRemaining(bodyText: text)
        let rateLimits = OpenAIDashboardParser.parseRateLimits(bodyText: text)

        #expect(credits == 12.5)
        #expect(rateLimits.primary != nil)
    }

    @Test
    func creditHistoryRowsExtractsTable() {
        let html = """
        <html><body>
        <h2>Credits usage history</h2>
        <table>
          <tr><th>Date</th><th>Service</th><th>Credits</th></tr>
          <tr><td>Jan 2, 2025</td><td>Codex</td><td>12 credits</td></tr>
        </table>
        </body></html>
        """

        let rows = OpenAIDashboardHTMLScraper.creditHistoryRows(from: html)
        let events = OpenAIDashboardParser.parseCreditEvents(rows: rows)

        #expect(rows.count >= 1)
        #expect(events.count == 1)
        #expect(events.first?.service == "Codex")
    }
}
#endif
