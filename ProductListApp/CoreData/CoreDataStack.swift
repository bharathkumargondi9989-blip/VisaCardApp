import Foundation
import CoreData

/// Core Data manager responsible for local persistence of product catalog
final class CoreDataStack {
    static let shared = CoreDataStack()

    private let containerName = "ProductListModel"

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

    var mainContext: NSManagedContextProtocol {
        return persistentContainer.viewContext
    }

    private init() {}

    /// Programmatically constructs the Managed Object Model so it works reliably in any build setup
    private static func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "ProductEntity"
        entity.managedObjectClassName = NSStringFromClass(ProductEntity.self)

        var properties: [NSPropertyDescription] = []

        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .stringAttributeType
        idAttr.isOptional = true
        properties.append(idAttr)

        let nameAttr = NSAttributeDescription()
        nameAttr.name = "name"
        nameAttr.attributeType = .stringAttributeType
        nameAttr.isOptional = true
        properties.append(nameAttr)

        let codeAttr = NSAttributeDescription()
        codeAttr.name = "code"
        codeAttr.attributeType = .stringAttributeType
        codeAttr.isOptional = true
        properties.append(codeAttr)

        let priceAttr = NSAttributeDescription()
        priceAttr.name = "retailerPrice"
        priceAttr.attributeType = .doubleAttributeType
        priceAttr.isOptional = false
        priceAttr.defaultValue = 0.0
        properties.append(priceAttr)

        let qtyAttr = NSAttributeDescription()
        qtyAttr.name = "quantity"
        qtyAttr.attributeType = .integer32AttributeType
        qtyAttr.isOptional = false
        qtyAttr.defaultValue = 0
        properties.append(qtyAttr)

        let divAttr = NSAttributeDescription()
        divAttr.name = "divisionCode"
        divAttr.attributeType = .integer32AttributeType
        divAttr.isOptional = false
        divAttr.defaultValue = 0
        properties.append(divAttr)

        let dateAttr = NSAttributeDescription()
        dateAttr.name = "lastUpdated"
        dateAttr.attributeType = .dateAttributeType
        dateAttr.isOptional = true
        properties.append(dateAttr)

        entity.properties = properties
        model.entities = [entity]
        return model
    }

    // MARK: - Core Operations

    /// Upserts products into Core Data in a background context
    func syncProducts(_ items: [ProductItem]) async throws {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        try await backgroundContext.perform {
            for item in items {
                let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", item.id)
                fetchRequest.fetchLimit = 1

                let existing = try? backgroundContext.fetch(fetchRequest).first
                let entity = existing ?? ProductEntity(context: backgroundContext)

                entity.id = item.id
                entity.name = item.name
                entity.code = item.code
                entity.retailerPrice = item.retailerPrice
                entity.divisionCode = Int32(item.divisionCode)
                entity.lastUpdated = Date()

                // Preserve existing quantity if user had modified it locally
                if existing == nil {
                    entity.quantity = Int32(item.quantity)
                }
            }

            if backgroundContext.hasChanges {
                try backgroundContext.save()
            }
        }
    }

    /// Fetches all stored products from Core Data
    func fetchProducts() -> [ProductItem] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]

        do {
            let entities = try context.fetch(request)
            return entities.compactMap { $0.toDomainModel() }
        } catch {
            print("⚠️ Failed to fetch products from Core Data: \(error)")
            return []
        }
    }

    /// Updates the quantity of a specific product in Core Data
    func updateProductQuantity(id: String, quantity: Int) {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1

        do {
            if let entity = try context.fetch(request).first {
                entity.quantity = Int32(quantity)
                try context.save()
            }
        } catch {
            print("⚠️ Failed to update product quantity: \(error)")
        }
    }

    /// Resets all product quantities back to 0 (after successful save)
    func resetAllQuantities() {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()

        do {
            let entities = try context.fetch(request)
            for entity in entities {
                entity.quantity = 0
            }
            try context.save()
        } catch {
            print("⚠️ Failed to reset quantities: \(error)")
        }
    }
}

typealias NSManagedContextProtocol = NSManagedObjectContext
