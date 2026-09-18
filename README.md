# TestThrive - iOS Task Management App

A SwiftUI-based task management app built with Clean Architecture principles.

## 📱 Features

- ✅ **Responsive Design** - Supports iPhone Duo, iPad, Mac Mirroring, and all devices
- ✅ **Priority Tasks** - Display important tasks first
- ✅ **Timeline View** - Group tasks by date
- ✅ **Task Detail** - View task details and toggle completion status
- ✅ **Real API Integration** - Connected to JSONPlaceholder API
- ✅ **Clean Architecture** - Domain/Data/Presentation layer separation

## 🏗️ Architecture

```
TestThrive/
├── Domain/
│   ├── Entities/          # TaskItem, GroupedTasks
│   ├── RepositoryProtocols/
│   └── UseCases/          # FetchTasksUseCase
├── Data/
│   └── Repositories/      # APITaskRepository, MockTaskRepository
└── Presentation/
    ├── Models/            # TaskDashboardViewModel
    ├── Navigation/        # AppCoordinator, AppRoute
    ├── Utils/             # LayoutSizeInfo (Responsive Design)
    └── Views/             # SwiftUI Components
```

## 🎨 Layout Adaptation

### iOS 27 Responsive Design Principles

The app automatically adapts layout based on available space:

| Width | Layout | Feature |
|-------|--------|---------|
| < 540pt | Single Column | Vertical stack (narrow screens) |
| 540-800pt | Two Column | Side-by-side layout (medium) |
| > 800pt | Two Column Expanded | Side-by-side with extra space |

For details, see: `README_EN.md` or `IOS27_RESPONSIVE_COMPLIANCE_EN.md`

## 🚀 Getting Started

### Prerequisites
- Xcode 26.5+
- iOS 26.5+

### Installation

```bash
cd /Users/san2/Downloads/TestThrive
open TestThrive.xcodeproj
```

### Run

1. Select `TestThrive` scheme in Xcode
2. Select iPhone 17 simulator
3. Run (⌘R)


## 🛠️ Technologies

- **SwiftUI** - UI Framework
- **Combine** - Reactive Programming
- **URLSession** - Network
- **Clean Architecture** - Layered Design

## 📊 Project Structure

- `Domain` - Business logic (framework-independent)
- `Data` - Data access (Repository pattern)
- `Presentation` - UI and state management (ViewModel)

## ✅ Compliance

- ✅ iOS 27 Responsive Design principles
- ✅ Device-independent layout (space-based decisions)
- ✅ ViewThatFits negotiation
- ✅ containerRelativeFrame sizing
- ✅ Dynamic hinge detection

## 🎯 Next Steps

- [ ] Local data caching
- [ ] Offline mode
- [ ] User accounts
- [ ] Real-time synchronization

