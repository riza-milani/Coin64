//
//  LazyView.swift
//  Coin64
//
//  Created by Reza on 27.04.25.
//
import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
