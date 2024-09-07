//
//  MealDetailViewModel.swift
//  Recipe Book
//
//  Created by Josh Birnholz on 9/3/24.
//

import Foundation
import SwiftUI

@Observable
@MainActor
class MealDetailViewModel {
  
  private let service: MealDBServiceProtocol
  
  let mealInfo: MealInfo
  
  private(set) var meal: Meal?
  private(set) var error: Error?
  private(set) var isLoading: Bool = true
  
  init(mealInfo: MealInfo, service: MealDBServiceProtocol = MealDBService()) {
    self.mealInfo = mealInfo
    self.service = service
  }
  
  enum State: Equatable {
    case meal(Meal)
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
    } else if let meal {
      return .meal(meal)
    } else {
      return .empty
    }
  }
  
  /// The meal's instructions, formatted to remove extra line breaks.
  var formattedInstructions: String? {
    meal?.instructions.components(separatedBy: .newlines).filter { !$0.isEmpty }.joined(separator: "\n\n")
  }
  
  var flagEmoji: String? {
    guard let meal else { return nil }
    return switch meal.area {
    case "British": "🇬🇧"
    case "Canadian": "🇨🇦"
    case "Tunisian": "🇹🇳"
    case "American": "🇺🇸"
    case "Croatian": "🇭🇷"
    case "Russian": "🇷🇺"
    case "Portuguese": "🇵🇹"
    case "French": "🇫🇷"
    case "Italian": "🇮🇹"
    case "Malaysian": "🇲🇾"
    case "Polish": "🇵🇱"
    case "Greek": "🇬🇷"
    default: nil
    }
  }
  
  /// Asynchronously loads the meal and sets either the `meal` property, or the `error` if one was encountered.
  func fetchMeal() async {
    self.isLoading = true
    
    do {
      defer {
        self.isLoading = false
      }
      
      self.meal = try await service.getMeal(id: mealInfo.id)
    } catch {
      self.error = error
    }
  }
}
