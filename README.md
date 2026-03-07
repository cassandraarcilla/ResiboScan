# ResiboScan — Flutter Project
## Receipt Scanner & Organizer
### Holy Angel University — School of Computing | Group 8 | S.Y. 2025-2026

---

## Project Structure

```
resiboscan/
├── pubspec.yaml                         ← asset + dependency config
├── assets/images/
│   ├── scanner.png                      ← Card 1 image
│   ├── folder.png                       ← Card 2 image
│   └── expense.png                      ← Card 3 image
└── lib/
    ├── main.dart                        ← entry point + splash + nav
    ├── utils/constants.dart             ← colors, seed data, categories
    ├── models/receipt_model.dart        ← Receipt data class
    ├── widgets/
    │   ├── receipt_card.dart            ← reusable Card widget
    │   ├── bottom_nav.dart              ← bottom navigation bar
    │   ├── search_bar.dart              ← search input widget
    │   └── scan_modal.dart              ← add receipt bottom sheet
    └── screens/
        ├── home_screen.dart             ← home with 3 cards
        ├── folders_screen.dart          ← folder view
        ├── expenses_screen.dart         ← expense tracker
        ├── alerts_screen.dart           ← warranty alerts
        └── receipt_detail_screen.dart   ← receipt detail view
```

---

## How to Run

1. Make sure Flutter is installed: https://flutter.dev/docs/get-started/install
2. Open a terminal in this folder
3. Run:
   ```bash
   flutter pub get
   flutter run
   ```

---

## Features (Milestone 1)
- Loading/splash screen with progress bar
- Home screen with 3 Cards using local AssetImage
- Card customization: elevation, margin, color, rounded corners
- Search bar with category filter chips
- Bottom navigation with FAB scan button
- Add receipt modal (camera / gallery / manual)
- Folders screen (Personal / Work)
- Expense summary with breakdown bars
- Warranty alerts screen

---

## Team — Group 8
| Name | Role |
|---|---|
| Cassandra Arcilla | Project Manager/Lead Developer |
| Anne Alimurung | Frontend Developer |
| Ryna David | Backend Developer |
| Romer Macabali | Backend Developer |
| Sherene Tolentino | UI/UX Designer |
