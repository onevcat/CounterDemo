//
//  ContentView.swift
//  CounterDemo
//
//  Created by Wang Wei on 2021/12/08.
//

import SwiftUI
import ComposableArchitecture

struct Counter: Equatable {
  var count: Int = 0
}

enum CounterAction {
  case increment
  case decrement
}

struct CounterEnvironment { }

let counterReducer = Reducer<Counter, CounterAction, CounterEnvironment> {
  state, action, _ in
  switch action {
  case .increment:
    state.count += 1
    return .none
  case .decrement:
    state.count -= 1
    return .none
  }
}.debug()

struct CounterView: View {
  let store: Store<Counter, CounterAction>
  var body: some View {
    WithViewStore(store) { viewStore in
      HStack {
        Button("-") { viewStore.send(.decrement) }
        Text("\(viewStore.count)")
        Button("+") { viewStore.send(.increment) }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      CounterView(
        store: Store(
          initialState: Counter(),
          reducer: counterReducer,
          environment: CounterEnvironment())
      )
    }
}
