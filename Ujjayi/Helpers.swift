//
//  Helpers.swift
//  test-220118-ujjayi
//
//  Created by Aleksandr Borisov on 20.01.2022.
//

import Foundation
import Combine

extension Publisher where Failure == Never {
    func weakAssign<T: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<T, Output>,
        on object: T
    ) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
    
    func weakSink<T: AnyObject>(
        _ weaklyCaptured: T,
        receiveValue: @escaping (T, Self.Output) -> Void
    ) -> AnyCancellable {
        sink { [weak weaklyCaptured] output in
            guard let strongRef = weaklyCaptured else { return }
            receiveValue(strongRef, output)
        }
    }
}

extension Publisher {
    func dateStringFromSeconds() -> AnyPublisher<String, Never> {
        self
            .map {
                let dateFormatter = DateFormatter()
                var dateComponents = DateComponents()
                dateFormatter.dateFormat = "m:ss"
                dateComponents.second = $0 as? Int
                if let date = Calendar.current.date(from: dateComponents) {
                    return dateFormatter.string(from: date)
                } else {
                    return ""
                }
            }
            .replaceError(with: "")
            .eraseToAnyPublisher()
    }
}
