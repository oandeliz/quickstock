# QuickStock 📦⚡

An offline-first, multi-role inventory management and last-mile delivery verification engine built with **Flutter**, **Drift (SQLite)**, **Riverpod**, and **AWS Amplify Gen 2**.

QuickStock bridges warehouse floor operations, fleet logistics, and customer ordering with zero cloud lag. By using a local-first persistence model coupled with cryptographic QR handshakes, delivery drops and stock mutations are guaranteed even in cellular dead zones.

---

## 🚀 Key Highlights & Architecture

* **Offline-First Persistence (Drift / SQLite):** Sub-millisecond reads and writes directly on the device. Background synchronization queues transactions until network connectivity is restored.
* **Reactive State Architecture (Riverpod 2.x):** Unidirectional data flow utilizing asynchronous code generation notifiers and derived real-time search filters.
* **Cryptographic QR Delivery Handshake:** Generates time-sensitive, randomized 6-character tokens (`QS-XXXXXX`) bound to order records. Drivers verify drops instantly via native camera feed or manual alphanumeric fallback.
* **Multi-Role Scaffolding:** Granular interface isolation across three core operational roles:
  * 🏢 **Business Owner / Manager:** Catalog CRUD, real-time stock overrides, low-stock threshold monitoring, and team oversight.
  * 🚚 **Delivery Driver:** Active route inspection, camera barcode viewfinder with hardware torch toggle, and one-tap delivery verification.
  * 🛍️ **Customer Storefront:** Real-time catalog search, order creation, and high-contrast delivery verification token display.
* **Enterprise Cloud Backend (AWS Amplify Gen 2):** Infrastructure as Code (IaC) powered by AWS CDK, featuring Cognito User Pools, DynamoDB, and Bedrock-ready serverless integration points.

---

## 🛠️ Tech Stack & Tooling

| Layer | Technologies |
| :--- | :--- |
| **Framework** | Flutter 3.x (iOS, Android, Web) |
| **Language** | Dart 3.x |
| **State Management** | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` |
| **Local Database** | `drift`, `drift_flutter`, `sqlite3` |
| **Hardware & Peripherals** | `mobile_scanner`, `qr_flutter` |
| **Cloud & Identity** | AWS Amplify Gen 2, AWS Cognito, Amazon DynamoDB |
| **Code Generation** | `build_runner` |

---

## 📁 Repository Structure

```text
lib/
├── core/
│   ├── database/                  # Drift tables, migrations, and database engine
│   │   ├── app_database.dart
│   │   └── tables/                # ProductsTable, OrdersTable schemas
│   └── providers/                 # Top-level database and client bindings
├── features/
│   ├── inventory/                 # Stock catalog, local mutations, and search logic
│   │   └── presentation/providers/# InventoryNotifier, ProductSearchQuery
│   ├── orders/                    # Order processing and customer token views
│   │   └── presentation/widgets/  # DeliveryQrView
│   └── delivery/                  # Driver route logic, camera viewfinder, and verification
│       ├── presentation/providers/# DeliveryNotifier
│       └── presentation/widgets/  # DeliveryScannerView
└── main.dart                      # App entry point, ProviderScope, and navigation harness
```

---

## 📅 Engineering Sprint Roadmap

- [x] **Day 1:** Project scaffolding, Amplify Gen 2 sandbox initialization.
- [x] **Day 2:** Drift local database architecture and offline repository layer.
- [x] **Day 3:** Riverpod reactive state binding and mock data hydration.
- [x] **Day 4:** Customer QR code generator (qr_flutter) & driver camera scanner (mobile_scanner).
- [ ] **Day 5 (In Progress):** Multi-role dashboard UI (Business Owner, Driver, Customer, Warehouse) + global catalog search.