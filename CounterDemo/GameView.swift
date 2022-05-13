//
//  GameView.swift
//  CounterDemo
//
//  Created by Wang Wei on 2022/03/14.
//

import SwiftUI
import ComposableArchitecture

struct GameResult: Equatable, Identifiable {
  let counter: Counter
  let timeSpent: TimeInterval
  
  var correct: Bool { counter.secret == counter.count }
  var id: UUID { counter.id }
}

struct GameState: Equatable {
  var counter: Counter = .init()
  var timer: TimerState = .init()
  
  var resultListState: Identified<UUID, GameResultListState>?
  
  var results = IdentifiedArrayOf<GameResult>()
  var lastTimestamp = 0.0
  
  var alert: AlertState<GameAlertAction>?
  var savingResults: Bool = false
}

enum GameAction {
  case counter(CounterAction)
  case listResult(GameResultListAction)
  case timer(TimerAction)
  case setNavigation(UUID?)
  case alertAction(GameAlertAction)
  case saveResult(Result<Void, URLError>)
}

enum GameAlertAction: Equatable {
  case alertSaveButtonTapped
  case alertCancelButtonTapped
  case alertDismiss
}

struct GameEnvironment {
  var generateRandom: (ClosedRange<Int>) -> Int
  var uuid: () -> UUID
  var date: () -> Date
  var mainQueue: AnySchedulerOf<DispatchQueue>
  
  static let live = GameEnvironment(
    generateRandom: Int.random,
    uuid: UUID.init,
    date: Date.init,
    mainQueue: .main
  )
}

let resultListStateTag = UUID()

let gameReducer = Reducer<GameState, GameAction, GameEnvironment>.combine(
  .init { state, action, environment in
    switch action {
    case .counter(.playNext):
      let result = GameResult(counter: state.counter, timeSpent: state.timer.duration - state.lastTimestamp)
      state.results.append(result)
      state.lastTimestamp = state.timer.duration
      return .none
    case .counter:
      return .none
    case .timer:
      return .none
    case .listResult:
      return .none
    case .setNavigation(.some(let id)):
      state.resultListState = Identified(state.results, id: id)
      return .none
    case .setNavigation(.none):
      if state.resultListState?.value != state.results {
        state.alert = .init(
          title: .init("Save Changes?"),
          primaryButton: .default(.init("OK"), action: .send(.alertSaveButtonTapped)),
          secondaryButton: .cancel(.init("Cancel"), action: .send(.alertCancelButtonTapped))
        )
      } else {
        state.resultListState = nil
      }
      return .none
    case .alertAction(.alertDismiss):
      state.alert = nil
      return .none
    case .alertAction(.alertSaveButtonTapped):
      state.savingResults = true
      return Effect(value: .saveResult(.success(())))
        .delay(for: 2, scheduler: environment.mainQueue)
        .eraseToEffect()
    case .alertAction(.alertCancelButtonTapped):
      state.resultListState = nil
      return .none
    case .saveResult(let result):
      state.savingResults = false
      state.results = state.resultListState?.value ?? []
      state.resultListState = nil
      return .none
    }
  },
  counterReducer.pullback(
    state: \.counter,
    action: /GameAction.counter,
    environment: { .init(generateRandom: $0.generateRandom, uuid: $0.uuid) }
  ),
  timerReducer.pullback(
    state: \.timer,
    action: /GameAction.timer,
    environment: { .init(date: $0.date, mainQueue: $0.mainQueue) }
  ),
  gameResultListReducer
    .pullback(
      state: \Identified.value,
      action: .self,
      environment: { $0 }
    )
    .optional()
    .pullback(
      state: \.resultListState,
      action: /GameAction.listResult,
      environment: { _ in .init() }
    )
)

struct GameView: View {
  let store: Store<GameState, GameAction>
  var body: some View {
    WithViewStore(store.scope(state: \.results)) { viewStore in
      VStack {
        resultLabel(viewStore.state.elements)
        Divider()
        TimerLabelView(store: store.scope(state: \.timer, action: GameAction.timer))
        CounterView(store: store.scope(state: \.counter, action: GameAction.counter))
      }.onAppear {
        viewStore.send(.timer(.start))
      }
    }.toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        WithViewStore(store) { viewStore in
          NavigationLink(
            tag: resultListStateTag,
            selection: viewStore.binding(get: \.resultListState?.id, send: GameAction.setNavigation),
            destination: {
              IfLetStore(
                store.scope(state: \.resultListState?.value, action: GameAction.listResult),
                then: { GameResultListView(store: $0) }
              ) },
            label: {
              if viewStore.savingResults {
                ProgressView()
              } else {
                Text("Detail")
              }
            }
          )
        }
      }
    }.alert(
      store.scope(state: \.alert, action: GameAction.alertAction),
      dismiss: .alertDismiss
    )
  }
  
  func resultLabel(_ results: [GameResult]) -> some View {
    Text("Result: \(results.filter(\.correct).count)/\(results.count) correct")
  }
}
