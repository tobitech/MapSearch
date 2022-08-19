import ComposableArchitecture
import MapKit

struct LocalSearchClient {
  var search: (LocalSearchCompletion) -> Effect<Response, Error>
  
  struct Response: Equatable {
    var boundingRegion = CoordinateRegion()
    var mapItems: [MKMapItem] = []
  }
}

extension LocalSearchClient.Response {
  init(rawValue: MKLocalSearch.Response) {
    self.boundingRegion = .init(rawValue: rawValue.boundingRegion)
    self.mapItems = rawValue.mapItems
  }
}

extension LocalSearchClient {
  static let live = Self(
    search: { completion in
      
      Effect.task {
        // we're force unwrapping here because the rawValue should not be nil in production code, only in test code can it be nil
        // and this code is not run in test
        // we can also make the initializer that takes rawValue as the only public initializer while the other init method is made internal for test to access.
        .init(
          rawValue: try await MKLocalSearch(request: .init(completion: completion.rawValue!))
            .start()
        )
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
