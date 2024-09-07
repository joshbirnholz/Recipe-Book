//
//  CategoryViewModel.swift
//  Recipe Book
//
//  Created by Josh Birnholz on 9/3/24.
//

import Foundation
import SwiftUI

@Observable
@MainActor
class MealCategoryViewModel {
  
  private let service: MealDBServiceProtocol
  
  let categoryName: String
  
  private(set) var meals: [MealInfo]?
  private(set) var error: Error?
  private(set) var isLoading: Bool = true
  
  var query: String = ""
  
  init(categoryName: String, service: MealDBServiceProtocol = MealDBService()) {
    self.categoryName = categoryName
    self.service = service
  }
  
  enum State: Equatable {
    case meals([MealInfo])
    case empty
    case loading
    case error(String)
  }
  
  /// The state of the view, computed based on the loading and error states and the fetched data.
  var state: State {
    if let error {
      return .error(error.localizedDescription)
    } else if isLoading {
      return .loading
    } else if let meals, !meals.isEmpty {
      let query = query.trimmingCharacters(in: .whitespaces).lowercased()
      if query.count >= 2 {
        // Filter the displayed meals based on the user's query in the search bar
        let filteredMeals = meals.filter { $0.name.lowercased().contains(query) }
        return .meals(filteredMeals)
      } else {
        // The user isn't searching for anything, display all the meals
        return .meals(meals)
      }
    } else {
      return .empty
    }
  }
  
  /// Asynchronously loads the meals and sets either the `meals` property, or the `error` if one was encountered.
  func fetchMeals() async {
    self.isLoading = true
    
    do {
      defer {
        self.isLoading = false
      }
      
      // Sort the meals alphabetically when they are fetched
      self.meals = try await service.getCategory(name: categoryName).sorted(using: SortDescriptor(\.name))
    } catch {
      self.error = error
    }
  }
}
