import Foundation




/// Repository implementation orchestrating Visa Card data and Core Data persistence
public final class CardRepository: CardRepositoryProtocol {
    private let coreDataStack: CoreDataStack

    public init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    public func getCard() -> VisaCard {
        return coreDataStack.fetchCard()
    }

    public func setCardFrozen(_ isFrozen: Bool) {
        coreDataStack.updateCardFreeze(isFrozen: isFrozen)
    }

    public func setSpendingLimit(_ limit: Double) {
        coreDataStack.updateSpendingLimit(limit)
    }

    public func getTransactions() -> [CardTransaction] {
        return coreDataStack.fetchTransactions()
    }

    public func recordTransaction(merchant: String, amount: Double, category: TransactionCategory) -> CardTransaction {
        let tx = CardTransaction(
            merchantName: merchant,
            category: category,
            date: Date(),
            amount: amount,
            status: .completed,
            note: "Authorized by Visa Network"
        )
        coreDataStack.addTransaction(tx)
        return tx
    }
}
