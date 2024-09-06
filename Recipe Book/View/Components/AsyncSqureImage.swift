//
//  AsyncSqureImage.swift
//  Recipe Book
//
//  Created by Josh Birnholz on 9/5/24.
//

import Foundation
import SwiftUI
import CachedAsyncImage

/// A View that displays a cached async image which fits its content into a square shape.
struct AsyncSqureImage<Placeholder: View>: View {
  
  let url: URL?
  let placeholder: () -> Placeholder
  
  init(url: URL?, @ViewBuilder placeholder: @escaping () -> Placeholder) {
    self.url = url
    self.placeholder = placeholder
  }
  
  var body: some View {
    CachedAsyncImage(url: url) { image in
      image
        .resizable()
    } placeholder: {
      placeholder()
    }
    .aspectRatio(1, contentMode: .fill)
  }
  
}

extension AsyncSqureImage where Placeholder == Color {
  /// Initializes an `AsyncSquareImage` with a default gray placeholder.
  init(url: URL?) {
    self.url = url
    self.placeholder = { .gray }
  }
}
