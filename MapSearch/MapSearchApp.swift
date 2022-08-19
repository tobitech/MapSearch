//
//  MapSearchApp.swift
//  MapSearch
//
//  Created by Oluwatobi Omotayo on 18/08/2022.
//

import ComposableArchitecture
import SwiftUI

@main
struct MapSearchApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView(
          store: Store(
            initialState: AppState(),
            // this automatically prints when an action is sent to the store.
            reducer: appReducer.debugActions(),
            environment: AppEnvironment(
              localSearch: .live,
              localSearchCompleter: .live,
              mainQueue: .main
            )
          )
        )
      }
    }
  }
}
