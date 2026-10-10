import Foundation
import CoreData

/// Core Data stack managing local persistence for VisaCard and CardTransactions
public final class CoreDataStack {
    public static let shared = CoreDataStack()

    private let containerName = "VisaCardModel"

    lazy var persistentContainer: NSPersistentContainer = {
        let model = CoreDataStack.createManagedObjectModel()
        let container = NSPersistentContainer(name: containerName, managedObjectModel: model)

        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                print("⚠️ Core Data failed to load store: \(error), \(error.userInfo)")
            } else {
                container.viewContext.automaticallyMergesChangesFromParent = true
                container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            }
        }
        return container
    }()

    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    private init() {
        prepopulateDefaultDataIfNeeded()
    }

    /// Programmatically constructs the Managed Object Model for CardEntity & TransactionEntity
    private static func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // 1. CardEntity
        let cardEntity = NSEntityDescription()
        cardEntity.name = "CardEntity"
        cardEntity.managedObjectClassName = NSStringFromClass(CardEntity.self)

        var cardProperties: [NSPropertyDescription] = []

        func addAttr(_ name: String, _ type: NSAttributeType, _ optional: Bool = true, _ defVal: Any? = nil) {
            let attr = NSAttributeDescription()
            attr.name = name
            attr.attributeType = type
            attr.isOptional = optional
            if let defVal = defVal { attr.defaultValue = defVal }
            cardProperties.append(attr)
        }

        addAttr("id", .stringAttributeType)
        addAttr("cardholderName", .stringAttributeType)
        addAttr("cardNumber", .stringAttributeType)
        addAttr("expiryMonth", .integer16AttributeType, false, 8)
        addAttr("expiryYear", .integer16AttributeType, false, 2029)
        addAttr("cvv", .stringAttributeType)
        addAttr("tierRaw", .stringAttributeType)
        addAttr("balance", .doubleAttributeType, false, 4850.75)
        addAttr("creditLimit", .doubleAttributeType, false, 15000.0)
        addAttr("spendingLimit", .doubleAttributeType, false, 5000.0)
        addAttr("isFrozen", .booleanAttributeType, false, false)
        addAttr("isOnlinePurchasesEnabled", .booleanAttributeType, false, true)
        addAttr("isInternationalEnabled", .booleanAttributeType, false, true)
        addAttr("billingCycleDaysLeft", .integer16AttributeType, false, 18)

        cardEntity.properties = cardProperties

        // 2. TransactionEntity
        let txEntity = NSEntityDescription()
        txEntity.name = "TransactionEntity"
        txEntity.managedObjectClassName = NSStringFromClass(TransactionEntity.self)

        var txProperties: [NSPropertyDescription] = []

        func addTxAttr(_ name: String, _ type: NSAttributeType, _ optional: Bool = true, _ defVal: Any? = nil) {
            let attr = NSAttributeDescription()
            attr.name = name
            attr.attributeType = type
            attr.isOptional = optional
            if let defVal = defVal { attr.defaultValue = defVal }
            txProperties.append(attr)
        }

        addTxAttr("id", .stringAttributeType)
        addTxAttr("merchantName", .stringAttributeType)
        addTxAttr("categoryRaw", .stringAttributeType)
        addTxAttr("date", .dateAttributeType)
        addTxAttr("amount", .doubleAttributeType, false, 0.0)
        addTxAttr("statusRaw", .stringAttributeType)
        addTxAttr("note", .stringAttributeType)

        txEntity.properties = txProperties

        model.entities = [cardEntity, txEntity]
        return model
    }

    // MARK: - Initial Seed / Pre-population
    func prepopulateDefaultDataIfNeeded() {
        let context = persistentContainer.viewContext
        let cardRequest: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        
        do {
            let count = try context.count(for: cardRequest)
            if count == 0 {
                // Seed primary Visa Infinite Card
                let card = CardEntity(context: context)
                card.id = UUID().uuidString
                card.cardholderName = "BHARATH KUMAR"
                card.cardNumber = "4532 8920 1849 9021"
                card.expiryMonth = 8
                card.expiryYear = 2029
                card.cvv = "742"
                card.tierRaw = VisaCardTier.infinite.rawValue
                card.balance = 3420.50
                card.creditLimit = 15000.00
                card.spendingLimit = 6000.00
                card.isFrozen = false
                card.isOnlinePurchasesEnabled = true
                card.isInternationalEnabled = true
                card.billingCycleDaysLeft = 14

                // Seed Initial realistic transactions
                let sampleTransactions: [(String, TransactionCategory, Double, TimeInterval)] = [
                    ("Apple Store", .tech, -1299.00, 3600 * 2), // 2 hours ago
                    ("Starbucks Reserve", .dining, -14.50, 3600 * 5),
                    ("Uber Premium Ride", .travel, -42.80, 3600 * 24), // yesterday
                    ("Visa 3% Cashback Rewards", .cashback, 75.00, 3600 * 30),
                    ("Whole Foods Market", .groceries, -182.40, 3600 * 48),
                    ("Netflix Premium 4K", .subscription, -22.99, 3600 * 72),
                    ("Amazon Marketplace", .shopping, -320.15, 3600 * 96)
                ]

                for item in sampleTransactions {
                    let tx = TransactionEntity(context: context)
                    tx.id = UUID().uuidString
                    tx.merchantName = item.0
                    tx.categoryRaw = item.1.rawValue
                    tx.amount = item.2
                    tx.date = Date().addingTimeInterval(-item.3)
                    tx.statusRaw = TransactionStatus.completed.rawValue
                    tx.note = "Verified Visa Transaction"
                }

                try context.save()
                print("💳 Pre-populated Core Data with sample Visa Card and transactions")
            }
        } catch {
            print("⚠️ Failed to check or seed initial data: \(error)")
        }
    }

    // MARK: - Card CRUD
    func fetchCard() -> VisaCard {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        request.fetchLimit = 1

        do {
            if let entity = try context.fetch(request).first {
                return entity.toDomainModel()
            }
        } catch {
            print("⚠️ Failed to fetch card: \(error)")
        }

        return VisaCard(
            cardholderName: "BHARATH KUMAR",
            cardNumber: "4532 8920 1849 9021",
            expiryMonth: 8,
            expiryYear: 2029,
            cvv: "742",
            tier: .infinite,
            balance: 3420.50,
            creditLimit: 15000.0,
            spendingLimit: 6000.0
        )
    }

    func updateCardFreeze(isFrozen: Bool) {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        request.fetchLimit = 1

        do {
            if let entity = try context.fetch(request).first {
                entity.isFrozen = isFrozen
                try context.save()
            }
        } catch {
            print("⚠️ Failed to update freeze state: \(error)")
        }
    }

    func updateSpendingLimit(_ limit: Double) {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        request.fetchLimit = 1

        do {
            if let entity = try context.fetch(request).first {
                entity.spendingLimit = limit
                try context.save()
            }
        } catch {
            print("⚠️ Failed to update spending limit: \(error)")
        }
    }

    func addTransaction(_ tx: CardTransaction) {
        let context = persistentContainer.viewContext
        let entity = TransactionEntity(context: context)
        entity.id = tx.id
        entity.merchantName = tx.merchantName
        entity.categoryRaw = tx.category.rawValue
        entity.amount = tx.amount
        entity.date = tx.date
        entity.statusRaw = tx.status.rawValue
        entity.note = tx.note

        // Update card balance automatically
        let cardReq: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        cardReq.fetchLimit = 1
        if let card = try? context.fetch(cardReq).first {
            // Purchases (negative amount) increase the spent balance
            // Cashback / payments (positive amount) decrease the spent balance
            card.balance = max(0.0, card.balance - tx.amount)
        }

        do {
            try context.save()
        } catch {
            print("⚠️ Failed to add transaction: \(error)")
        }
    }

    func fetchTransactions() -> [CardTransaction] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]

        do {
            let entities = try context.fetch(request)
            return entities.map { $0.toDomainModel() }
        } catch {
            print("⚠️ Failed to fetch transactions: \(error)")
            return []
        }
    }
}
