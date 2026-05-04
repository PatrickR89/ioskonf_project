import Foundation
import OSLog

enum BackendLogger {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "io.iosKonf.dAIly-drip",
        category: "Backend"
    )

    static func info(_ message: String, metadata: [String: CustomStringConvertible?] = [:]) {
        log("INFO", message: message, metadata: metadata)
    }

    static func warning(_ message: String, metadata: [String: CustomStringConvertible?] = [:]) {
        log("WARNING", message: message, metadata: metadata)
    }

    static func error(
        _ message: String,
        error: Error? = nil,
        metadata: [String: CustomStringConvertible?] = [:]
    ) {
        var fields = metadata
        if let error {
            fields.merge(errorMetadata(error), uniquingKeysWith: { current, _ in current })
        }
        log("ERROR", message: message, metadata: fields)
    }

    static func preview(_ value: String, maxLength: Int = 600) -> String {
        let singleLineValue = value
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")

        guard singleLineValue.count > maxLength else {
            return singleLineValue
        }

        return "\(singleLineValue.prefix(maxLength))..."
    }

    private static func log(
        _ level: String,
        message: String,
        metadata: [String: CustomStringConvertible?]
    ) {
        let metadataText = metadata
            .compactMapValues { $0?.description }
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")

        let line = metadataText.isEmpty
            ? "[\(level)] \(message)"
            : "[\(level)] \(message) \(metadataText)"

        switch level {
        case "ERROR":
            logger.error("\(line, privacy: .public)")
        case "WARNING":
            logger.warning("\(line, privacy: .public)")
        default:
            logger.info("\(line, privacy: .public)")
        }

        debugPrint("BackendLogger \(line)")
    }

    private static func errorMetadata(_ error: Error) -> [String: CustomStringConvertible?] {
        let nsError = error as NSError
        var metadata: [String: CustomStringConvertible?] = [
            "errorType": String(reflecting: type(of: error)),
            "errorDomain": nsError.domain,
            "errorCode": nsError.code,
            "localizedDescription": nsError.localizedDescription,
            "failureReason": nsError.localizedFailureReason,
            "recoverySuggestion": nsError.localizedRecoverySuggestion,
        ]

        let userInfo = nsError.userInfo
            .filter { key, _ in key != NSUnderlyingErrorKey }
            .map { key, value in "\(key)=\(preview(String(describing: value)))" }
            .sorted()
            .joined(separator: "; ")

        if !userInfo.isEmpty {
            metadata["userInfo"] = userInfo
        }

        if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? Error {
            let underlyingNSError = underlyingError as NSError
            metadata["underlyingDomain"] = underlyingNSError.domain
            metadata["underlyingCode"] = underlyingNSError.code
            metadata["underlyingDescription"] = underlyingNSError.localizedDescription
        }

        return metadata
    }
}
