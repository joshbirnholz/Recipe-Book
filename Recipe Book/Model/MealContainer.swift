//
//  MealContainer.swift
//  Recipe Book
//
//  Created by Josh Birnholz on 9/3/24.
//

import Foundation

public struct MealDBResult<T: Decodable>: Decodable {
  public let meals: [T]
}
