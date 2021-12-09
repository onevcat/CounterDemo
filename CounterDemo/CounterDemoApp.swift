//
//  CounterDemoApp.swift
//  CounterDemo
//
//  Created by Wang Wei on 2021/12/08.
//

import SwiftUI
import ComposableArchitecture

@main
struct CounterDemoApp: App {
  var body: some Scene {
    WindowGroup {
      CounterView(
        store: Store(
          initialState: Counter(),
          reducer: counterReducer,
          environment: CounterEnvironment())
      )
    }
  }
}
