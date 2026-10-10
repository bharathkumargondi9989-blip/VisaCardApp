import Foundation
import CoreData

// MARK: - Card Entity
@objc(CardEntity)
public class CardEntity: NSManagedObject {}

extension CardEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardEntity> {
        return NSFetchRequest<CardEntity>(entityName: "CardEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var cardholderName: String?
    @NSManaged public var cardNumber: String?
    @NSManaged public var expiryMonth: Int16
    @NSManaged public var expiryYear: Int16
    @NSManaged public var cvv: String?
    @NSManaged public var tierRaw: String?
    @NSManaged public var balance: Double
    @NSManaged public var creditLimit: Double
    @NSManaged public var spendingLimit: Double
    @NSManaged public var isFrozen: Bool
    @NSManaged public var isOnlinePurchasesEnabled: Bool
    @NSManaged public var isInternationalEnabled: Bool
    @NSManaged public var billingCycleDaysLeft: Int16

    func toDomainModel() -> VisaCard {
        return VisaCard(
            id: id ?? UUID().uuidString,
            cardholderName: cardholderName ?? "BHARATH KUMAR",
            cardNumber: cardNumber ?? "4532 8920 1849 9021",
            expiryMonth: Int(expiryMonth == 0 ? 8 : expiryMonth),
            expiryYear: Int(expiryYear == 0 ? 2029 : expiryYear),
            cvv: cvv ?? "742",
            tier: VisaCardTier(rawValue: tierRaw ?? "") ?? .infinite,
            balance: balance,
            creditLimit: creditLimit == 0 ? 15000.0 : creditLimit,
            spendingLimit: spendingLimit == 0 ? 5000.0 : spendingLimit,
            isFrozen: isFrozen,
            isOnlinePurchasesEnabled: isOnlinePurchasesEnabled,
            isInternationalEnabled: isInternationalEnabled,
            billingCycleDaysLeft: Int(billingCycleDaysLeft == 0 ? 18 : billingCycleDaysLeft)
        )
    }
}

// MARK: - Transaction Entity
@objc(TransactionEntity)
public class TransactionEntity: NSManagedObject {}

extension TransactionEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionEntity> {
        return NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var merchantName: String?
    @NSManaged public var categoryRaw: String?
    @NSManaged public var date: Date?
    @NSManaged public var amount: Double
    @NSManaged public var statusRaw: String?
    @NSManaged public var note: String?

    func toDomainModel() -> CardTransaction {
        let category = TransactionCategory(rawValue: categoryRaw ?? "") ?? .shopping
        let status = TransactionStatus(rawValue: statusRaw ?? "") ?? .completed
        return CardTransaction(
            id: id ?? UUID().uuidString,
            merchantName: merchantName ?? "Merchant",
            category: category,
            date: date ?? Date(),
            amount: amount,
            status: status,
            note: note
        )
    }
}
