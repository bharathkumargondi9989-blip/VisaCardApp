import UIKit

/// High-end virtual Visa Card component featuring 3D flip animation, realistic chip, contactless wave, and frozen lock overlay
public final class VisaCardView: UIView {

    // MARK: - Subviews
    private let containerView = UIView()
    private let frontView = UIView()
    private let backView = UIView()
    private let frozenOverlayView = UIView()

    // Front Elements
    private let frontGradientLayer = CAGradientLayer()
    private let chipView = UIView()
    private let contactlessImageView = UIImageView()
    private let cardNumberLabel = UILabel()
    private let cardholderLabel = UILabel()
    private let expiryLabel = UILabel()
    private let expiryTitleLabel = UILabel()
    private let cardholderTitleLabel = UILabel()
    private let visaLogoLabel = UILabel()
    private let visaGoldBar = UIView()
    private let tierBadgeLabel = UILabel()
    private let flipHintLabel = UILabel()

    // Back Elements
    private let backGradientLayer = CAGradientLayer()
    private let magneticStripe = UIView()
    private let signatureStrip = UIView()
    private let cvvTitleLabel = UILabel()
    private let cvvValueLabel = UILabel()
    private let hologramView = UIView()
    private let backDisclaimerLabel = UILabel()

    // Frozen Overlay Elements
    private let lockIconImageView = UIImageView()
    private let frozenTitleLabel = UILabel()
    private let frozenSubtitleLabel = UILabel()

    // MARK: - State
    public private(set) var isShowingBack: Bool = false
    private var isMasked: Bool = true
    private var currentCard: VisaCard?

    // MARK: - Initializer
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        frontGradientLayer.frame = frontView.bounds
        backGradientLayer.frame = backView.bounds
        
        // Add subtle shadow to container
        layer.shadowColor = UIColor(red: 0.05, green: 0.10, blue: 0.25, alpha: 0.35).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowRadius = 16
        layer.shadowOpacity = 1.0
    }

    // MARK: - Setup
    private func setupViews() {
        backgroundColor = .clear

        // Container
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        addSubview(containerView)

        // Setup Front and Back
        setupFrontView()
        setupBackView()
        setupFrozenOverlay()

        containerView.addSubview(backView)
        containerView.addSubview(frontView)
        containerView.addSubview(frozenOverlayView)

        backView.isHidden = true
        frozenOverlayView.isHidden = true

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            frontView.topAnchor.constraint(equalTo: containerView.topAnchor),
            frontView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            frontView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            frontView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            backView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            frozenOverlayView.topAnchor.constraint(equalTo: containerView.topAnchor),
            frozenOverlayView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            frozenOverlayView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            frozenOverlayView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        // Tap Gesture for 3D Flip
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCard))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    // MARK: - Front View Setup
    private func setupFrontView() {
        frontView.translatesAutoresizingMaskIntoConstraints = false
        frontView.layer.cornerRadius = 16
        frontView.clipsToBounds = true

        // Metallic obsidian-navy gradient
        frontGradientLayer.colors = [
            UIColor(red: 0.08, green: 0.12, blue: 0.22, alpha: 1.0).cgColor,
            UIColor(red: 0.05, green: 0.08, blue: 0.15, alpha: 1.0).cgColor
        ]
        frontGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        frontGradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        frontView.layer.insertSublayer(frontGradientLayer, at: 0)

        // Visa Logo & Gold Accent
        visaLogoLabel.translatesAutoresizingMaskIntoConstraints = false
        visaLogoLabel.text = "VISA"
        visaLogoLabel.font = UIFont.systemFont(ofSize: 24, weight: .black)
        visaLogoLabel.textColor = .white
        visaLogoLabel.letterSpacing = 1.2
        frontView.addSubview(visaLogoLabel)

        visaGoldBar.translatesAutoresizingMaskIntoConstraints = false
        visaGoldBar.backgroundColor = .visaGold
        visaGoldBar.layer.cornerRadius = 1.5
        frontView.addSubview(visaGoldBar)

        // Tier Badge (e.g. INFINITE)
        tierBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        tierBadgeLabel.text = "INFINITE"
        tierBadgeLabel.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        tierBadgeLabel.textColor = UIColor(white: 0.85, alpha: 0.9)
        tierBadgeLabel.letterSpacing = 2.0
        frontView.addSubview(tierBadgeLabel)

        // Flip Hint Pill
        flipHintLabel.translatesAutoresizingMaskIntoConstraints = false
        flipHintLabel.text = "FLIP ↻"
        flipHintLabel.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
        flipHintLabel.textColor = UIColor(white: 1.0, alpha: 0.6)
        flipHintLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        flipHintLabel.layer.cornerRadius = 6
        flipHintLabel.clipsToBounds = true
        flipHintLabel.textAlignment = .center
        frontView.addSubview(flipHintLabel)

        // EMV Chip
        chipView.translatesAutoresizingMaskIntoConstraints = false
        chipView.backgroundColor = UIColor(red: 0.88, green: 0.74, blue: 0.45, alpha: 1.0)
        chipView.layer.cornerRadius = 6
        chipView.layer.borderWidth = 1
        chipView.layer.borderColor = UIColor(red: 0.72, green: 0.58, blue: 0.32, alpha: 1.0).cgColor
        setupChipDetails(on: chipView)
        frontView.addSubview(chipView)

        // Contactless NFC Wave
        contactlessImageView.translatesAutoresizingMaskIntoConstraints = false
        contactlessImageView.image = UIImage(systemName: "wave.3.right")
        contactlessImageView.tintColor = UIColor(white: 0.85, alpha: 0.8)
        contactlessImageView.contentMode = .scaleAspectFit
        frontView.addSubview(contactlessImageView)

        // Card Number
        cardNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        cardNumberLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .bold)
        cardNumberLabel.textColor = .white
        cardNumberLabel.letterSpacing = 2.2
        frontView.addSubview(cardNumberLabel)

        // Cardholder
        cardholderTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardholderTitleLabel.text = "CARDHOLDER"
        cardholderTitleLabel.font = UIFont.systemFont(ofSize: 8, weight: .bold)
        cardholderTitleLabel.textColor = UIColor(white: 0.75, alpha: 0.7)
        cardholderTitleLabel.letterSpacing = 1.0
        frontView.addSubview(cardholderTitleLabel)

        cardholderLabel.translatesAutoresizingMaskIntoConstraints = false
        cardholderLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        cardholderLabel.textColor = .white
        cardholderLabel.letterSpacing = 1.2
        frontView.addSubview(cardholderLabel)

        // Expiry
        expiryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        expiryTitleLabel.text = "EXPIRES"
        expiryTitleLabel.font = UIFont.systemFont(ofSize: 8, weight: .bold)
        expiryTitleLabel.textColor = UIColor(white: 0.75, alpha: 0.7)
        expiryTitleLabel.letterSpacing = 1.0
        frontView.addSubview(expiryTitleLabel)

        expiryLabel.translatesAutoresizingMaskIntoConstraints = false
        expiryLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .bold)
        expiryLabel.textColor = .white
        expiryLabel.letterSpacing = 1.0
        frontView.addSubview(expiryLabel)

        // Front AutoLayout
        NSLayoutConstraint.activate([
            visaLogoLabel.topAnchor.constraint(equalTo: frontView.topAnchor, constant: 18),
            visaLogoLabel.leadingAnchor.constraint(equalTo: frontView.leadingAnchor, constant: 22),

            visaGoldBar.leadingAnchor.constraint(equalTo: visaLogoLabel.trailingAnchor, constant: 4),
            visaGoldBar.centerYAnchor.constraint(equalTo: visaLogoLabel.centerYAnchor),
            visaGoldBar.widthAnchor.constraint(equalToConstant: 3),
            visaGoldBar.heightAnchor.constraint(equalToConstant: 16),

            tierBadgeLabel.leadingAnchor.constraint(equalTo: visaGoldBar.trailingAnchor, constant: 6),
            tierBadgeLabel.centerYAnchor.constraint(equalTo: visaLogoLabel.centerYAnchor),

            flipHintLabel.centerYAnchor.constraint(equalTo: visaLogoLabel.centerYAnchor),
            flipHintLabel.trailingAnchor.constraint(equalTo: frontView.trailingAnchor, constant: -20),
            flipHintLabel.widthAnchor.constraint(equalToConstant: 52),
            flipHintLabel.heightAnchor.constraint(equalToConstant: 20),

            chipView.topAnchor.constraint(equalTo: visaLogoLabel.bottomAnchor, constant: 16),
            chipView.leadingAnchor.constraint(equalTo: frontView.leadingAnchor, constant: 22),
            chipView.widthAnchor.constraint(equalToConstant: 42),
            chipView.heightAnchor.constraint(equalToConstant: 30),

            contactlessImageView.centerYAnchor.constraint(equalTo: chipView.centerYAnchor),
            contactlessImageView.leadingAnchor.constraint(equalTo: chipView.trailingAnchor, constant: 14),
            contactlessImageView.widthAnchor.constraint(equalToConstant: 20),
            contactlessImageView.heightAnchor.constraint(equalToConstant: 20),

            cardNumberLabel.topAnchor.constraint(equalTo: chipView.bottomAnchor, constant: 18),
            cardNumberLabel.leadingAnchor.constraint(equalTo: frontView.leadingAnchor, constant: 22),
            cardNumberLabel.trailingAnchor.constraint(equalTo: frontView.trailingAnchor, constant: -22),

            cardholderTitleLabel.topAnchor.constraint(equalTo: cardNumberLabel.bottomAnchor, constant: 14),
            cardholderTitleLabel.leadingAnchor.constraint(equalTo: frontView.leadingAnchor, constant: 22),

            cardholderLabel.topAnchor.constraint(equalTo: cardholderTitleLabel.bottomAnchor, constant: 2),
            cardholderLabel.leadingAnchor.constraint(equalTo: frontView.leadingAnchor, constant: 22),
            cardholderLabel.bottomAnchor.constraint(equalTo: frontView.bottomAnchor, constant: -18),

            expiryTitleLabel.centerYAnchor.constraint(equalTo: cardholderTitleLabel.centerYAnchor),
            expiryTitleLabel.trailingAnchor.constraint(equalTo: frontView.trailingAnchor, constant: -22),

            expiryLabel.topAnchor.constraint(equalTo: expiryTitleLabel.bottomAnchor, constant: 2),
            expiryLabel.trailingAnchor.constraint(equalTo: frontView.trailingAnchor, constant: -22),
        ])
    }

    private func setupChipDetails(on view: UIView) {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(red: 0.72, green: 0.58, blue: 0.32, alpha: 0.8)
        view.addSubview(line)
        NSLayoutConstraint.activate([
            line.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            line.topAnchor.constraint(equalTo: view.topAnchor),
            line.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            line.widthAnchor.constraint(equalToConstant: 1)
        ])
    }

    // MARK: - Back View Setup
    private func setupBackView() {
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.layer.cornerRadius = 16
        backView.clipsToBounds = true

        backGradientLayer.colors = [
            UIColor(red: 0.07, green: 0.10, blue: 0.18, alpha: 1.0).cgColor,
            UIColor(red: 0.04, green: 0.06, blue: 0.12, alpha: 1.0).cgColor
        ]
        backGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        backGradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        backView.layer.insertSublayer(backGradientLayer, at: 0)

        // Magnetic Stripe
        magneticStripe.translatesAutoresizingMaskIntoConstraints = false
        magneticStripe.backgroundColor = UIColor(white: 0.10, alpha: 1.0)
        backView.addSubview(magneticStripe)

        // Signature & CVV Panel
        signatureStrip.translatesAutoresizingMaskIntoConstraints = false
        signatureStrip.backgroundColor = UIColor(white: 0.94, alpha: 1.0)
        signatureStrip.layer.cornerRadius = 4
        backView.addSubview(signatureStrip)

        cvvTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cvvTitleLabel.text = "CVV / SECURITY CODE"
        cvvTitleLabel.font = UIFont.systemFont(ofSize: 8, weight: .bold)
        cvvTitleLabel.textColor = UIColor(white: 0.7, alpha: 0.8)
        cvvTitleLabel.letterSpacing = 1.0
        backView.addSubview(cvvTitleLabel)

        cvvValueLabel.translatesAutoresizingMaskIntoConstraints = false
        cvvValueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .bold)
        cvvValueLabel.textColor = .black
        cvvValueLabel.textAlignment = .center
        signatureStrip.addSubview(cvvValueLabel)

        // Hologram View
        hologramView.translatesAutoresizingMaskIntoConstraints = false
        hologramView.backgroundColor = UIColor(red: 0.7, green: 0.75, blue: 0.85, alpha: 0.25)
        hologramView.layer.cornerRadius = 6
        hologramView.layer.borderWidth = 1
        hologramView.layer.borderColor = UIColor(white: 1.0, alpha: 0.2).cgColor
        backView.addSubview(hologramView)

        let holoLabel = UILabel()
        holoLabel.translatesAutoresizingMaskIntoConstraints = false
        holoLabel.text = "VISA"
        holoLabel.font = UIFont.systemFont(ofSize: 10, weight: .black)
        holoLabel.textColor = UIColor(white: 1.0, alpha: 0.6)
        hologramView.addSubview(holoLabel)

        // Disclaimer
        backDisclaimerLabel.translatesAutoresizingMaskIntoConstraints = false
        backDisclaimerLabel.text = "Authorized Signature • Not Valid Unless Signed\nVisa Global Concierge: 1-800-VISA-INF"
        backDisclaimerLabel.numberOfLines = 2
        backDisclaimerLabel.font = UIFont.systemFont(ofSize: 8, weight: .medium)
        backDisclaimerLabel.textColor = UIColor(white: 0.6, alpha: 0.8)
        backView.addSubview(backDisclaimerLabel)

        NSLayoutConstraint.activate([
            magneticStripe.topAnchor.constraint(equalTo: backView.topAnchor, constant: 22),
            magneticStripe.leadingAnchor.constraint(equalTo: backView.leadingAnchor),
            magneticStripe.trailingAnchor.constraint(equalTo: backView.trailingAnchor),
            magneticStripe.heightAnchor.constraint(equalToConstant: 38),

            cvvTitleLabel.topAnchor.constraint(equalTo: magneticStripe.bottomAnchor, constant: 14),
            cvvTitleLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 22),

            signatureStrip.topAnchor.constraint(equalTo: cvvTitleLabel.bottomAnchor, constant: 4),
            signatureStrip.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 22),
            signatureStrip.widthAnchor.constraint(equalToConstant: 180),
            signatureStrip.heightAnchor.constraint(equalToConstant: 32),

            cvvValueLabel.centerYAnchor.constraint(equalTo: signatureStrip.centerYAnchor),
            cvvValueLabel.trailingAnchor.constraint(equalTo: signatureStrip.trailingAnchor, constant: -10),

            hologramView.centerYAnchor.constraint(equalTo: signatureStrip.centerYAnchor),
            hologramView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -22),
            hologramView.widthAnchor.constraint(equalToConstant: 50),
            hologramView.heightAnchor.constraint(equalToConstant: 32),

            holoLabel.centerXAnchor.constraint(equalTo: hologramView.centerXAnchor),
            holoLabel.centerYAnchor.constraint(equalTo: hologramView.centerYAnchor),

            backDisclaimerLabel.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -14),
            backDisclaimerLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 22),
            backDisclaimerLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -22),
        ])
    }

    // MARK: - Frozen Overlay Setup
    private func setupFrozenOverlay() {
        frozenOverlayView.translatesAutoresizingMaskIntoConstraints = false
        frozenOverlayView.backgroundColor = UIColor(red: 0.08, green: 0.14, blue: 0.25, alpha: 0.92)
        frozenOverlayView.layer.cornerRadius = 16
        frozenOverlayView.clipsToBounds = true

        lockIconImageView.translatesAutoresizingMaskIntoConstraints = false
        lockIconImageView.image = UIImage(systemName: "lock.fill")
        lockIconImageView.tintColor = .white
        lockIconImageView.contentMode = .scaleAspectFit
        frozenOverlayView.addSubview(lockIconImageView)

        frozenTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        frozenTitleLabel.text = "CARD LOCKED"
        frozenTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .black)
        frozenTitleLabel.textColor = .white
        frozenTitleLabel.letterSpacing = 1.5
        frozenOverlayView.addSubview(frozenTitleLabel)

        frozenSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        frozenSubtitleLabel.text = "Transactions & purchases are paused"
        frozenSubtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        frozenSubtitleLabel.textColor = UIColor(white: 0.85, alpha: 0.9)
        frozenOverlayView.addSubview(frozenSubtitleLabel)

        NSLayoutConstraint.activate([
            lockIconImageView.centerXAnchor.constraint(equalTo: frozenOverlayView.centerXAnchor),
            lockIconImageView.centerYAnchor.constraint(equalTo: frozenOverlayView.centerYAnchor, constant: -20),
            lockIconImageView.widthAnchor.constraint(equalToConstant: 36),
            lockIconImageView.heightAnchor.constraint(equalToConstant: 36),

            frozenTitleLabel.topAnchor.constraint(equalTo: lockIconImageView.bottomAnchor, constant: 10),
            frozenTitleLabel.centerXAnchor.constraint(equalTo: frozenOverlayView.centerXAnchor),

            frozenSubtitleLabel.topAnchor.constraint(equalTo: frozenTitleLabel.bottomAnchor, constant: 4),
            frozenSubtitleLabel.centerXAnchor.constraint(equalTo: frozenOverlayView.centerXAnchor),
        ])
    }

    // MARK: - Flip Animation
    @objc private func didTapCard() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        isShowingBack.toggle()

        let fromView = isShowingBack ? frontView : backView
        let toView = isShowingBack ? backView : frontView

        let transitionOptions: UIView.AnimationOptions = [
            isShowingBack ? .transitionFlipFromRight : .transitionFlipFromLeft,
            .showHideTransitionViews
        ]

        UIView.transition(with: containerView, duration: 0.5, options: transitionOptions, animations: {
            fromView.isHidden = true
            toView.isHidden = false
        }, completion: nil)
    }

    // MARK: - Configuration
    public func configure(with card: VisaCard, isMasked: Bool) {
        self.currentCard = card
        self.isMasked = isMasked

        cardholderLabel.text = card.cardholderName.uppercased()
        tierBadgeLabel.text = card.tier.badgeTitle
        expiryLabel.text = card.formattedExpiry

        cardNumberLabel.text = isMasked ? card.maskedCardNumber : card.cardNumber
        cvvValueLabel.text = isMasked ? card.maskedCVV : card.cvv

        // Freeze State
        if card.isFrozen {
            frozenOverlayView.isHidden = false
            frozenOverlayView.alpha = 1.0
        } else {
            UIView.animate(withDuration: 0.25) {
                self.frozenOverlayView.alpha = 0.0
            } completion: { _ in
                self.frozenOverlayView.isHidden = true
            }
        }
    }
}

// MARK: - UILabel Letter Spacing Helper
private extension UILabel {
    var letterSpacing: CGFloat {
        get { return 0 }
        set {
            guard let text = self.text else { return }
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(
                .kern,
                value: newValue,
                range: NSRange(location: 0, length: text.count)
            )
            self.attributedText = attributedString
        }
    }
}
