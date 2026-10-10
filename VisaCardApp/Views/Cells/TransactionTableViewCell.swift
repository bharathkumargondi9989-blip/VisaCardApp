import UIKit

/// High-end table view cell backed by TransactionTableViewCell.xib
public final class TransactionTableViewCell: UITableViewCell {
    public static let reuseIdentifier = "TransactionTableViewCell"

    // MARK: - IBOutlets
    @IBOutlet public weak var iconContainerView: UIView!
    @IBOutlet public weak var iconImageView: UIImageView!
    @IBOutlet public weak var merchantNameLabel: UILabel!
    @IBOutlet public weak var categoryAndDateLabel: UILabel!
    @IBOutlet public weak var amountLabel: UILabel!

    // MARK: - Lifecycle
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        iconContainerView.layer.cornerRadius = 14
        iconContainerView.clipsToBounds = true
    }

    // MARK: - Configuration
    public func configure(with viewModel: TransactionItemViewModel) {
        merchantNameLabel.text = viewModel.merchantName
        categoryAndDateLabel.text = "\(viewModel.categoryName) • \(viewModel.formattedDate)"
        amountLabel.text = viewModel.formattedAmount
        amountLabel.textColor = viewModel.amountColor

        iconContainerView.backgroundColor = viewModel.iconBackgroundColor
        iconImageView.image = UIImage(systemName: viewModel.iconName)
        iconImageView.tintColor = viewModel.iconTintColor
    }
}
