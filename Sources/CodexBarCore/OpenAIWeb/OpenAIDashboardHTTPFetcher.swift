#if !os(macOS)
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@MainActor
public struct OpenAIDashboardFetcher {
    public enum FetchError: LocalizedError, Sendable {
        case loginRequired
        case noDashboardData(body: String)

        public var errorDescription: String? {
            switch self {
            case .loginRequired:
                "OpenAI web access requires login."
            case let .noDashboardData(body):
                "OpenAI dashboard data not found. Body sample: \(body.prefix(200))"
            }
        }
    }

    private let usageURL = URL(string: "https://chatgpt.com/codex/settings/usage")!

    public init() {}

    public func loadLatestDashboard(
        cookieHeader: String,
        logger: ((String) -> Void)? = nil,
        debugDumpHTML: Bool = false,
        timeout: TimeInterval = 60) async throws -> OpenAIDashboardSnapshot
    {
        let trimmed = cookieHeader.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw FetchError.loginRequired
        }

        let response = try await Self.fetchHTML(
            url: self.usageURL,
            cookieHeader: trimmed,
            timeout: timeout,
            logger: logger)
        if response.finalURL.contains("/login") || response.finalURL.contains("/auth") {
            if debugDumpHTML {
                Self.writeDebugArtifacts(html: response.html, logger: logger)
            }
            throw FetchError.loginRequired
        }
        let authStatus = OpenAIDashboardParser.parseAuthStatusFromClientBootstrap(html: response.html)
        if authStatus?.lowercased() == "logged_out" {
            if debugDumpHTML {
                Self.writeDebugArtifacts(html: response.html, logger: logger)
            }
            throw FetchError.loginRequired
        }

        let bodyText = OpenAIDashboardHTMLScraper.bodyText(from: response.html)
        let rateLimits = OpenAIDashboardParser.parseRateLimits(bodyText: bodyText)
        let creditsRemaining = OpenAIDashboardParser.parseCreditsRemaining(bodyText: bodyText)
        let codeReview = OpenAIDashboardParser.parseCodeReviewRemainingPercent(bodyText: bodyText)
        let rows = OpenAIDashboardHTMLScraper.creditHistoryRows(from: response.html)
        let events = OpenAIDashboardParser.parseCreditEvents(rows: rows)
        let dailyBreakdown = OpenAIDashboardSnapshot.makeDailyBreakdown(from: events, maxDays: 30)
        let accountPlan = OpenAIDashboardParser.parsePlanFromHTML(html: response.html)
        let signedInEmail = OpenAIDashboardParser.parseSignedInEmailFromClientBootstrap(html: response.html)

        if rateLimits.primary == nil,
           rateLimits.secondary == nil,
           creditsRemaining == nil,
           codeReview == nil,
           events.isEmpty
        {
            if debugDumpHTML {
                Self.writeDebugArtifacts(html: response.html, logger: logger)
            }
            throw FetchError.noDashboardData(body: bodyText)
        }

        return OpenAIDashboardSnapshot(
            signedInEmail: signedInEmail,
            accountPlan: accountPlan,
            creditsRemaining: creditsRemaining,
            creditsUpdatedAt: Date(),
            dailyBreakdown: dailyBreakdown,
            usageBreakdown: [],
            codeReviewRemainingPercent: codeReview,
            primaryRateLimit: rateLimits.primary,
            secondaryRateLimit: rateLimits.secondary,
            creditsPurchaseURL: nil)
    }

    private struct HTMLResponse {
        let html: String
        let finalURL: String
        let statusCode: Int
    }

    private static func fetchHTML(
        url: URL,
        cookieHeader: String,
        timeout: TimeInterval,
        logger: ((String) -> Void)?) async throws -> HTMLResponse
    {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = timeout
        request.setValue(cookieHeader, forHTTPHeaderField: "Cookie")
        request.setValue(
            "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            forHTTPHeaderField: "Accept")
        request.setValue(
            "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) " +
                "Chrome/120.0.0.0 Safari/537.36",
            forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? -1
        let finalURL = response.url?.absoluteString ?? url.absoluteString
        logger?("OpenAI web status=\(status) url=\(finalURL)")

        if status == 401 || status == 403 {
            throw FetchError.loginRequired
        }
        let html = String(data: data, encoding: .utf8) ?? ""
        if html.isEmpty {
            throw FetchError.noDashboardData(body: "")
        }
        return HTMLResponse(html: html, finalURL: finalURL, statusCode: status)
    }

    private static func writeDebugArtifacts(html: String, logger: ((String) -> Void)?) {
        let stamp = ISO8601DateFormatter().string(from: Date())
        let dir = FileManager.default.temporaryDirectory
        let htmlURL = dir.appendingPathComponent("codex-openai-dashboard-\(stamp).html")
        do {
            try html.write(to: htmlURL, atomically: true, encoding: .utf8)
            logger?("Dumped HTML: \(htmlURL.path)")
        } catch {
            logger?("Failed to dump HTML: \(error.localizedDescription)")
        }
    }
}
#endif
