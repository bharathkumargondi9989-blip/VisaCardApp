import UIKit

/// Main Product List View Controller backed by ProductListViewController.xib
final class ProductListViewController: UIViewController {

    // MARK: - IBOutlets (Connected to ProductListViewController.xib)
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var summaryCardView: UIView!
    @IBOutlet weak var totalItemsLabel: UILabel!
    @IBOutlet weak var totalQtyLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var summaryCardBottomConstraint: NSLayoutConstraint!

    // MARK: - Dependencies
    private let viewModel: ProductListViewModelProtocol
    private let refreshControl = UIRefreshControl()

    // MARK: - Initializer
    init(viewModel: ProductListViewModelProtocol = ProductListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: "ProductListViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = ProductListViewModel()
        super.init(coder: coder)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCardStyle()
        setupTableView()
        setupBindings()
        setupKeyboardObservers()

        viewModel.loadProducts()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Products"
        navigationController?.navigationBar.prefersLargeTitles = true

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.textPrimary]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.textPrimary]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(didTapRefresh)
        )
    }

    private func setupCardStyle() {
        summaryCardView.layer.cornerRadius = 16
        summaryCardView.layer.shadowColor = UIColor.black.cgColor
        summaryCardView.layer.shadowOffset = CGSize(width: 0, height: -3)
        summaryCardView.layer.shadowOpacity = 0.08
        summaryCardView.layer.shadowRadius = 8

        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
        updateSaveButtonState(isEnabled: false)
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "ProductTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: ProductTableViewCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        refreshControl.addTarget(self, action: #selector(didPullRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    // MARK: - MVVM Bindings
    private func setupBindings() {
        viewModel.onStateChange = { [weak self] state in
            self?.handleStateChange(state)
        }

        viewModel.onTotalsUpdated = { [weak self] in
            self?.updateSummaryCard()
        }
    }

    private func handleStateChange(_ state: ProductListViewState) {
        refreshControl.endRefreshing()

        switch state {
        case .idle:
            loadingIndicator.stopAnimating()

        case .loading:
            loadingIndicator.startAnimating()

        case .loaded:
            loadingIndicator.stopAnimating()
            tableView.reloadData()
            updateSummaryCard()

        case .saving:
            loadingIndicator.startAnimating()

        case .saveSuccess(let message):
            loadingIndicator.stopAnimating()
            tableView.reloadData()
            updateSummaryCard()
            showSuccessAlert(message: message)

        case .error(let message):
            loadingIndicator.stopAnimating()
            showErrorAlert(message: message)
        }
    }

    private func updateSummaryCard() {
        totalItemsLabel.text = "\(viewModel.totalItems)"
        totalQtyLabel.text = "\(viewModel.totalQuantity)"
        totalAmountLabel.text = viewModel.formattedTotalAmount
        updateSaveButtonState(isEnabled: viewModel.isSaveEnabled)
    }

    private func updateSaveButtonState(isEnabled: Bool) {
        saveButton.isEnabled = isEnabled
        saveButton.alpha = isEnabled ? 1.0 : 0.4
        saveButton.backgroundColor = isEnabled ? .appPrimary : UIColor.systemGray4
    }

    // MARK: - IBActions
    @IBAction func didTapSave(_ sender: UIButton) {
        presentRemarksAlert()
    }

    @objc private func didTapRefresh() {
        viewModel.loadProducts()
    }

    @objc private func didPullRefresh() {
        viewModel.loadProducts()
    }

    // MARK: - Save Flow
    /// PDF Specification: "On tapping Save, show an alert with a TextField to capture the user's remarks before saving the product list."
    private func presentRemarksAlert() {
        let alert = UIAlertController(
            title: "Save Product List",
            message: "Please enter your remarks for this order:",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Enter remarks (e.g. Urgent delivery)"
            textField.autocapitalizationType = .sentences
            textField.accessibilityIdentifier = "remarksTextField"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alert] _ in
            guard let remarks = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !remarks.isEmpty else {
                self?.showErrorAlert(message: "Remarks cannot be empty.")
                return
            }
            self?.viewModel.submitOrder(remarks: remarks)
        }

        alert.addAction(cancelAction)
        alert.addAction(submitAction)

        present(alert, animated: true, completion: nil)
    }

    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(
            title: "Success",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Notice",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        summaryCardBottomConstraint.constant = -keyboardHeight

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        summaryCardBottomConstraint.constant = 0

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ProductListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.productViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProductTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? ProductTableViewCell else {
            return UITableViewCell()
        }

        let itemVM = viewModel.productViewModels[indexPath.row]
        cell.configure(with: itemVM)

        cell.onQuantityChanged = { [weak self] newQty in
            self?.viewModel.setQuantity(at: indexPath.row, quantity: newQty)
        }

        return cell
    }
}
