import ComposableArchitecture
import MapKit

struct LocalSearchClient {
  var search: (MKLocalSearchCompletion) -> Effect<MKLocalSearch.Response, Error>
}

extension LocalSearchClient {
  static let live = Self(
    search: { completion in
      
      Effect.task {
        try await MKLocalSearch(request: .init(completion: completion))
          .start()
      }
      
//      Effect.future { callback in
//
//        // spin up a new async context.
//        // Task is a unit of asynchronous work.
//        // This was introduced in Swift 5 iOS 13+
//        Task {
//          do {
//            let response = try await MKLocalSearch(request: .init(completion: completion))
//              .start()
//            callback(.success(response))
//          } catch {
//            callback(.failure(error))
//          }
//        }
//      }
      
    }
  )
}

extension Effect {
  static func task(
    priority: TaskPriority? = nil,
    operation: @escaping @Sendable () async throws -> Output
  ) -> Effect
  where Failure == Error {
    .future { callback in
      Task(priority: priority) {
        do {
          let response = try await operation()
          callback(.success(response))
        } catch {
          callback(.failure(error))
        }
      }
      
    }
  }
}
