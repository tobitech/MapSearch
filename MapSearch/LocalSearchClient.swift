import ComposableArchitecture
import MapKit

struct LocalSearchClient {
  var search: (MKLocalSearchCompletion) -> Effect<MKLocalSearch.Response, Error>
}

extension LocalSearchClient {
  static let live = Self(
    search: { completion in
      Effect.future { callback in
        
        // spin up a new async context.
        // Task is a unit of asynchronous work.
        // This was introduced in Swift 5 iOS 13+
        Task {
          do {
            let response = try await MKLocalSearch(request: .init(completion: completion))
              .start()
            callback(.success(response))
          } catch {
            callback(.failure(error))
          }
        }
        
      }
    }
  )
}
