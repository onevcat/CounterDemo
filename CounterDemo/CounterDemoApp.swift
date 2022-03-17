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
      GameView(
        store: Store(
          initialState: GameState(),
          reducer: gameReducer,
          environment: .live)
      )
    }
  }
}
