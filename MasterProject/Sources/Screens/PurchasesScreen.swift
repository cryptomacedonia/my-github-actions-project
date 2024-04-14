//
//  PurchasesScreen.swift
//  SwiftUp
//
//  Created by Igor Jovcevski on 10.1.24.
//

import Foundation

import SwiftUI

struct PurchaseItem: Identifiable {
    var id = UUID()
    var name: String
    var price: Double
    var imageUrl: String
}

struct PurchasesScreen: View {
    let sampleData: [PurchaseItem] = [
        PurchaseItem(name: "Product 1", price: 19.99, imageUrl: "https://via.placeholder.com/150"),
        PurchaseItem(name: "Product 2", price: 29.99, imageUrl: "https://via.placeholder.com/150"),
        PurchaseItem(name: "Product 3", price: 39.99, imageUrl: "https://via.placeholder.com/150"),
        PurchaseItem(name: "Product 4", price: 49.99, imageUrl: "https://via.placeholder.com/150"),
    ]

    var body: some View {
        NavigationView {
            List(sampleData) { item in
                NavigationLink(destination: PurchaseDetailScreen(item: item)) {
                    PurchaseRow(item: item)
                }
            }
            .navigationTitle("Purchases")
        }
    }
}

struct PurchaseRow: View {
    var item: PurchaseItem

    var body: some View {
        HStack {
            Image(systemName: "cart")
                .resizable()
                .frame(width: 50, height: 50)
                .padding(10)
                .background(Color.blue)
                .clipShape(Circle())
                .foregroundColor(.white)

            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text("$\(item.price)")
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 10)
    }
}

struct PurchaseDetailScreen: View {
    var item: PurchaseItem

    var body: some View {
        VStack {
            Image(systemName: "cart")
                .resizable()
                .frame(width: 100, height: 100)
                .padding(20)
                .background(Color.blue)
                .clipShape(Circle())
                .foregroundColor(.white)

            Text(item.name)
                .font(.title)
                .padding(.bottom, 10)

            Text("$\(item.price)")
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("Details")
    }
}

struct PurchasesScreen_Previews: PreviewProvider {
    static var previews: some View {
        PurchasesScreen()
    }
}
