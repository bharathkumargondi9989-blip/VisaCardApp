import UIKit

extension UIColor {
    // MARK: - Visa Brand & Core Colors
    static let visaBlue = UIColor(red: 0.10, green: 0.12, blue: 0.44, alpha: 1.0) // #1A1F71
    static let visaGold = UIColor(red: 0.97, green: 0.71, blue: 0.00, alpha: 1.0) // #F7B600
    static let visaDarkNavy = UIColor(red: 0.06, green: 0.09, blue: 0.16, alpha: 1.0) // #0F172A
    
    // MARK: - Surfaces & Backgrounds
    static let appBackground = UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1.0) // #F5F7FC
    static let cardBackground = UIColor.white
    static let surfaceElevated = UIColor(red: 0.98, green: 0.99, blue: 1.00, alpha: 1.0)
    static let cardFrozenOverlay = UIColor(red: 0.15, green: 0.23, blue: 0.36, alpha: 0.88)
    
    // MARK: - Card Gradients
    static let cardGradientTop = UIColor(red: 0.08, green: 0.11, blue: 0.22, alpha: 1.0) // Obsidian Sapphire
    static let cardGradientBottom = UIColor(red: 0.13, green: 0.24, blue: 0.42, alpha: 1.0)
    static let chipGold = UIColor(red: 0.86, green: 0.70, blue: 0.38, alpha: 1.0)
    
    // MARK: - Typography & Accents
    static let textPrimary = UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1.0) // #111726
    static let textSecondary = UIColor(red: 0.42, green: 0.47, blue: 0.54, alpha: 1.0) // #6B788A
    static let textMuted = UIColor(red: 0.60, green: 0.65, blue: 0.72, alpha: 1.0)
    static let borderLight = UIColor(red: 0.90, green: 0.92, blue: 0.95, alpha: 1.0)
    
    // MARK: - Financial State Colors
    static let emeraldSuccess = UIColor(red: 0.06, green: 0.73, blue: 0.51, alpha: 1.0) // #10B981
    static let expenseRed = UIColor(red: 0.94, green: 0.27, blue: 0.27, alpha: 1.0) // #EF4444
    static let warningAmber = UIColor(red: 0.96, green: 0.62, blue: 0.12, alpha: 1.0)
    static let accentPurple = UIColor(red: 0.49, green: 0.34, blue: 0.89, alpha: 1.0)
    
    // MARK: - Backwards Compatibility
    static let appPrimary = visaBlue
    static let appPrimaryDark = visaDarkNavy
    static let appAccent = visaGold
}
