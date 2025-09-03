@testable import SerializerDemo
import Foundation
import Testing
import WaitWhile

@MainActor
struct SerializerTests {
    @Test("serializer serializes `vend` values into the configured handler")
    func serializer() async {
        let subject = Serializer<Int>()
        var values = [Int]()
        await subject.startStream { @MainActor value in
            try? await Task.sleep(for: .seconds(0.2))
            values.append(value)
        }
        await subject.vend(1)
        await subject.vend(2)
        await subject.vend(3)
        await #while(values.count < 2)
        #expect(values == [1, 2])
    }

    @Test("throwing into the handler ends the stream")
    func throwing() async {
        let subject = Serializer<Int>()
        var values = [Int]()
        await subject.startStream { @MainActor value in
            try? await Task.sleep(for: .seconds(0.2))
            values.append(value)
            if values.count > 0 {
                throw NSError(domain: "die", code: 0)
            }
        }
        await subject.vend(1)
        await subject.vend(2)
        await subject.vend(3)
        try? await Task.sleep(for: .seconds(0.5))
        #expect(values == [1])
    }

    @Test("cancel: ends the stream")
    func cancel() async {
        let subject = Serializer<Int>()
        var values = [Int]()
        await subject.startStream { @MainActor value in
            try? await Task.sleep(for: .seconds(0.2))
            values.append(value)
        }
        await subject.vend(1)
        await subject.vend(2)
        await subject.vend(3)
        await subject.cancel()
        try? await Task.sleep(for: .seconds(0.5))
        #expect(values == [])
    }
}
