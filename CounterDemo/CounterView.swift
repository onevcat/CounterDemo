//
//  CounterView.swift
//  CounterDemo
//
//  Created by Wang Wei on 2021/12/08.
//

import SwiftUI
import ComposableArchitecture

struct Counter: Equatable, Identifiable {
  var count: Int = 0
  var secret = Int.random(in: -100 ... 100)
  
  var id: UUID = UUID()
}

// View Model
extension Counter {
  var countString: String {
    get { String(count) }
    set { count = Int(newValue) ?? count }
  }
  
  var countFloat: Float {
    get { Float(count) }
    set { count = Int(newValue) }
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
  case slidingCount(Float)
  case playNext
}

struct CounterEnvironment {
  var generateRandom: (ClosedRange<Int>) -> Int
  var uuid: () -> UUID
  
  static let live = CounterEnvironment(
    generateRandom: Int.random,
    uuid: UUID.init
  )
}

let counterReducer = Reducer<Counter, CounterAction, CounterEnvironment> {
  state, action, environment in
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
  case .slidingCount(let value):
    state.countFloat = value
    return .none
  case .playNext:
    state.count = 0
    state.secret = environment.generateRandom(-100 ... 100)
    state.id = environment.uuid()
    return .none
  }
}

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
        Slider(value: viewStore.binding(get: \.countFloat, send: CounterAction.slidingCount), in: -100...100)
        Button("Next") { viewStore.send(.playNext) }
      }.frame(width: 150)
    }
  }
  
  func checkLabel(with checkResult: Counter.CheckResult) -> some View {
    switch checkResult {
    case .lower:
      return Label("Lower", systemImage: "lessthan.circle")
        .foregroundColor(.red)
    case .higher:
      return Label("Higher", systemImage: "greaterthan.circle")
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

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
      CounterView(
        store: Store(
          initialState: Counter(),
          reducer: counterReducer,
          environment: .live)
      )
    }
}

