import Foundation

/// Protocol that describes the public face of our Serializer type.
protocol SerializerType<T>: Actor {
    associatedtype T: Sendable
    func startStream(_ handler: @Sendable @escaping (T) async throws -> Void)
    func vend(_ value: T)
    func cancel()
}

/// Actor that embodies serialization of an asynchronously provided value. It holds a closure
/// to which this value will be passed; the closure is `async`. The idea is when a value arrives,
/// it cannot be passed to the closure until the closure finishes waiting for the completion
/// of whatever it does.
actor Serializer<T: Sendable>: SerializerType {
    /// Stream that buffers and vends values.
    /// The subscriber should loop with `for await` to receive values.
    var stream: AsyncStream<T>!

    /// The continuation of the `stream`, unfolded so that we can buffer into the stream.
    var continuation: AsyncStream<T>.Continuation?

    /// Task that will subscribe to the `stream` by looping endless with `for await`.
    var task: Task<Void, Error>?

    /// Create the stream and the task that subscribes to it.
    /// - Parameter handler: What to do inside the loop that fetches values from
    /// the stream. The handler is expected to `await` some long-running process.
    /// The caller can `throw` from within this handler to cancel the subscriber task.
    func startStream(_ handler: @Sendable @escaping (T) async throws -> Void) {
        let stream = AsyncStream<T> { continuation in
            self.continuation = continuation
        }
        self.stream = stream // dance to avoid retain cycle
        self.task = Task<Void, Error> {
            for await value in stream {
                try Task.checkCancellation()
                // This is the heart of serialization. Because we say `await` here, each loop
                // pauses until `handler` finishes before retrieving the next `value` from
                // the `stream`.
                try await handler(value)
                try Task.checkCancellation()
            }
        }
    }

    /// Feed a value into the stream.
    /// - Parameter value: The value.
    func vend(_ value: T) {
        continuation?.yield(value)
    }

    /// Manual way of cancelling the stream and the task.
    func cancel() {
        continuation?.finish()
        task?.cancel()
    }

    /// Automatic way of cancelling the stream and the task.
    deinit {
        print("deinit serializer")
        continuation?.finish()
        task?.cancel()
    }
}
