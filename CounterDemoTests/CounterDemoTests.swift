//
//  CounterDemoTests.swift
//  CounterDemoTests
//
//  Created by Wang Wei on 2021/12/08.
//

import XCTest
@testable import CounterDemo
import ComposableArchitecture

class CounterDemoTests: XCTestCase {
  
  var store: TestStore<Counter, Counter, CounterAction, CounterAction, CounterEnvironment>!
  
  override func setUp() {
    store = TestStore(
      initialState: Counter(count: Int.random(in: -100...100)),
      reducer: counterReducer,
      environment: CounterEnvironment()
    )
  }
  
  func testCounterIncrement() throws {
    store.send(.increment) { state in
      state.count += 1
    }
  }
  
  func testCounterDecrement() throws {
    store.send(.decrement) { state in
      state.count -= 1
    }
  }
  
  func testReset() throws {
    store.send(.newGame) { state in
      state.count = 0
    }
  }
  
  func testSetCount() {
    store.send(.setCount("100")) { state in
      state.count = 100
    }
  }
}


