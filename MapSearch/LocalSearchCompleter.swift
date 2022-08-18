import Combine
import ComposableArchitecture
import MapKit

struct LocalSearchCompleter {
  // var search: (String) -> Effect<[MKLocalSearchCompletion], Error>
  var completions: () -> Effect<Result<[MKLocalSearchCompletion], Error>, Never>
  var search: (String) -> Effect<Never, Never>
}

extension LocalSearchCompleter {
  static var live: Self {
    
    class Delegate: NSObject, MKLocalSearchCompleterDelegate {
      
      let subscriber: Effect<Result<[MKLocalSearchCompletion], Error>, Never>.Subscriber
      
      init(subscriber: Effect<Result<[MKLocalSearchCompletion], Error>, Never>.Subscriber) {
        self.subscriber = subscriber
      }
      
      func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.subscriber.send(.success(completer.results))
      }
      
      func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.subscriber.send(.failure(error))
      }
    }
    
    let completer = MKLocalSearchCompleter()
    
    return Self(
      completions: {
        // the run method is how we create a long living effect...
        // you can use the subscriber to send it data as much as you want
        // kind of tool to bridge non-publisher code with publisher code.
        // in the future we may be able to get rid of Effect.run and just use an async stream provided in swift 5.5
        Effect.run { subscriber in
          let delegate = Delegate(subscriber: subscriber)
          completer.delegate = delegate
          
          // we need to return AnyCancellabel inside Effect.run in order to free up any resources when the effect is turned down.
          return AnyCancellable {
            // we're doing this because the `MKLocalSearchCompleterDelegate` on completer holds a weak reference and we want to keep the Delegate instance we created around as long as the Effect lives.
            _ = delegate
          }
        }
      },
      search: { query in
          .fireAndForget {
            completer.queryFragment = query
          }
      }
    )
  }
}
