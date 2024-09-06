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
  }
  
  func testInitialState() throws {
    XCTAssertTrue(viewModel.state == .loading)
  }
  
  func testStateAfterFetching() async throws {
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
  
  func testStateAfterFailing() async throws {
    await failingViewModel.fetchMeals()
    
    if case .error(_) = failingViewModel.state {
      // Error state, no action needed
    } else {
      XCTFail("Expected error state")
    }
  }
  
  func testStateAfterReceivingNoData() async throws {
    await emptyViewModel.fetchMeals()
    
    if case .empty = emptyViewModel.state {
      // Error state, no action needed
    } else {
      XCTFail("Expected empty state")
    }
  }
  
  func testFetchedMeals() async throws {
    await viewModel.fetchMeals()
    await mockViewModel.fetchMeals()
    
    if case .meals(let meals) = viewModel.state, case .meals(let expectedMeals) = mockViewModel.state {
      XCTAssertEqual(meals, expectedMeals)
    } else {
      XCTFail("Expected to decode meals")
    }
  }
  
  func testMealsSorted() async throws {
    await viewModel.fetchMeals()
    
    if case .meals(let meals) = viewModel.state {
      XCTAssertEqual(meals, meals.sorted(using: SortDescriptor(\.name)))
    } else {
      XCTFail("Expected to decode meals")
    }
  }
  
  func testDecodingMeals() async throws {
    await viewModel.fetchMeals()
    
    let meals = try XCTUnwrap(viewModel.meals, "Expected to load meals.")
    
    try await withThrowingTaskGroup(of: (MealInfo, Result<Meal, any Error>).self) { group in
      // For each meal in the category, attempt to fetch and decode the full meal object.
      for mealInfo in meals {
        group.addTask {
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
