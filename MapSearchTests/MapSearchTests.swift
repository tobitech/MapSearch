//
//  MapSearchTests.swift
//  MapSearchTests
//
//  Created by Oluwatobi Omotayo on 19/08/2022.
//

import Combine
import ComposableArchitecture
import MapKit
import XCTest
@testable import MapSearch

class MapSearchTests: XCTestCase {
  
  func testExample() {
    
    let completions = PassthroughSubject<Result<[MKLocalSearchCompletion], Error>, Never>()
    
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment(
        localSearch: .failing,
        localSearchCompleter: .failing,
        mainQueue: .failing
      )
    )
    
    store.environment.localSearchCompleter.completions = { completions.eraseToEffect()
    }
    let completion = MKLocalSearchCompletion()
    store.environment.localSearchCompleter.search = { query in
        .fireAndForget {
          completions.send(.success([completion]))
        }
    }
    defer { completions.send(completion: .finished) }
    
    store.send(.onAppear)
    
    store.send(.queryChanged("Apple")) {
      $0.query = "Apple"
    }
    
    store.receive(.completionsUpdated(.success([completion]))) {
      $0.completions = [completion]
    }
  }
  
}

extension LocalSearchClient {
  static let failing = Self(
    search: { _ in .failing("LocalSearchClient.search is unimplemented") }
  )
}

extension LocalSearchCompleter {
  static let failing = Self(
    completions: { .failing("LocalSearchCompleter.completions is unimplemented") },
    search: { _ in .failing("LocalSearchCompleter.search is unimplemented") }
  )
}

