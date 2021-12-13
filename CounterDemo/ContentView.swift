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
  let secret = Int.random(in: -100 ... 100)
}

// View Model
extension Counter {
  var countString: String {
    get { String(count) }
    set { count = Int(newValue) ?? count }
  }
  
  enum CheckResult {
    case lower, equal, higher
  }
  
  var checkResult: CheckResult {
    if count < secret { return .lower }
    if count > secret { return .higher }
    return .equal
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
        checkLabel(with: viewStore.checkResult)
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
  
  func checkLabel(with checkResult: Counter.CheckResult) -> some View {
    switch checkResult {
    case .lower:
      return Label("Lower", systemImage: "lessthan.circle")
        .foregroundColor(.red)
    case .higher:
      return Label("Higer", systemImage: "greaterthan.circle")
        .foregroundColor(.red)
    case .equal:
      return Label("Correct", systemImage: "checkmark.circle")
        .foregroundColor(.green)
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

