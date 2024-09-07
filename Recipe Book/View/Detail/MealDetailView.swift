//
//  MealDetailView.swift
//  Recipe Book
//
//  Created by Josh Birnholz on 9/3/24.
//

import SwiftUI

struct MealDetailView: View {
  @State var viewModel: MealDetailViewModel
  
  var body: some View {
    Group {
      switch viewModel.state {
      case .meal(let meal):
        MealView(
          meal: meal,
          formattedInstructions: viewModel.formattedInstructions ?? meal.instructions,
          flag: viewModel.flagEmoji
        ).toolbar {
            if let source = meal.source {
              ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: source) {
                  Image(systemName: "square.and.arrow.up")
                }
              }
            }
          }
      case .empty:
        ContentUnavailableView(
          "Something went wrong",
          systemImage: "fork.knife"
        )
      case .loading:
        ProgressView()
      case .error(let string):
        ContentUnavailableView(
          "Something went wrong",
          systemImage: "fork.knife",
          description: Text(string)
        )
      }
    }.navigationBarTitleDisplayMode(.inline)
    .task {
      if viewModel.meal == nil {
        await viewModel.fetchMeal()
      }
    }
  }
}

struct MealView: View {
  let meal: Meal
  let formattedInstructions: String
  let flag: String?
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        MealViewHeader(imageURL: meal.thumbnailURL, title: meal.name)
        
        VStack(alignment: .leading, spacing: 20) {
          HStack {
            Text(meal.category)
              .foregroundStyle(.secondary)
            Spacer()
            if let flag {
              Text(flag)
                .font(.largeTitle)
            }
          }
          
          HStack {
            Text("Ingredients")
              .font(.headline)
          }
          
          IngredientsList(ingredients: meal.ingredients)
          
          HStack {
            Text("Instructions")
              .font(.headline)
          }
          
          Text(formattedInstructions)
        }.padding()
      }
    }
  }
}

struct MealViewHeader: View {
  let imageURL: URL?
  let title: String
  
  var body: some View {
    ZStack(alignment: .bottomLeading) {
      AsyncSqureImage(url: imageURL)
      
      LinearGradient(colors: [.black.opacity(0.5), .clear], startPoint: .bottom, endPoint: .center)
      
      Text(title)
        .foregroundStyle(.white)
        .font(.title)
        .bold()
        .padding()
    }
  }
}

struct IngredientsList: View {
  let ingredients: [Meal.Ingredient]
  
  var body: some View {
    VStack {
      ForEach(ingredients) { ingredient in
        ZStack(alignment: .bottom) {
          RoundedRectangle(cornerRadius: 8)
            .foregroundStyle(.quinary)
          
          HStack(spacing: 6) {
            AsyncSqureImage(url: ingredient.thumbnailURL, placeholder: {
              Color.clear
            }).frame(width: 30, height: 30)
            
            Text(ingredient.name)
              .fixedSize(horizontal: false, vertical: true)
              .multilineTextAlignment(.center)
            
            Spacer(minLength: 0)
              
            Text(ingredient.measurement)
              .foregroundStyle(.secondary)
          }.padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    MealDetailView(viewModel: .init(
      mealInfo: .init(
        name: "Apple & Blackberry Crumble",
        thumbnailURL: URL(string: "https://www.themealdb.com/images/media/meals/xvsurr1511719182.jpg"),
        id: "52893"
      )
    ))
  }
}

#Preview {
  CategoryView()
    .environment(Router())
}
