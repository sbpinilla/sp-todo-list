import Foundation
import Testing
import TodoApplication
import TodoDomain
@testable import TodoInfrastructure

@Suite struct JSONTodoRepositoryTests {
    private func withTempDirectory(_ body: (URL) throws -> Void) throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("sp-todo-list-tests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        try body(dir)
    }

    private func contents(of dir: URL) -> [String] {
        ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? []).sorted()
    }

    @Test func roundTripPreservesItemsAndOrder() throws {
        try withTempDirectory { dir in
            let repo = JSONTodoRepository(directory: dir)
            let items = [
                TodoItem(title: "b", isDone: true, createdAt: Date(timeIntervalSince1970: 1_700_000_000)),
                TodoItem(title: "a", createdAt: Date(timeIntervalSince1970: 1_700_000_100)),
                TodoItem(title: "c", createdAt: Date(timeIntervalSince1970: 1_700_000_200)),
            ]
            try repo.save(items)
            let loaded = try JSONTodoRepository(directory: dir).load()
            #expect(loaded == items)
        }
    }

    @Test func missingFileReturnsEmptyList() throws {
        try withTempDirectory { dir in
            let loaded = try JSONTodoRepository(directory: dir).load()
            #expect(loaded.isEmpty)
        }
    }

    @Test func saveCreatesMissingDirectory() throws {
        try withTempDirectory { dir in
            let nested = dir.appendingPathComponent("a/b", isDirectory: true)
            try JSONTodoRepository(directory: nested).save([TodoItem(title: "x")])
            #expect(contents(of: nested) == ["todos.json"])
        }
    }

    @Test func fileHasVersionedEnvelope() throws {
        try withTempDirectory { dir in
            try JSONTodoRepository(directory: dir).save([TodoItem(title: "x")])
            let data = try Data(contentsOf: dir.appendingPathComponent("todos.json"))
            let object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
            #expect(object["version"] as? Int == 1)
            #expect((object["items"] as? [Any])?.count == 1)
        }
    }

    @Test func corruptFileIsQuarantinedAndReturnsEmpty() throws {
        try withTempDirectory { dir in
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let garbage = Data("not json {".utf8)
            try garbage.write(to: dir.appendingPathComponent("todos.json"))
            let repo = JSONTodoRepository(directory: dir, now: { Date(timeIntervalSince1970: 1_700_000_000) })

            let loaded = try repo.load()
            #expect(loaded.isEmpty)

            let names = contents(of: dir)
            #expect(!names.contains("todos.json"))
            let corrupt = try #require(names.first { $0.hasPrefix("todos.corrupt-") && $0.hasSuffix(".json") })
            let kept = try Data(contentsOf: dir.appendingPathComponent(corrupt))
            #expect(kept == garbage)
        }
    }

    @Test func corruptQuarantineIsNeverOverwritten() throws {
        try withTempDirectory { dir in
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let repo = JSONTodoRepository(directory: dir, now: { Date(timeIntervalSince1970: 1_700_000_000) })
            for text in ["bad one", "bad two"] {
                try Data(text.utf8).write(to: dir.appendingPathComponent("todos.json"))
                let loaded = try repo.load()
                #expect(loaded.isEmpty)
            }
            #expect(contents(of: dir).filter { $0.hasPrefix("todos.corrupt-") }.count == 2)
        }
    }

    @Test func saveOverwritesAtomicallyWithoutLeftovers() throws {
        try withTempDirectory { dir in
            let repo = JSONTodoRepository(directory: dir)
            try repo.save([TodoItem(title: "one", createdAt: Date(timeIntervalSince1970: 1_700_000_000))])
            let second = [TodoItem(title: "two", createdAt: Date(timeIntervalSince1970: 1_700_000_000.5))]
            try repo.save(second)
            let loaded = try repo.load()
            #expect(loaded == second)
            #expect(contents(of: dir) == ["todos.json"])
        }
    }

    @Test func defaultDirectoryIsApplicationSupportSpTodoList() {
        let url = JSONTodoRepository.defaultDirectory
        #expect(url.lastPathComponent == "sp-todo-list")
        #expect(url.deletingLastPathComponent().lastPathComponent == "Application Support")
    }
}
