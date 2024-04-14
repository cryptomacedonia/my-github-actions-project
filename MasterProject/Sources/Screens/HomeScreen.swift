//
//  HomeScreen.swift
//  SwiftUp
//
//  Created by Igor Jovcevski on 10.1.24.
//

import Foundation
import Kingfisher
import SwiftUI

struct FeaturedItem: Identifiable {
    var id = UUID()
    var name: String
    var description: String
    var imageUrl: String
}

struct CategoryItem: Identifiable {
    var id = UUID()
    var name: String
    var imageUrl: String
}

struct RecommendedProduct: Identifiable {
    var id = UUID()
    var name: String
    var imageUrl: String
}

struct HomeScreen: View {
    let featuredItems: [FeaturedItem] = [
        FeaturedItem(name: "Special Offer", description: "Limited time offer!", imageUrl: "https://picsum.photos/300"),
        FeaturedItem(name: "New Arrivals", description: "Check out the latest products", imageUrl: "https://picsum.photos/300"),
    ]

    let categoryItems: [CategoryItem] = [
        CategoryItem(name: "Electronics", imageUrl: "https://picsum.photos/100"),
        CategoryItem(name: "Clothing", imageUrl: "https://picsum.photos/100"),
        CategoryItem(name: "Home Decor", imageUrl: "https://picsum.photos/100"),
        CategoryItem(name: "Books", imageUrl: "https://picsum.photos/100"),
    ]

    let recommendedProducts: [RecommendedProduct] = [
        RecommendedProduct(name: "Product A", imageUrl: "https://picsum.photos/150"),
        RecommendedProduct(name: "Product B", imageUrl: "https://picsum.photos/150"),
        RecommendedProduct(name: "Product C", imageUrl: "https://picsum.photos/150"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Featured Section
                Text("Featured")
                    .font(.title)
                    .bold()
                    .padding(.leading, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(featuredItems) { item in
                            FeaturedItemCard(item: item)
                        }
                    }
                    .padding(16)
                }

                // Categories
                Text("Categories")
                    .font(.title)
                    .bold()
                    .padding(.leading, 16)

                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 16) {
                    ForEach(categoryItems) { category in
                        CategoryItemCard(category: category)
                    }
                }
                .padding(16)

                // Recommended Products
                Text("Recommended Products")
                    .font(.title)
                    .bold()
                    .padding(.leading, 16)

                ForEach(recommendedProducts) { product in
                    RecommendedProductCard(product: product)
                        .padding(.horizontal, 16)
                }
            }
        }
        .navigationTitle("Home")
    }
}

struct FeaturedItemCard: View {
    var item: FeaturedItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            KFImage(URL(string:item.imageUrl))
                .resizable().aspectRatio(contentMode: .fill)


            Text(item.name)
                .font(.headline)
                .bold()

            Text(item.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .frame(width: 150)
        .padding(8)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

struct CategoryItemCard: View {
    var category: CategoryItem

    var body: some View {
        VStack {
            KFImage(URL(string:category.imageUrl))
                .resizable().resizable().aspectRatio(contentMode: .fill)
            Text(category.name)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .cornerRadius(5)
        .shadow(radius: 4)
    }
}

struct RecommendedProductCard: View {
    var product: RecommendedProduct

    var body: some View {
        HStack {
            KFImage(URL(string:product.imageUrl))
                .resizable().resizable().frame(width: 70, height: 70)


            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .bold()

                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
            }

            Spacer()
        }
        .cornerRadius(5)
        .shadow(radius: 4)
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
