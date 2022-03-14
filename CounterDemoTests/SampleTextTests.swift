//
//  SampleTextTests.swift
//  CounterDemoTests
//
//  Created by Wang Wei on 2022/03/14.
//

import XCTest
import ComposableArchitecture
@testable import CounterDemo

class SampleTextTests: XCTestCase {
  
  // let scheduler = DispatchQueue.test
  
  func testSampleTextRequest() throws {
    let store = TestStore(
      initialState: SampleTextState(loading: false, text: ""),
      reducer: sampleTextReducer,
      environment: SampleTextEnvironment(
        loadText: { Effect(value: "Hello World") },
        //mainQueue: scheduler.eraseToAnyScheduler()
        mainQueue: .immediate
      )
    )
    store.send(.load) { state in
      state.loading = true
    }
    // scheduler.advance()
    store.receive(.loaded(.success("Hello World"))) { state in
      state.loading = false
      state.text = "Hello World"
    }
  }
}

