//
//  GameView.swift
//  CounterDemo
//
//  Created by Wang Wei on 2022/03/14.
//

import SwiftUI
import ComposableArchitecture

struct GameResult: Equatable {
  let target: Int
  let guess: Int
  let timeSpent: TimeInterval
}

struct GameState: Equatable {
  var counter: Counter = .init()
  var timer: TimerState = .init()
  
  var results: [GameResult] = []
  var lastTimestamp = 0.0
}

enum GameAction {
  case counter(CounterAction)
  case timer(TimerAction)
}

struct GameEnvironment { }

let gameReducer = Reducer<GameState, GameAction, GameEnvironment>.combine(
  counterReducer.pullback(
    state: \.counter,
    action: /GameAction.counter,
    environment: { _ in .live }
  ),
  timerReducer.pullback(
    state: \.timer,
    action: /GameAction.timer,
    environment: { _ in .live }
  )
)

struct GameView: View {
  let store: Store<GameState, GameAction>
  var body: some View {
    WithViewStore(store.stateless) { viewStore in
      VStack {
        TimerLabelView(store: store.scope(state: \.timer, action: GameAction.timer))
        CounterView(store: store.scope(state: \.counter, action: GameAction.counter))
      }.onAppear {
        viewStore.send(.timer(.start))
      }
    }
  }
}
