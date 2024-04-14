//
//  EmptyScreen.swift
//  SwiftUp
//
//  Created by Igor Jovcevski on 10.1.24.
//

import Foundation

import SwiftUI

struct EmptyScreen: View {
    var body: some View {
        VStack {
            Image(systemName: "pencil")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
                .padding(20)

            Text("This screen is empty!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .padding(.bottom, 20)

            Text("You can put any content you want here.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
        .navigationTitle("Empty Screen")
    }
}

struct EmptyScreen_Previews: PreviewProvider {
    static var previews: some View {
        EmptyScreen()
    }
}
