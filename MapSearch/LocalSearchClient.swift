import ComposableArchitecture
import MapKit

struct LocalSearchClient {
  var search: (MKLocalSearchCompletion) -> Effect<MKLocalSearch.Response, Error>
}

extension LocalSearchClient {
  static let live = Self(
    search: { completion in
      Effect.future { callback in
        MKLocalSearch(request: .init(completion: completion))
          .start { response, error in
            if let response = response {
              callback(.success(response))
            } else if let error = error {
              callback(.failure(error))
            } else {
              fatalError()
            }
          }
      }
    }
  )
}
