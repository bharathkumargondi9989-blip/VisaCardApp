import UIKit

/// Main Visa Card Dashboard View Controller backed by CardDashboardViewController.xib
public final class CardDashboardViewController: UIViewController {

    // MARK: - IBOutlets (Connected to CardDashboardViewController.xib)
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var cardPlaceholderView: UIView!
    @IBOutlet weak var freezeButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var simulateButton: UIButton!
    @IBOutlet weak var limitsButton: UIButton!
    @IBOutlet weak var availableCreditValueLabel: UILabel!
    @IBOutlet weak var spentBalanceValueLabel: UILabel!
    @IBOutlet weak var creditProgressBar: UIProgressView!
    @IBOutlet weak var utilizationLabel: UILabel!
    @IBOutlet weak var transactionBadgeLabel: UILabel!

    // MARK: - Properties
    private let viewModel: CardDashboardViewModelProtocol
    private let refreshControl = UIRefreshControl()
    private let cardView = VisaCardView()

    // MARK: - Initializer
    public init(viewModel: CardDashboardViewModelProtocol = CardDashboardViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: "CardDashboardViewController", bundle: nil)
    }

    public required init?(coder: NSCoder) {
        self.viewModel = CardDashboardViewModel()
        super.init(coder: coder)
    }

    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCardView()
        setupTableView()
        setupActionButtons()
        setupBindings()

        viewModel.loadDashboard()
    }

    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        title = "Visa Card"
        navigationController?.navigationBar.prefersLargeTitles = false

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.textPrimary,
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        // Right Bar Button: Add Transaction
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill"),
            style: .done,
            target: self,
            action: #selector(didTapSimulatePurchase(_:))
        )
        navigationItem.rightBarButtonItem?.tintColor = .visaBlue

        // Left Bar Button: Refresh
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(didTapRefresh)
        )
        navigationItem.leftBarButtonItem?.tintColor = .textSecondary
    }

    // MARK: - View Setup
    private func setupCardView() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardPlaceholderView.addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cardPlaceholderView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: cardPlaceholderView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: cardPlaceholderView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: cardPlaceholderView.bottomAnchor)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        // Register XIB Cell
        let nib = UINib(nibName: "TransactionTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: TransactionTableViewCell.reuseIdentifier)
        tableView.rowHeight = 76
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .borderLight
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 76, bottom: 0, right: 16)

        refreshControl.addTarget(self, action: #selector(didPullRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        transactionBadgeLabel.backgroundColor = UIColor(red: 0.10, green: 0.12, blue: 0.44, alpha: 0.08)
        transactionBadgeLabel.layer.cornerRadius = 8
        transactionBadgeLabel.clipsToBounds = true
    }

    private func setupActionButtons() {
        let buttons = [freezeButton, detailsButton, simulateButton, limitsButton]
        for btn in buttons {
            btn?.layer.borderWidth = 1
            btn?.layer.borderColor = UIColor.borderLight.cgColor
            btn?.layer.cornerRadius = 12
            btn?.clipsToBounds = true
        }
    }

    // MARK: - MVVM Bindings
    private func setupBindings() {
        viewModel.onCardUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.updateCardAndSummary()
            }
        }

        viewModel.onTransactionsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                self?.tableView.reloadData()
                self?.updateTransactionBadge()
            }
        }

        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleStateChange(state)
            }
        }
    }

    private func handleStateChange(_ state: CardDashboardViewState) {
        switch state {
        case .idle, .loading:
            break
        case .loaded:
            refreshControl.endRefreshing()
            updateCardAndSummary()
            tableView.reloadData()
            updateTransactionBadge()
        case .cardFreezeToggled(let isFrozen):
            let msg = isFrozen ? "Visa card locked. All purchases are now disabled." : "Visa card unlocked and active."
            showAlert(title: isFrozen ? "Card Locked" : "Card Unlocked", message: msg)
        case .transactionAdded(let merchant, let amount):
            showAlert(title: "Purchase Approved", message: "Successfully charged \(amount) at \(merchant).")
        case .error(let message):
            showAlert(title: "Notice", message: message)
        }
    }

    private func updateCardAndSummary() {
        let card = viewModel.card
        cardView.configure(with: card, isMasked: viewModel.isCardDetailsMasked)

        availableCreditValueLabel.text = card.formattedAvailableCredit
        spentBalanceValueLabel.text = card.formattedBalance
        creditProgressBar.setProgress(Float(card.creditUtilizationRatio), animated: true)

        let utilizationPercent = Int(card.creditUtilizationRatio * 100)
        utilizationLabel.text = "\(utilizationPercent)% of \(card.formattedCreditLimit) limit used • \(card.billingCycleDaysLeft) days left"

        // Update Freeze Button
        var freezeConfig = freezeButton.configuration
        freezeConfig?.title = card.isFrozen ? "Unlock" : "Lock"
        freezeConfig?.image = UIImage(systemName: card.isFrozen ? "lock.open.fill" : "lock.shield")
        freezeConfig?.baseForegroundColor = card.isFrozen ? .expenseRed : .textPrimary
        freezeButton.configuration = freezeConfig

        // Update Details Button
        var detailsConfig = detailsButton.configuration
        detailsConfig?.title = viewModel.isCardDetailsMasked ? "Details" : "Hide"
        detailsConfig?.image = UIImage(systemName: viewModel.isCardDetailsMasked ? "eye" : "eye.slash")
        detailsButton.configuration = detailsConfig
    }

    private func updateTransactionBadge() {
        let count = viewModel.transactionViewModels.count
        transactionBadgeLabel.text = " \(count) "
    }

    // MARK: - IBActions
    @IBAction func didTapFreeze(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        viewModel.toggleFreeze()
    }

    @IBAction func didTapToggleDetails(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        viewModel.toggleCardDetailsMask()
    }

    @IBAction func didTapSimulatePurchase(_ sender: Any) {
        let modal = NewTransactionViewController()
        modal.onTransactionSubmitted = { [weak self] merchant, amount, category in
            self?.viewModel.makePurchase(merchant: merchant, amount: amount, category: category)
        }
        if let sheet = modal.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(modal, animated: true)
    }

    @IBAction func didTapSetLimit(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Spending Limit",
            message: "Adjust your monthly card spending limit:",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Enter limit (e.g. 7500)"
            textField.keyboardType = .numberPad
            textField.text = "\(Int(self.viewModel.card.spendingLimit))"
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save Limit", style: .default, handler: { [weak self, weak alert] _ in
            if let text = alert?.textFields?.first?.text, let limit = Double(text), limit > 0 {
                self?.viewModel.updateSpendingLimit(to: limit)
            }
        }))

        present(alert, animated: true)
    }

    @objc private func didTapRefresh() {
        viewModel.loadDashboard()
    }

    @objc private func didPullRefresh() {
        viewModel.loadDashboard()
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension CardDashboardViewController: UITableViewDataSource, UITableViewDelegate {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.transactionViewModels.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TransactionTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? TransactionTableViewCell else {
            return UITableViewCell()
        }

        let itemVM = viewModel.transactionViewModels[indexPath.row]
        cell.configure(with: itemVM)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let itemVM = viewModel.transactionViewModels[indexPath.row]
        let message = "Merchant: \(itemVM.merchantName)\nCategory: \(itemVM.categoryName)\nDate: \(itemVM.formattedDate)\nAmount: \(itemVM.formattedAmount)"
        showAlert(title: "Transaction Details", message: message)
    }
}
