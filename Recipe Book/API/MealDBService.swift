//
//  MealDBService.swift
//  Recipe Book
//
//  Created by Josh Birnholz on 9/3/24.
//

import Foundation

// MARK: Router

public final class API {
  
  let baseURL: URL
  
  public init(baseURL: URL = URL(string: "https://themealdb.com/api/json/v1/1/")!) {
    self.baseURL = baseURL
  }
  
  public enum Destination {
    case category(String)
    case meal(id: String)
  }
  
  public func url(for destination: Destination) -> URL? {
    var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
    
    switch destination {
    case .category(let category):
      components.path.append("filter.php")
      components.queryItems = [
        .init(name: "c", value: category)
      ]
    case .meal(let id):
      components.path.append("lookup.php")
      components.queryItems = [
        .init(name: "i", value: id)
      ]
    }
    
    return components.url
  }
}

// MARK: Protocol

public protocol MealDBServiceProtocol {
  func getCategory(name: String) async throws -> [MealInfo]
  func getMeal(id: String) async throws -> Meal?
}

// MARK: Service

public final class MealDBService: MealDBServiceProtocol {
  
  enum MealServiceError: Error {
    case invalidURL
    
    var localizedDescription: String {
      switch self {
      case .invalidURL:
        "The content couldn't be loaded."
      }
    }
  }
  
  let api: API
  
  public init(api: API = .init()) {
    self.api = api
  }
  
  public func getCategory(name: String) async throws -> [MealInfo] {
    guard let url = api.url(for: .category(name)) else {
      throw MealServiceError.invalidURL
    }
    let data = try await URLSession.shared.data(from: url).0
    
    let decoder = JSONDecoder()
    let response = try decoder.decode(MealDBResult<MealInfo>.self, from: data)
    return response.meals
  }
  
  public func getMeal(id: String) async throws -> Meal? {
    guard let url = api.url(for: .meal(id: id)) else {
      throw MealServiceError.invalidURL
    }
    let data = try await URLSession.shared.data(from: url).0
    
    let decoder = JSONDecoder()
    let response = try decoder.decode(MealDBResult<Meal>.self, from: data)
    return response.meals.first
  }
  
}
