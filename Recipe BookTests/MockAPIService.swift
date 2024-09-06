//
//  MockAPIService.swift
//  Recipe BookTests
//
//  Created by Josh Birnholz on 9/6/24.
//

import Foundation
import UIKit

public final class MockMealDBService: MealDBServiceProtocol {
  
  public init() {
    
  }
  
  private func loadFile(named name: String, extension fileExtension: String? = nil) throws -> Data {
    let bundle = Bundle(for: MockMealDBService.self)
    let url = bundle.url(forResource: name, withExtension: fileExtension)!
    return try Data(contentsOf: url)
  }
  
  public func getCategory(name: String) async throws -> [MealInfo] {
    let data = try loadFile(named: "meals", extension: "json")
    
    let decoder = JSONDecoder()
    let response = try decoder.decode(MealDBResult<MealInfo>.self, from: data)
    return response.meals
  }
  
  public func getMeal(id: String) async throws -> Meal? {
    let data = try loadFile(named: "52893", extension: "json")
    
    let decoder = JSONDecoder()
    let response = try decoder.decode(MealDBResult<Meal>.self, from: data)
    return response.meals.first
  }
  
}

public final class FailingMealDBService: MealDBServiceProtocol {
  
  enum ServiceError: Error {
    case failedToLoad
    
    var localizedDescription: String {
      "Failed to load"
    }
  }
  
  public init() {
    
  }
  
  public func getCategory(name: String) async throws -> [MealInfo] {
    throw ServiceError.failedToLoad
  }
  
  public func getMeal(id: String) async throws -> Meal? {
    throw ServiceError.failedToLoad
  }
  
}

public final class EmptyMealDBService: MealDBServiceProtocol {
  
  public init() {
    
  }
  
  public func getCategory(name: String) async throws -> [MealInfo] {
    return []
  }
  
  public func getMeal(id: String) async throws -> Meal? {
    return nil
  }
  
}
