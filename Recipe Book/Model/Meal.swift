//
//  Meal.swift
//  Recipe Book
//
//  Created by Josh Birnholz on 9/3/24.
//

import Foundation

public struct Meal: Identifiable, Decodable, Equatable, Sendable {
  public struct Ingredient: Identifiable, Equatable, Sendable {
    let name: String
    let measurement: String
    
    public let id = UUID()
    
    /// A URL that points to an image of the ingredient.
    public var thumbnailURL: URL {
      URL(string: "https://www.themealdb.com/images/ingredients/\(name).png")!
    }
  }
  
  /// The name of the meal.
  public let name: String
  /// A URL that points to an image of the meal.
  public let thumbnailURL: URL
  /// The meal's ID on TheMealDB.
  public let id: String
  /// The name of the category the meal is in.
  public let category: String
  /// The meal's origin, eg, "British"
  public let area: String
  /// The instructions to prepare the meal.
  public let instructions: String
  /// A list of tags describing the meal.
  public let tags: [String]?
  /// A URL that points to a YouTube video assocated with the meal.
  public let youTubeURL: URL?
  /// A list of the ingredients needed to prepare the meal.`
  public let ingredients: [Ingredient]
  /// A URL pointing to the source of the recipe for the meal.
  public let source: URL?
  
  enum CodingKeys: String, CodingKey, CaseIterable {
    case name = "strMeal"
    case thumbnailURL = "strMealThumb"
    case id = "idMeal"
    case category = "strCategory"
    case area = "strArea"
    case instructions = "strInstructions"
    case tags = "strTags"
    case youTubeURL = "strYoutube"
    case ingredient1 = "strIngredient1"
    case ingredient2 = "strIngredient2"
    case ingredient3 = "strIngredient3"
    case ingredient4 = "strIngredient4"
    case ingredient5 = "strIngredient5"
    case ingredient6 = "strIngredient6"
    case ingredient7 = "strIngredient7"
    case ingredient8 = "strIngredient8"
    case ingredient9 = "strIngredient9"
    case ingredient10 = "strIngredient10"
    case ingredient11 = "strIngredient11"
    case ingredient12 = "strIngredient12"
    case ingredient13 = "strIngredient13"
    case ingredient14 = "strIngredient14"
    case ingredient15 = "strIngredient15"
    case ingredient16 = "strIngredient16"
    case ingredient17 = "strIngredient17"
    case ingredient18 = "strIngredient18"
    case ingredient19 = "strIngredient19"
    case ingredient20 = "strIngredient20"
    
    case measurement1 = "strMeasure1"
    case measurement2 = "strMeasure2"
    case measurement3 = "strMeasure3"
    case measurement4 = "strMeasure4"
    case measurement5 = "strMeasure5"
    case measurement6 = "strMeasure6"
    case measurement7 = "strMeasure7"
    case measurement8 = "strMeasure8"
    case measurement9 = "strMeasure9"
    case measurement10 = "strMeasure10"
    case measurement11 = "strMeasure11"
    case measurement12 = "strMeasure12"
    case measurement13 = "strMeasure13"
    case measurement14 = "strMeasure14"
    case measurement15 = "strMeasure15"
    case measurement16 = "strMeasure16"
    case measurement17 = "strMeasure17"
    case measurement18 = "strMeasure18"
    case measurement19 = "strMeasure19"
    case measurement20 = "strMeasure20"
    case source = "strSource"
  }
  
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(String.self, forKey: .name)
    self.thumbnailURL = try container.decode(URL.self, forKey: .thumbnailURL)
    self.id = try container.decode(String.self, forKey: .id)
    self.category = try container.decode(String.self, forKey: .category)
    self.area = try container.decode(String.self, forKey: .area)
    self.instructions = try container.decode(String.self, forKey: .instructions)
    self.tags = try container.decodeIfPresent(String.self, forKey: .tags)?.components(separatedBy: ",")
    
    let youTubeString = try container.decode(String.self, forKey: .youTubeURL)
    self.youTubeURL = URL(string: youTubeString)
    
    // The API represents ingredients and measurements using 20 strings each, rather than an array of objects.
    // The below code decodes these values, matches them up, and then uses them to create an array of
    // `Ingredient` instances, in order to more easily consume these in the View. It also discards null
    // and empty values.
    
    let ingredients = try CodingKeys.allCases.filter { $0.rawValue.hasPrefix("strIngredient") }
      .compactMap { key in
        if let value = try container.decode(String?.self, forKey: key), !value.isEmpty {
          return value
        } else {
          return nil
        }
      }
    
    let measurements = try CodingKeys.allCases.filter { $0.rawValue.hasPrefix("strMeasure") }
      .compactMap { key in
        if let value = try container.decode(String?.self, forKey: key), !value.isEmpty {
          return value
        } else {
          return nil
        }
      }
    
    self.ingredients = zip(ingredients, measurements).map { ingredient, measurement in
      Ingredient(name: ingredient, measurement: measurement)
    }
    
    if let sourceURL = try container.decodeIfPresent(String.self, forKey: .source) {
      self.source = URL(string: sourceURL)
    } else {
      self.source = nil
    }
  }
}
