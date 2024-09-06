//
//  Router.swift
//  Recipe Book
//
//  Created by Josh Birnholz on 9/5/24.
//

import Foundation
import SwiftUI

enum Route: Hashable {
  case meal(MealInfo)
}

@Observable
class Router {
  private(set) var path: NavigationPath
  
  init() {
    self.path = NavigationPath()
  }
  
  func removeAll() {
    path.removeLast(path.count)
  }
  
  @ViewBuilder
  @MainActor
  func destination(for route: Route) -> some View {
    switch route {
    case .meal(let mealInfo):
      let viewModel = MealDetailViewModel(mealInfo: mealInfo)
      MealDetailView(viewModel: viewModel)
    }
  }
}
