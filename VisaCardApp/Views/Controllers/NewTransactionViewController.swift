import UIKit

/// Modal sheet allowing the user to simulate an in-store or online Visa card transaction
public final class NewTransactionViewController: UIViewController {

    // MARK: - Callbacks
    public var onTransactionSubmitted: ((String, Double, TransactionCategory) -> Void)?

    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let merchantTextField = UITextField()
    private let amountTextField = UITextField()
    private let categorySegmentedControl = UISegmentedControl()
    private let submitButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)

    private let categories: [TransactionCategory] = [
        .dining, .shopping, .tech, .travel, .groceries
    ]

    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Simulate Visa Purchase"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .textPrimary
        view.addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Authorize a new transaction using your virtual card"
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = .textSecondary
        view.addSubview(subtitleLabel)

        // Merchant Input
        merchantTextField.translatesAutoresizingMaskIntoConstraints = false
        merchantTextField.placeholder = "Merchant Name (e.g., Apple Store)"
        merchantTextField.borderStyle = .none
        merchantTextField.backgroundColor = .appBackground
        merchantTextField.layer.cornerRadius = 10
        merchantTextField.layer.borderWidth = 1
        merchantTextField.layer.borderColor = UIColor.borderLight.cgColor
        merchantTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        merchantTextField.leftViewMode = .always
        merchantTextField.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        view.addSubview(merchantTextField)

        // Amount Input
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.placeholder = "Amount ($) (e.g., 85.50)"
        amountTextField.borderStyle = .none
        amountTextField.backgroundColor = .appBackground
        amountTextField.layer.cornerRadius = 10
        amountTextField.layer.borderWidth = 1
        amountTextField.layer.borderColor = UIColor.borderLight.cgColor
        amountTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        amountTextField.leftViewMode = .always
        amountTextField.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
        amountTextField.keyboardType = .decimalPad
        view.addSubview(amountTextField)

        // Category Picker
        categorySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        for (index, cat) in categories.enumerated() {
            categorySegmentedControl.insertSegment(withTitle: cat.rawValue.components(separatedBy: " ").first ?? cat.rawValue, at: index, animated: false)
        }
        categorySegmentedControl.selectedSegmentIndex = 0
        view.addSubview(categorySegmentedControl)

        // Submit Button
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        var submitConfig = UIButton.Configuration.filled()
        submitConfig.title = "Authorize & Pay"
        submitConfig.baseBackgroundColor = .visaBlue
        submitConfig.baseForegroundColor = .white
        submitConfig.cornerStyle = .medium
        submitButton.configuration = submitConfig
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        view.addSubview(submitButton)

        // Cancel Button
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.textSecondary, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            merchantTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            merchantTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            merchantTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            merchantTextField.heightAnchor.constraint(equalToConstant: 48),

            amountTextField.topAnchor.constraint(equalTo: merchantTextField.bottomAnchor, constant: 14),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            amountTextField.heightAnchor.constraint(equalToConstant: 48),

            categorySegmentedControl.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 18),
            categorySegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categorySegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            submitButton.topAnchor.constraint(equalTo: categorySegmentedControl.bottomAnchor, constant: 28),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50),

            cancelButton.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 12),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapSubmit() {
        guard let merchant = merchantTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !merchant.isEmpty else {
            showAlert("Please enter a merchant name.")
            return
        }

        guard let amountStr = amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let amount = Double(amountStr), amount > 0 else {
            showAlert("Please enter a valid amount greater than $0.")
            return
        }

        let selectedCat = categories[categorySegmentedControl.selectedSegmentIndex]

        dismiss(animated: true) { [weak self] in
            self?.onTransactionSubmitted?(merchant, amount, selectedCat)
        }
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
