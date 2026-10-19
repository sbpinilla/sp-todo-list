import Foundation
import TodoApplication
import TodoDomain

/// File-backed `TodoRepository` storing a versioned JSON envelope.
public struct JSONTodoRepository: TodoRepository {
    private struct Envelope: Codable {
        var version: Int
        var items: [TodoItem]
    }

    private static let currentVersion = 1
    private static let fileName = "todos.json"

    /// ISO 8601 with millisecond precision.
    private static let dateFormat = Date.ISO8601FormatStyle(includingFractionalSeconds: true)

    private let directory: URL
    private let now: @Sendable () -> Date

    /// `~/Library/Application Support/sp-todo-list` (decision O2).
    public static var defaultDirectory: URL {
        FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("sp-todo-list", isDirectory: true)
    }

    public init(
        directory: URL = JSONTodoRepository.defaultDirectory,
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.directory = directory
        self.now = now
    }

    private var fileURL: URL { directory.appendingPathComponent(Self.fileName) }

    public func load() throws -> [TodoItem] {
        let fm = FileManager.default
        guard fm.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        do {
            let envelope = try Self.makeDecoder().decode(Envelope.self, from: data)
            guard envelope.version == Self.currentVersion else {
                throw CocoaError(.coderInvalidValue)
            }
            return envelope.items
        } catch {
            try quarantineCorruptFile()
            return []
        }
    }

    public func save(_ items: [TodoItem]) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try Self.makeEncoder().encode(Envelope(version: Self.currentVersion, items: items))
        try data.write(to: fileURL, options: .atomic)
    }

    private func quarantineCorruptFile() throws {
        let fm = FileManager.default
        let stamp = Self.timestamp(now())
        var target = directory.appendingPathComponent("todos.corrupt-\(stamp).json")
        var counter = 1
        while fm.fileExists(atPath: target.path) {
            target = directory.appendingPathComponent("todos.corrupt-\(stamp)-\(counter).json")
            counter += 1
        }
        try fm.moveItem(at: fileURL, to: target)
    }

    private static func timestamp(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: date).replacingOccurrences(of: ":", with: "-")
    }

    private static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, enc in
            var container = enc.singleValueContainer()
            try container.encode(date.formatted(Self.dateFormat))
        }
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { dec in
            let container = try dec.singleValueContainer()
            return try Date(try container.decode(String.self), strategy: Self.dateFormat)
        }
        return decoder
    }
}
