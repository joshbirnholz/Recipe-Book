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
  
  enum CodingKeys: RawRepresentable, CodingKey {
    case name
    case thumbnailURL
    case id
    case category
    case area
    case instructions
    case tags
    case youTubeURL
    case source
    case ingredient(Int)
    case measurement(Int)
    
    var rawValue: String {
      switch self {
      case .name: return "strMeal"
      case .thumbnailURL: return "strMealThumb"
      case .id: return "idMeal"
      case .category: return "strCategory"
      case .area: return "strArea"
      case .instructions: return "strInstructions"
      case .tags: return "strTags"
      case .youTubeURL: return "strYoutube"
      case .source: return "strSource"
      case .ingredient(let num): return "strIngredient\(num)"
      case .measurement(let num): return "strMeasure\(num)"
      }
    }
    
    init?(rawValue: String) {
      switch rawValue {
      case "strMeal": self = .name
      case "strMealThumb": self = .thumbnailURL
      case "idMeal": self = .id
      case "strCategory": self = .category
      case "strArea": self = .area
      case "strInstructions": self = .instructions
      case "strTags": self = .tags
      case "strYoutube": self = .youTubeURL
      case "strSource": self = .source
      case _ where rawValue.hasPrefix("strIngredient"):
        if let num = Int(rawValue.replacingOccurrences(of: "strIngredient", with: "")) {
          self = .ingredient(num)
        } else {
          return nil
        }
      case _ where rawValue.hasPrefix("strMeasure"):
        if let num = Int(rawValue.replacingOccurrences(of: "strMeasure", with: "")) {
          self = .measurement(num)
        } else {
          return nil
        }
      default:
        return nil
      }
    }
    
    var stringValue: String {
      return rawValue
    }
    
    var intValue: Int? {
      return nil
    }
    
    init?(stringValue: String) {
      self.init(rawValue: stringValue)
    }
    
    init?(intValue: Int) {
      return nil
    }
    
    var num: Int? {
      if case .ingredient(let num) = self {
        return num
      } else if case .measurement(let num) = self {
        return num
      } else {
        return nil
      }
    }
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
    // The below code decodes the values for the ingredient keys, pairs them up with the matching measurement
    // values, and then uses them to create an array of `Ingredient` instances, in order to more easily consume
    // these in the View. It also discards empty string values.
    
    self.ingredients = container.allKeys.sorted(using: KeyPathComparator(\.num)).compactMap { key in
      guard
        case .ingredient(let num) = key,
        let ingredient = try? container.decode(String.self, forKey: key),
        let measurement = try? container.decode(String.self, forKey: .measurement(num)),
        !ingredient.isEmpty && !measurement.isEmpty
      else {
        return nil
      }
      
      return Ingredient(name: ingredient, measurement: measurement)
    }
    
    if let sourceURL = try container.decodeIfPresent(String.self, forKey: .source) {
      self.source = URL(string: sourceURL)
    } else {
      self.source = nil
    }
  }
}
