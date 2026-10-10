import Foundation

/// Main ViewModel governing the Visa Card Dashboard, calculations, and actions
public final class CardDashboardViewModel: CardDashboardViewModelProtocol {

    private let repository: CardRepositoryProtocol

    public private(set) var card: VisaCard
    public private(set) var transactionViewModels: [TransactionItemViewModel] = []
    public private(set) var isCardDetailsMasked: Bool = true
    public private(set) var state: CardDashboardViewState = .idle {
        didSet {
            onStateChange?(state)
        }
    }

    public var onStateChange: ((CardDashboardViewState) -> Void)?
    public var onCardUpdated: (() -> Void)?
    public var onTransactionsUpdated: (() -> Void)?

    public init(repository: CardRepositoryProtocol = CardRepository()) {
        self.repository = repository
        self.card = repository.getCard()
    }

    public func loadDashboard() {
        state = .loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            self.refreshData()
            self.state = .loaded
        }
    }

    private func refreshData() {
        self.card = repository.getCard()
        let txs = repository.getTransactions()
        self.transactionViewModels = txs.map { TransactionItemViewModel(transaction: $0) }
        onCardUpdated?()
        onTransactionsUpdated?()
    }

    public func toggleFreeze() {
        let newFreezeState = !card.isFrozen
        repository.setCardFrozen(newFreezeState)
        self.card = repository.getCard()
        onCardUpdated?()
        state = .cardFreezeToggled(isFrozen: newFreezeState)
    }

    public func toggleCardDetailsMask() {
        isCardDetailsMasked.toggle()
        onCardUpdated?()
    }

    public func updateSpendingLimit(to limit: Double) {
        repository.setSpendingLimit(limit)
        self.card = repository.getCard()
        onCardUpdated?()
    }

    public func makePurchase(merchant: String, amount: Double, category: TransactionCategory) {
        if card.isFrozen {
            state = .error(message: "Card is currently frozen. Please unfreeze your Visa card before making a purchase.")
            return
        }

        let newTx = repository.recordTransaction(
            merchant: merchant,
            amount: -abs(amount),
            category: category
        )
        refreshData()
        state = .transactionAdded(
            merchant: merchant,
            amount: CurrencyHelper.format(abs(amount))
        )
    }
}
