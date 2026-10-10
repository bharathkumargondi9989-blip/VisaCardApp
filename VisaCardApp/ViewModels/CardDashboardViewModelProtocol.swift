import Foundation

public enum CardDashboardViewState: Equatable {
    case idle
    case loading
    case loaded
    case cardFreezeToggled(isFrozen: Bool)
    case transactionAdded(merchant: String, amount: String)
    case error(message: String)
}

/// Protocol defining interface for Card Dashboard ViewModel
public protocol CardDashboardViewModelProtocol: AnyObject {
    var card: VisaCard { get }
    var transactionViewModels: [TransactionItemViewModel] { get }
    var isCardDetailsMasked: Bool { get }
    var state: CardDashboardViewState { get }
    
    var onStateChange: ((CardDashboardViewState) -> Void)? { get set }
    var onCardUpdated: (() -> Void)? { get set }
    var onTransactionsUpdated: (() -> Void)? { get set }

    func loadDashboard()
    func toggleFreeze()
    func toggleCardDetailsMask()
    func updateSpendingLimit(to limit: Double)
    func makePurchase(merchant: String, amount: Double, category: TransactionCategory)
}
