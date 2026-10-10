import Foundation
import UIKit

// MARK: - Visa Card Tier
public enum VisaCardTier: String, Codable {
    case infinite = "Visa Infinite"
    case signature = "Visa Signature"
    case platinum = "Visa Platinum"
    
    public var badgeTitle: String {
        return rawValue.uppercased()
    }
}


// MARK: - Visa Card Domain Model
public struct VisaCard: Codable, Identifiable {
    public let id: String
    public var cardholderName: String
    public var cardNumber: String
    public var expiryMonth: Int
    public var expiryYear: Int
    public var cvv: String
    public var tier: VisaCardTier
    public var balance: Double
    public var creditLimit: Double
    public var spendingLimit: Double
    public var isFrozen: Bool
    public var isOnlinePurchasesEnabled: Bool
    public var isInternationalEnabled: Bool
    public var billingCycleDaysLeft: Int
    
    public init(
        id: String = UUID().uuidString,
        cardholderName: String,
        cardNumber: String,
        expiryMonth: Int,
        expiryYear: Int,
        cvv: String,
        tier: VisaCardTier = .infinite,
        balance: Double,
        creditLimit: Double,
        spendingLimit: Double,
        isFrozen: Bool = false,
        isOnlinePurchasesEnabled: Bool = true,
        isInternationalEnabled: Bool = true,
        billingCycleDaysLeft: Int = 18
    ) {
        self.id = id
        self.cardholderName = cardholderName
        self.cardNumber = cardNumber
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.cvv = cvv
        self.tier = tier
        self.balance = balance
        self.creditLimit = creditLimit
        self.spendingLimit = spendingLimit
        self.isFrozen = isFrozen
        self.isOnlinePurchasesEnabled = isOnlinePurchasesEnabled
        self.isInternationalEnabled = isInternationalEnabled
        self.billingCycleDaysLeft = billingCycleDaysLeft
    }
    
    // MARK: - Computed Formatters
    public var availableCredit: Double {
        return max(0.0, creditLimit - balance)
    }
    
    public var creditUtilizationRatio: Double {
        guard creditLimit > 0 else { return 0 }
        return min(1.0, max(0.0, balance / creditLimit))
    }
    
    public var formattedBalance: String {
        return CurrencyHelper.format(balance)
    }
    
    public var formattedCreditLimit: String {
        return CurrencyHelper.format(creditLimit)
    }
    
    public var formattedAvailableCredit: String {
        return CurrencyHelper.format(availableCredit)
    }
    
    public var formattedSpendingLimit: String {
        return CurrencyHelper.format(spendingLimit)
    }
    
    public var maskedCardNumber: String {
        let clean = cardNumber.replacingOccurrences(of: " ", with: "")
        guard clean.count >= 4 else { return "•••• •••• •••• 0000" }
        let last4 = clean.suffix(4)
        return "••••  ••••  ••••  \(last4)"
    }
    
    public var formattedExpiry: String {
        let monthStr = String(format: "%02d", expiryMonth)
        let yearStr = String(format: "%02d", expiryYear % 100)
        return "\(monthStr)/\(yearStr)"
    }
    
    public var maskedCVV: String {
        return "•••"
    }
}

// MARK: - Transaction Category
public enum TransactionCategory: String, Codable, CaseIterable {
    case shopping = "Shopping"
    case dining = "Dining & Food"
    case tech = "Electronics"
    case travel = "Travel & Flight"
    case entertainment = "Entertainment"
    case groceries = "Groceries"
    case subscription = "Subscription"
    case cashback = "Rewards & Cashback"
    
    public var systemIconName: String {
        switch self {
        case .shopping: return "bag.fill"
        case .dining: return "fork.knife"
        case .tech: return "laptopcomputer"
        case .travel: return "airplane"
        case .entertainment: return "film.fill"
        case .groceries: return "cart.fill"
        case .subscription: return "tv.fill"
        case .cashback: return "gift.fill"
        }
    }
    
    public var iconBackgroundColor: UIColor {
        switch self {
        case .shopping: return UIColor(red: 0.95, green: 0.40, blue: 0.50, alpha: 0.15)
        case .dining: return UIColor(red: 0.98, green: 0.58, blue: 0.24, alpha: 0.15)
        case .tech: return UIColor(red: 0.25, green: 0.50, blue: 0.95, alpha: 0.15)
        case .travel: return UIColor(red: 0.15, green: 0.70, blue: 0.85, alpha: 0.15)
        case .entertainment: return UIColor(red: 0.60, green: 0.35, blue: 0.90, alpha: 0.15)
        case .groceries: return UIColor(red: 0.20, green: 0.75, blue: 0.45, alpha: 0.15)
        case .subscription: return UIColor(red: 0.85, green: 0.30, blue: 0.70, alpha: 0.15)
        case .cashback: return UIColor(red: 0.10, green: 0.75, blue: 0.50, alpha: 0.15)
        }
    }
    
    public var iconTintColor: UIColor {
        switch self {
        case .shopping: return UIColor(red: 0.90, green: 0.25, blue: 0.40, alpha: 1.0)
        case .dining: return UIColor(red: 0.92, green: 0.48, blue: 0.15, alpha: 1.0)
        case .tech: return UIColor(red: 0.18, green: 0.42, blue: 0.88, alpha: 1.0)
        case .travel: return UIColor(red: 0.10, green: 0.60, blue: 0.78, alpha: 1.0)
        case .entertainment: return UIColor(red: 0.50, green: 0.25, blue: 0.82, alpha: 1.0)
        case .groceries: return UIColor(red: 0.15, green: 0.68, blue: 0.38, alpha: 1.0)
        case .subscription: return UIColor(red: 0.78, green: 0.20, blue: 0.60, alpha: 1.0)
        case .cashback: return UIColor(red: 0.06, green: 0.68, blue: 0.45, alpha: 1.0)
        }
    }
}

// MARK: - Transaction Status
public enum TransactionStatus: String, Codable {
    case completed = "Completed"
    case pending = "Pending"
    case refunded = "Refunded"
}

// MARK: - Card Transaction Domain Model
public struct CardTransaction: Codable, Identifiable {
    public let id: String
    public var merchantName: String
    public var category: TransactionCategory
    public var date: Date
    public var amount: Double // Negative = expense, Positive = cashback/refund
    public var status: TransactionStatus
    public var note: String?
    
    public init(
        id: String = UUID().uuidString,
        merchantName: String,
        category: TransactionCategory,
        date: Date = Date(),
        amount: Double,
        status: TransactionStatus = .completed,
        note: String? = nil
    ) {
        self.id = id
        self.merchantName = merchantName
        self.category = category
        self.date = date
        self.amount = amount
        self.status = status
        self.note = note
    }
    
    public var isPositive: Bool {
        return amount > 0
    }
    
    public var formattedAmount: String {
        let absAmount = abs(amount)
        let formatted = CurrencyHelper.format(absAmount)
        if amount > 0 {
            return "+ \(formatted)"
        } else {
            return "- \(formatted)"
        }
    }
    
    public var formattedDate: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            return "Today, \(timeFormatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            return "Yesterday, \(timeFormatter.string(from: date))"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Currency Helper
public enum CurrencyHelper {
    public static func format(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "$%.2f", value)
    }
}
