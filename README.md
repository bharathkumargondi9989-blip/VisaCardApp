# Product List App

A native iOS application implementing a Product Catalog, Quantity Stepper, Dynamic Cart Calculations, Core Data local persistence, and Order Submission with remarks, built using **Swift**, **UIKit**, **XIBs**, and the **MVVM Architecture**.

---

## 🏛️ Architecture Overview

The application follows the **Model-View-ViewModel (MVVM)** design pattern combined with the **Repository Pattern** for a clean separation of concerns and testability:

```
┌────────────────────────────────────────────────────────┐
│                   PRESENTATION (UI)                    │
│  - ProductListViewController.swift & .xib              │
│  - ProductTableViewCell.swift & .xib                   │
│  - Remarks UIAlertController                           │
└───────────────────────────┬────────────────────────────┘
                            │ (Binds via closures & protocols)
┌───────────────────────────▼────────────────────────────┐
│                    VIEWMODEL LAYER                     │
│  - ProductListViewModelProtocol                        │
│  - ProductListViewModel                                │
│  - ProductItemViewModel                                │
│  * Reactive summary calculations (Items, Qty, Amount)  │
│  * State management (.idle, .loading, .loaded, .saving)│
└───────────────────────────┬────────────────────────────┘
                            │ (Calls Repository interface)
┌───────────────────────────▼────────────────────────────┐
│               DOMAIN & REPOSITORY LAYER                │
│  - ProductRepositoryProtocol                           │
│  - ProductRepository                                   │
│  * Orchestrates Token Auth -> Products & Rates Sync    │
│  * Joins Product [id] with Rate [Product_Detail_Code]  │
│  * Coordinates Core Data offline persistence           │
└──────────────┬───────────────────────────┬─────────────┘
               │                           │
┌──────────────▼─────────────┐ ┌───────────▼─────────────┐
│       NETWORK LAYER        │ │     CORE DATA LAYER     │
│  - NetworkService          │ │  - CoreDataStack        │
│  - APIRoute                │ │  - ProductEntity        │
│  - SessionManager          │ │  * SQLite local storage │
│  * URLSession async/await  │ └─────────────────────────┘
│  * Bearer token injection  │
└────────────────────────────┘
```

---

## 🚀 Key Features & Requirements

1. **Authentication (API 1)**:
   - Authenticates via `POST /api/ioslogin` with user credentials.
   - Extracts and maintains the `Jwt_Token` session.

2. **Master Sync (API 2 & API 3)**:
   - Fetches product catalog from `GET /api/qc/getmasterSync?Master_Name=Products...`.
   - Fetches retailer pricing from `GET /api/qc/getmasterSync?Master_Name=StateRate...`.
   - Matches and joins product records by product code.

3. **Core Data Local Persistence**:
   - Stores the synchronized product catalog in a local SQLite database (`ProductEntity`).
   - Supports offline app launch directly from local storage.

4. **Product List Screen & XIBs**:
   - Designed using Interface Builder (`.xib`) with zero manual AutoLayout code in Swift.
   - Displays Product Name, Rate (`Rate: ₹ 10.00`), Subtotal, and Quantity Stepper.
   - Stepper consists of Minus `[−]`, editable `[UITextField]`, and Plus `[+]` buttons.
   - Restricts non-numeric input and prevents negative quantities.

5. **Dynamic Summary Card**:
   - Automatically recalculates totals in real-time on every keystroke or button tap:
     - **Total Items**: Number of distinct products with `quantity > 0`.
     - **Total Qty**: Sum of all product quantities (`∑ qty`).
     - **Total Amount**: Formatted order total (`₹ ∑ (rate × qty)`).
   - "Save Order" button is enabled only when items are in the cart.

6. **Save Flow & Save API (Page 3)**:
   - Tapping Save displays a native alert with a `TextField` capturing user remarks.
   - Validates remarks to prevent empty submissions.
   - Posts order payload to `POST /api/qc/SaveSampleIos` matching the specified JSON schema.
   - On server confirmation (`"Order saved successfully."`), automatically resets cart quantities.

---

## 🛠️ Tech Stack & Requirements

- **Language**: Swift 5.0+
- **UI Framework**: UIKit + XIB (Interface Builder)
- **Architecture**: MVVM + Repository Pattern
- **Persistence**: Core Data (SQLite)
- **Networking**: URLSession with `async/await`
- **Compatibility**: iOS 15.0+ (Tested on iOS 17 / iOS 18 / Xcode 15 / 16 / 26 / 27)
- **External Dependencies**: **None** (100% native Apple frameworks, zero CocoaPods/SPM dependencies).

---

## 💻 How to Run

1. Open `ProductListApp.xcodeproj` in Xcode:
   ```bash
   open ProductListApp.xcodeproj
   ```
2. Select any iPhone simulator (e.g., iPhone 16 / 17 / 18).
3. Press **Run (`⌘R`)** to build and launch the application.
