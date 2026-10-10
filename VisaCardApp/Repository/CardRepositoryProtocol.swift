import Foundation

/// Repository protocol defining operations for Visa Card and Transactions
public protocol CardRepositoryProtocol {
    func getCard() -> VisaCard
    func setCardFrozen(_ isFrozen: Bool)
    func setSpendingLimit(_ limit: Double)
    func getTransactions() -> [CardTransaction]
    func recordTransaction(merchant: String, amount: Double, category: TransactionCategory) -> CardTransaction
}
