//
//  CategoryView.swift
//  Recipe Book
//
//  Created by Josh Birnholz on 9/3/24.
//

import SwiftUI

// MARK: Main category view

struct CategoryView: View {
  @State private var viewModel: MealCategoryViewModel
  @Environment(Router.self) private var router
  
  @MainActor init() {
    self._viewModel = State(wrappedValue: .init(categoryName: "Dessert"))
  }
  
  var body: some View {
    NavigationStack {
      Group {
        switch viewModel.state {
        case .meals(let meals):
          MealGrid(title: viewModel.categoryName, meals: meals)
            .searchable(text: $viewModel.query)
        case .empty:
          ContentUnavailableView(
            "No Recipes Available",
            systemImage: "fork.knife"
          )
        case .loading:
          ProgressView()
        case .error(let error):
          ContentUnavailableView {
            Text("Something went wrong")
              .bold()
          } description: {
            Text(error)
          } actions: {
            Button {
              Task {
                await viewModel.fetchMeals()
              }
            } label: {
              Label("Retry", systemImage: "arrow.counterclockwise")
            }
          }
        }
      }.navigationTitle("Recipe Book")
        .task {
          if viewModel.meals == nil {
            await viewModel.fetchMeals()
          }
        }.navigationDestination(for: Route.self, destination: router.destination(for:))
    }
  }
}

// MARK: Meal Grid

struct MealGrid: View {
  let title: String
  let meals: [MealInfo]
  
  var body: some View {
    ScrollView {
      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
        Section {
          ForEach(meals) { meal in
            NavigationLink(value: Route.meal(meal)) {
              MealGridItem(meal: meal)
            }.buttonStyle(.plain)
          }
        } header: {
          HStack {
            Text(title)
              .font(.title2)
              .bold()
            Spacer()
          }.padding(.horizontal, 8)
          .background(.background)
        }
      }.padding(8)
        .animation(.default, value: meals)
    }
  }
}

struct MealGridItem: View {
  let meal: MealInfo
  
  var body: some View {
    VStack(alignment: .leading) {
      AsyncSqureImage(url: meal.thumbnailURL)
        .clipShape(RoundedRectangle(cornerRadius: 16))
      
      Text(meal.name)
        .font(.subheadline)
        .bold()
        .lineLimit(2, reservesSpace: true)
    }
  }
}

#Preview {
  CategoryView()
    .environment(Router())
}
