//
//  MockAPIService.swift
//  Recipe BookTests
//
//  Created by Josh Birnholz on 9/6/24.
//

import Foundation
import UIKit

// MARK: Mock service

public actor MockMealDBService: MealDBServiceProtocol {
  
  public init() {
    
  }
  
  private func loadFile(named name: String, extension fileExtension: String? = nil) throws -> Data {
    let bundle = Bundle(for: MockMealDBService.self)
    guard let url = bundle.url(forResource: name, withExtension: fileExtension) else {
      throw NSError(domain: "MockMealDBService", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found"])
    }
    return try Data(contentsOf: url)
  }
  
  public func getCategory(name: String) async throws -> [MealInfo] {
    let data = try loadFile(named: "meals", extension: "json")
    
    let decoder = JSONDecoder()
    let response = try decoder.decode(MealDBResult<MealInfo>.self, from: data)
    return response.meals
  }
  
  public func getMeal(id: String) async throws -> Meal? {
    let data = try loadFile(named: id, extension: "json")
    
    let decoder = JSONDecoder()
    let response = try decoder.decode(MealDBResult<Meal>.self, from: data)
    return response.meals.first
  }
  
}

// MARK: Failing service

public actor FailingMealDBService: MealDBServiceProtocol {
  
  public init() {
    
  }
  
  public func getCategory(name: String) async throws -> [MealInfo] {
    throw NSError(domain: "MockMealDBService", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found"])
  }
  
  public func getMeal(id: String) async throws -> Meal? {
    throw NSError(domain: "MockMealDBService", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found"])
  }
  
}

// MARK: Empty service

public actor EmptyMealDBService: MealDBServiceProtocol {
  
  public init() {
    
  }
  
  public func getCategory(name: String) async throws -> [MealInfo] {
    return []
  }
  
  public func getMeal(id: String) async throws -> Meal? {
    return nil
  }
  
}
