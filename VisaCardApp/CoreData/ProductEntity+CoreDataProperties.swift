import Foundation
import CoreData

@objc(ProductEntity)
public class ProductEntity: NSManagedObject {

}

extension ProductEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductEntity> {
        return NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var code: String?
    @NSManaged public var retailerPrice: Double
    @NSManaged public var quantity: Int32
    @NSManaged public var divisionCode: Int32
    @NSManaged public var lastUpdated: Date?

    func toDomainModel() -> ProductItem? {
        guard let id = id, let name = name else { return nil }
        return ProductItem(
            id: id,
            name: name,
            code: code ?? "",
            retailerPrice: retailerPrice,
            quantity: Int(quantity),
            divisionCode: Int(divisionCode)
        )
    }
}

extension ProductEntity : Identifiable {

}
