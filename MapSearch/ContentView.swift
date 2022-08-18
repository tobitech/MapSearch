//
//  ContentView.swift
//  MapSearch
//
//  Created by Oluwatobi Omotayo on 18/08/2022.
//

import ComposableArchitecture
import MapKit
import SwiftUI

// Not advisable to add conformance to 3rd party frameworks.
extension MKCoordinateRegion: Equatable {
  public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
    lhs.center == rhs.center && lhs.span == rhs.span
  }
}

extension CLLocationCoordinate2D: Equatable {
  public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
  }
}

extension MKCoordinateSpan: Equatable {
  public static func == (lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
    lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta
  }
}

struct AppState: Equatable {
  var query = ""
  var region = MKCoordinateRegion(
    center: .init(latitude: 40.7, longitude: -74),
    span: .init(latitudeDelta: 0.075, longitudeDelta: 0.075)
  )
}

enum AppAction {
  case queryChanged(String)
  case regionChanged(MKCoordinateRegion)
}

struct AppEnvironment {
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, _ in
  switch action {
  case let .queryChanged(query):
    state.query = query
    return .none
    
  case let .regionChanged(region):
    state.region = region
    return .none
  }
}

struct ContentView: View {
  
  let store: Store<AppState, AppAction>
  let viewStore: ViewStore<AppState, AppAction>
  
  init(store: Store<AppState, AppAction>) {
    self.store = store
    self.viewStore = ViewStore(self.store)
  }
  
  var body: some View {
    Map(
      coordinateRegion: .constant(
        .init(
          center: .init(latitude: 40.7, longitude: -74),
          span: .init(latitudeDelta: 0.075, longitudeDelta: 0.075)
        )
      )
//      interactionModes: <#T##MapInteractionModes#>,
//      showsUserLocation: <#T##Bool#>,
//      userTrackingMode: <#T##Binding<MapUserTrackingMode>?#>,
//      annotationItems: <#T##RandomAccessCollection#>,
//      annotationContent: <#T##(Identifiable) -> MapAnnotationProtocol#>
    )
    .searchable(
      text: .constant("")
//      placement: <#T##SearchFieldPlacement#>,
//      prompt: <#T##LocalizedStringKey#>,
//      suggestions: <#T##() -> View#>
    ) {
      Text("Apple Store")
      Text("Cafe")
      Text("Library")
    }
    .navigationBarTitle("Places", displayMode: .inline)
    .ignoresSafeArea(edges: .bottom)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ContentView(
        store: Store(
          initialState: AppState(),
          reducer: appReducer,
          environment: AppEnvironment()
        )
      )
    }
  }
}
