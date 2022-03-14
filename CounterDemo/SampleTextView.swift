//
//  SampleTextView.swift
//  CounterDemo
//
//  Created by Wang Wei on 2022/03/14.
//

import SwiftUI
import ComposableArchitecture
import Combine

let sampleRequest = URLSession.shared
  .dataTaskPublisher(for: URL(string: "https://example.com")!)
  .map { element -> String in
    return String(data: element.data, encoding: .utf8) ?? ""
  }


struct SampleTextEnvironment {
  var loadText: () -> Effect<String, URLError>
  var mainQueue: AnySchedulerOf<DispatchQueue>
  static let live = SampleTextEnvironment(
    loadText: { sampleRequest.eraseToEffect() },
    mainQueue: .main
  )
}

enum SampleTextAction: Equatable {
  case load
  case loaded(Result<String, URLError>)
}

struct SampleTextState: Equatable {
  var loading: Bool
  var text: String
}

let sampleTextReducer = Reducer<SampleTextState, SampleTextAction, SampleTextEnvironment> {
  state, action, environment in
  switch action {
  case .load:
    state.loading = true
    return environment.loadText()
      .receive(on: environment.mainQueue)
      .catchToEffect(SampleTextAction.loaded)
  case .loaded(let result):
    state.loading = false
    do {
      state.text = try result.get()
    } catch {
      state.text = "Error: \(error)"
    }
    return .none
  }
}

struct SampleTextView: View {
  
  let store: Store<SampleTextState, SampleTextAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      ZStack {
        VStack {
          Button("Load") { viewStore.send(.load) }
          Text(viewStore.text)
        }
        if viewStore.loading {
          ProgressView().progressViewStyle(.circular)
        }
        
      }
    }
  }
}
