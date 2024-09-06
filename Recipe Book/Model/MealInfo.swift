//
//  MealInfo.swift
//  Recipe Book
//
//  Created by Josh Birnholz on 9/3/24.
//

import Foundation

public struct MealInfo: Codable, Identifiable, Equatable, Hashable {
  public let name: String
  public let thumbnailURL: URL?
  public let id: String
  
  init(name: String, thumbnailURL: URL?, id: String) {
    self.name = name
    self.thumbnailURL = thumbnailURL
    self.id = id
  }
  
  enum CodingKeys: String, CodingKey {
    case name = "strMeal"
    case thumbnailURL = "strMealThumb"
    case id = "idMeal"
  }
}
