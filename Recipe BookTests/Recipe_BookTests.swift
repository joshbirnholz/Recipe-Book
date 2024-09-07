//
//  Recipe_BookTests.swift
//  Recipe BookTests
//
//  Created by Josh Birnholz on 9/3/24.
//

import XCTest
@testable import Recipe_Book

final class Recipe_BookTests: XCTestCase {
  
  private var viewModel: MealCategoryViewModel!
  private var mockViewModel: MealCategoryViewModel!
  private var failingViewModel: MealCategoryViewModel!
  private var emptyViewModel: MealCategoryViewModel!
  
  @MainActor
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    let categoryName = "Dessert"
    
    self.viewModel = .init(categoryName: categoryName)
    self.mockViewModel = .init(categoryName: categoryName, service: MockMealDBService())
    self.failingViewModel = .init(categoryName: categoryName, service: FailingMealDBService())
    self.emptyViewModel = .init(categoryName: categoryName, service: EmptyMealDBService())
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    viewModel = nil
    mockViewModel = nil
    failingViewModel = nil
    emptyViewModel = nil
  }
  
  @MainActor
  func testInitialState() throws {
    XCTAssertTrue(viewModel.state == .loading)
  }
  
  @MainActor
  func testViewModelHandlesStateCorrectly() async throws {
    let expectation = expectation(description: "Fetch \(viewModel.categoryName)")
    
    Task {
      await viewModel.fetchMeals()
      
      if case .meals(let meals) = viewModel.state, !meals.isEmpty {
        expectation.fulfill()
      }
    }
    
    await fulfillment(of: [expectation], timeout: 5)
    XCTAssertFalse(viewModel.isLoading)
  }
  
  func testViewModelHandlesErrorStateCorrectly() async throws {
    await failingViewModel.fetchMeals()
    
    if case .error(_) = await failingViewModel.state {
      // Expected error state, test passed
    } else {
      XCTFail("Expected error state")
    }
  }
  
  func testViewModelHandlesEmptyStateCorrectly() async throws {
    await emptyViewModel.fetchMeals()
    
    if case .empty = await emptyViewModel.state {
      // Expected empty state, test passed
    } else {
      XCTFail("Expected empty state")
    }
  }
  
  func testViewModelFetchesMeals() async throws {
    await viewModel.fetchMeals()
    
    if case .meals(let meals) = await viewModel.state {
      XCTAssertFalse(meals.isEmpty)
    } else {
      XCTFail("Expected to decode meals")
    }
  }
  
  func testViewModelsSortsMealsAlphabetically() async throws {
    await mockViewModel.fetchMeals()
    
    if case .meals(let meals) = await mockViewModel.state {
      XCTAssertEqual(meals, meals.sorted(using: SortDescriptor(\.name)))
    } else {
      XCTFail("Expected to decode meals")
    }
  }
  
  @MainActor
  func testMealsDecodeSuccessfully() async throws {
    await viewModel.fetchMeals()
    
    let meals = try XCTUnwrap(viewModel.meals, "Expected to load meals.")
    
    try await withThrowingTaskGroup(of: (MealInfo, Result<Meal, any Error>).self) { group in
      // For each meal in the category, attempt to fetch and decode the full meal object.
      for mealInfo in meals {
        group.addTask { @MainActor in
          let viewModel = MealDetailViewModel(mealInfo: mealInfo)
          await viewModel.fetchMeal()
          return (mealInfo, Result {
            if let meal = viewModel.meal {
              return meal
            }
            throw try XCTUnwrap(viewModel.error)
          })
        }
      }
      
      for try await (mealInfo, result) in group {
        do {
          let meal = try result.get()
          
          for ingredient in meal.ingredients {
            // Ensure no empty strings are included in any of the ingredients.
            XCTAssertNotEqual(ingredient.name, "", "Expected ingredient name to be non-empty")
            XCTAssertNotEqual(ingredient.measurement, "Expected measurement to be non-empty")
          }
        } catch {
          // Ensure that every meal in the category is decoded successfully.
          XCTFail("Failed to decode \(mealInfo.name) (\(mealInfo.id)): \(error)")
        }
      }
    }
  }
}
