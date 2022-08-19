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
    
    let completions = PassthroughSubject<Result<[LocalSearchCompletion], Error>, Never>()
    
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment(
        localSearch: .failing,
        localSearchCompleter: .failing,
        mainQueue: .immediate
      )
    )
    
    store.environment.localSearchCompleter.completions = { completions.eraseToEffect()
    }
    let completion = LocalSearchCompletion(title: "Apple Store", subtitle: "Search Nearby")
    store.environment.localSearchCompleter.search = { query in
        .fireAndForget {
          completions.send(.success([completion]))
        }
    }
    let response = LocalSearchClient.Response(
      boundingRegion: .init(
        center: .init(latitude: 0, longitude: 0),
        span: .init(latitudeDelta: 1, longitudeDelta: 1)),
      // the reason this worked fine with Equatable is because we previously conformed it to Identifiable, this is not ideal
      // Check episode exercise to see how a wrapper was made around this.
      mapItems: [MKMapItem()]
    )
    store.environment.localSearch.search = { _ in
      .init(
        value: response
      )
    }
    defer { completions.send(completion: .finished) }
    
    store.send(.onAppear)
    
    store.send(.queryChanged("Apple")) {
      $0.query = "Apple"
    }
    
    store.receive(.completionsUpdated(.success([completion]))) {
      $0.completions = [completion]
    }
    
    store.send(.tappedCompletion(completion))
    
    store.receive(.searchResponse(.success(response))) {
      $0.region = response.boundingRegion
      $0.mapItems = response.mapItems
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

