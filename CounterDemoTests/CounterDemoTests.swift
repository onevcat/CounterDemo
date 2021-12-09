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
  func testCounterIncrement() throws {
    let store = TestStore(
      initialState: Counter(count: Int.random(in: -100...100)),
      reducer: counterReducer,
      environment: CounterEnvironment()
    )
    store.send(.increment) { state in
      state.count += 1
    }
  }
  
  func testCounterDecrement() throws {
    
  }
  
  func testReset() throws {
    
  }
}


