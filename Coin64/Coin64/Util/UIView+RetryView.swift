//
//  UIView+RetryView.swift
//  Coin64
//
//  Created by Reza on 22.04.25.
//

import UIKit


extension UIViewController {
    private var errorViewTag: Int { 1001 }
    func createErrorView(message: String, retryAction: @escaping () -> Void) {
        // Container view to hold label and button
        let container = UIView()
        container.tag = errorViewTag
        view.subviews.forEach { $0.tag == errorViewTag ? $0.removeFromSuperview() : ()}
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)

        // Error label
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false

        // Retry button
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        let action = UIAction { _ in
            retryAction()

        }
        button.addAction(action, for: .touchUpInside)

        // Add subviews to container
        container.addSubview(label)
        container.addSubview(button)

        // Layout constraints
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 12),
            button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }

    func removeErrorView() {
        view.subviews.forEach { $0.tag == errorViewTag ? $0.removeFromSuperview() : ()}
    }
}
