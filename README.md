# NavigationApp

A simple SwiftUI + MapKit location navigation demo app for iOS. The app demonstrates local place data repository patterns, a Map view with annotations, and CoreLocation permission handling.

---

## Author

David Tertre

---

## 🧩 Project Structure

- `NavigationApp/`
  - `App/`
    - `NavigationApp.swift` — app entry point (`@main`).
    - `ContentView.swift` — root view.
  - `Models/`
    - `Place.swift` — place data model.
  - `Repositories/`
    - `PlacesRepository.swift` — repository protocol.
    - `LocalPlacesRepository.swift` — local data provider.
    - `PlacesRepositoryMock.swift` — mock data (previews/tests).
  - `ViewModels/`
    - `MapViewModel.swift` — map and data state + business logic.
  - `Views/`
    - `MapView.swift` — SwiftUI map with annotations and location logic.
  - `Services/`
    - `LocationManager.swift` — CoreLocation wrapper + permissions.
  - `Routing/`
    - `Router.swift` — navigation flow handling.
  - `Utilities/` — helper utilities.

---

## ⚙️ Requirements

- Xcode 15+ (recommended)
- iOS 17+ target
- Swift 5.9+

---

## ▶️ Run

1. Open `NavigationApp.xcodeproj` in Xcode.
2. Select target `NavigationApp` and a simulator or device.
3. Build (`Cmd+B`) and run (`Cmd+R`).
4. Allow location permission when prompted.

---

## 🧪 Testing and Previews

- Use `PlacesRepositoryMock` when writing SwiftUI previews or unit tests.
- Swap repository implementation in `MapViewModel` for real vs mock data.

---

## 🛠️ Enhancements

- Add `MKDirections` route drawing and turn-by-turn instructions.
- Add place search (geocoding / `MKLocalSearch`).
- Persist favorites/historic places to `UserDefaults` or CoreData.
- Add route/placemark details screen.

---

## 🧾 Info.plist Requirements

- `NSLocationWhenInUseUsageDescription` (required)
- Optionally `NSLocationAlwaysAndWhenInUseUsageDescription`

---

## 📌 Notes

This is a personal demo app for exploring SwiftUI + MapKit architecture. Adjust location usage, permission handling, and data persistence before production.

---

## 🙌 Contribution

1. Fork
2. Add features/fixes
3. Submit PR with testing steps
