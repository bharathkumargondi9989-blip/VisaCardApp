import UIKit

/// TableView Cell backed by XIB, rendering Product Name, Rate, and Quantity Stepper
final class ProductTableViewCell: UITableViewCell, UITextFieldDelegate {
    static let reuseIdentifier = "ProductTableViewCell"

    // MARK: - IBOutlets
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var quantityTextField: UITextField!

    // MARK: - Callbacks
    var onQuantityChanged: ((Int) -> Void)?

    // MARK: - Properties
    private var currentQuantity: Int = 0
    private var unitPrice: Double = 0.0

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Card Styling
        cardContainerView.backgroundColor = .cardBackground
        cardContainerView.layer.cornerRadius = 12
        cardContainerView.layer.borderWidth = 1
        cardContainerView.layer.borderColor = UIColor.borderLight.cgColor
        cardContainerView.layer.shadowColor = UIColor.black.cgColor
        cardContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cardContainerView.layer.shadowOpacity = 0.05
        cardContainerView.layer.shadowRadius = 4

        // Button Styling with modern UIButton.Configuration
        var minusConfig = UIButton.Configuration.filled()
        minusConfig.title = "−"
        minusConfig.baseForegroundColor = .white
        minusConfig.baseBackgroundColor = .appPrimary
        minusConfig.cornerStyle = .medium
        minusButton.configuration = minusConfig

        var plusConfig = UIButton.Configuration.filled()
        plusConfig.title = "+"
        plusConfig.baseForegroundColor = .white
        plusConfig.baseBackgroundColor = .appPrimary
        plusConfig.cornerStyle = .medium
        plusButton.configuration = plusConfig

        // TextField Styling
        quantityTextField.backgroundColor = .stepperBackground
        quantityTextField.layer.cornerRadius = 6
        quantityTextField.layer.borderWidth = 1
        quantityTextField.layer.borderColor = UIColor.borderLight.cgColor
        quantityTextField.textAlignment = .center
        quantityTextField.keyboardType = .numberPad
        quantityTextField.delegate = self
        quantityTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        addDoneButtonToKeyboard()
    }

    private func addDoneButtonToKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        toolbar.items = [flexSpace, doneButton]
        quantityTextField.inputAccessoryView = toolbar
    }

    @objc private func didTapDone() {
        quantityTextField.resignFirstResponder()
    }

    // MARK: - Configuration
    func configure(with viewModel: ProductItemViewModel) {
        self.unitPrice = viewModel.price
        nameLabel.text = viewModel.name
        rateLabel.text = "Rate: \(viewModel.formattedPrice)"
        currentQuantity = viewModel.quantity
        quantityTextField.text = "\(currentQuantity)"
        updateSubtotal()
        updateButtonStates()
    }

    private func updateSubtotal() {
        if currentQuantity > 0 {
            subtotalLabel.isHidden = false
            let total = Double(currentQuantity) * unitPrice
            subtotalLabel.text = String(format: "Subtotal: ₹ %.2f", total)
        } else {
            subtotalLabel.isHidden = true
        }
    }

    // MARK: - IBActions
    @IBAction func didTapMinus(_ sender: UIButton) {
        guard currentQuantity > 0 else { return }
        currentQuantity -= 1
        quantityTextField.text = "\(currentQuantity)"
        updateSubtotal()
        updateButtonStates()
        onQuantityChanged?(currentQuantity)
    }

    @IBAction func didTapPlus(_ sender: UIButton) {
        currentQuantity += 1
        quantityTextField.text = "\(currentQuantity)"
        updateSubtotal()
        updateButtonStates()
        onQuantityChanged?(currentQuantity)
    }

    @objc private func textFieldDidChange() {
        let text = quantityTextField.text ?? ""
        if let val = Int(text) {
            currentQuantity = max(0, val)
        } else if text.isEmpty {
            currentQuantity = 0
        }
        updateSubtotal()
        updateButtonStates()
        onQuantityChanged?(currentQuantity)
    }

    // MARK: - UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = "\(currentQuantity)"
        updateButtonStates()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        guard allowedCharacters.isSuperset(of: characterSet) else { return false }

        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        return newString.count <= 4
    }

    private func updateButtonStates() {
        minusButton.isEnabled = currentQuantity > 0
        var config = minusButton.configuration ?? UIButton.Configuration.filled()
        config.baseBackgroundColor = currentQuantity > 0 ? .appPrimary : UIColor.systemGray4
        config.baseForegroundColor = currentQuantity > 0 ? .white : UIColor.systemGray2
        minusButton.configuration = config
    }
}
