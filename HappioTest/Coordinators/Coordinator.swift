//
//  Coordinator.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import UIKit

@MainActor
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
