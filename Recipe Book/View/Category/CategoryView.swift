//
//  CategoryView.swift
//  Recipe Book
//
//  Created by Josh Birnholz on 9/3/24.
//

import SwiftUI

struct CategoryView: View {
  @State private var viewModel: MealCategoryViewModel = .init(categoryName: "Dessert")
  @Environment(Router.self) private var router
  
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
        case .error(let string):
          ContentUnavailableView(
            "No Recipes Available",
            systemImage: "fork.knife",
            description: Text(string)
          )
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
