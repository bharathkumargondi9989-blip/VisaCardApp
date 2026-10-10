import Foundation
import UIKit

/// Item ViewModel for rendering an individual transaction cell
public struct TransactionItemViewModel {
    public let transaction: CardTransaction

    public init(transaction: CardTransaction) {
        self.transaction = transaction
    }

    public var merchantName: String {
        return transaction.merchantName
    }

    public var categoryName: String {
        return transaction.category.rawValue
    }

    public var formattedDate: String {
        return transaction.formattedDate
    }

    public var formattedAmount: String {
        return transaction.formattedAmount
    }

    public var isPositive: Bool {
        return transaction.isPositive
    }

    public var iconName: String {
        return transaction.category.systemIconName
    }

    public var iconBackgroundColor: UIColor {
        return transaction.category.iconBackgroundColor
    }

    public var iconTintColor: UIColor {
        return transaction.category.iconTintColor
    }

    public var amountColor: UIColor {
        return isPositive ? .emeraldSuccess : .textPrimary
    }
}
