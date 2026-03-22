# Memoir Path

A personal memory journal with a fully custom curved timeline UI. Each memory is a node on a visual journey path — with a photo, a title, a description, and a location tag.

## Features

- Add memories with title, description, photo, and date
- Location tagging via Geolocator
- Custom curved timeline drawn entirely with Canvas (`CustomPainter`)
- Photo attachment with image picker and local file storage
- BLoC architecture with clean separation of concerns
- Offline storage with SharedPreferences

## Highlight: Curved Timeline UI

The timeline is not a standard ListView. Each `JourneyTimelineNode` is positioned along a curved path drawn by `_CurvedTimelinePainter`, a custom `CustomPainter` that uses `quadraticBezierTo` to draw smooth curves between nodes. The cards alternate left and right along the path, connected by horizontal lines to each memory card.

```dart
class _CurvedTimelinePainter extends CustomPainter {
  void paint(Canvas canvas, Size size) {
    // Draws main curved path + horizontal connector lines to each card
    path.quadraticBezierTo(cpX1, centerY / 2, centerX, centerY);
    connectorPath.lineTo(curvesRight ? 0 : size.width, centerY);
  }
}
```

## Tech Stack

- **State Management:** BLoC (flutter_bloc 8.1.3) with Equatable
- **Storage:** SharedPreferences + path_provider for image files
- **Location:** geolocator ^14.0.2
- **Maps:** google_maps_flutter ^2.15.0
- **Image:** image_picker ^1.2.1
- **Other:** UUID, intl for date formatting

## Architecture

```
lib/
├── data/
│   ├── models/         — MemoryModel (serialization + fromEntity)
│   ├── repositories/   — MemoryRepositoryImpl
│   └── data_sources/   — MemoryLocalDataSourceImpl
├── domain/
│   ├── entities/       — Memory (id, title, description, imagePath, date)
│   └── repositories/   — MemoryRepository (abstract)
└── presentation/
    ├── bloc/           — MemoryBloc, MemoryEvent (LoadMemories, AddMemory), MemoryState
    └── pages/          — HomePage, AddMemoryPage
    └── widgets/        — JourneyTimelineNode, _CurvedTimelinePainter
```
