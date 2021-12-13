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

// View Model
extension Counter {
  var countString: String {
    get { String(count) }
    set { count = Int(newValue) ?? count }
  }
}

enum CounterAction {
  case increment
  case decrement
  case setCount(String)
  case reset
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
  case .setCount(let text):
    state.countString = text
    return .none
  case .reset:
    state.count = 0
    return .none
  }
}.debug()

struct CounterView: View {
  let store: Store<Counter, CounterAction>
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        HStack {
          Button("-") { viewStore.send(.decrement) }
          TextField(
            viewStore.countString,
            text: viewStore.binding(
              get: \.countString,
              send: CounterAction.setCount
            )
          )
            .frame(width: 40)
            .multilineTextAlignment(.center)
            .foregroundColor(colorOfCount(viewStore.count))
          Button("+") { viewStore.send(.increment) }
        }
        Button("Reset") { viewStore.send(.reset) }
      }
    }
  }
  
  func colorOfCount(_ value: Int) -> Color? {
    if value == 0 { return nil }
    return value < 0 ? .red : .green
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

