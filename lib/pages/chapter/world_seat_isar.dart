// world_seat_isar.dart

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

part 'world_seat_isar.g.dart';

/// =======================================================
/// Glossary
/// =======================================================

@collection
class GlossaryEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late String documentId;

  @Index(unique: true, replace: true)
  late String uid;

  late String term;
  late String desc;

  late bool pinned;
  late int createdAt;
  int? pinnedAt;
}

/// =======================================================
/// Memo
/// =======================================================

@collection
class MemoEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late String documentId;

  @Index(unique: true, replace: true)
  late String uid;

  late String text;

  @Index()
  late int updatedAt;
}

/// =======================================================
/// Character
/// =======================================================

@collection
class CharacterEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late String documentId;

  @Index(unique: true, replace: true)
  late String uid;

  @Index()
  late String kind;

  int? colorArgb;

  late String name;
  late String birthday;
  late String height;
  late String bloodType;
  late String specialNote;

  String? coverPath;
  String? sheetAssetPath;

  late List<String> personalityKeywords;
  late List<String> likes;
  late List<String> dislikes;
  late List<String> physicalNotes;

  late List<CharacterPaletteE> palette;
  late List<CharacterImageE> images;

  @Index()
  late int updatedAt;
}

@embedded
class CharacterPaletteE {
  late String label;
  late List<int> colorsArgb;
}

@embedded
class CharacterImageE {
  late String label;
  late String assetPath;
}

/// =======================================================
/// Timeline
/// =======================================================

@collection
class TimelineBarEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late String documentId;

  @Index(unique: true, replace: true)
  late String uid;

  late String label;
  late int colorArgb;

  @Index()
  late int order;

  late List<TimelineEventE> events;

  @Index()
  late int updatedAt;
}

@embedded
class TimelineEventE {
  late String year;
  late String desc;
}

/// =======================================================
/// Faction (Single Document Graph)
/// =======================================================

@collection
class FactionDocEntity {
  Id id = 0;

  late double canvasW;
  late double canvasH;

  late List<FactionDiagramE> diagrams;
  late List<FactionEdgeE> edges;
}

@embedded
class FactionDiagramE {
  late String id;
  late String name;

  late double x;
  late double y;
  late double r;

  late bool locked;

  String? imageUrl;

  late int shapeIndex;

  int? fillColor;

  late String insideText;
  late bool showInsideText;
  int? insideTextColor;
}

@embedded
class FactionEdgeE {
  late String id;
  late String from;
  late String to;

  late int fromAnchor;
  late int toAnchor;

  double? fromFreeX;
  double? fromFreeY;

  double? toFreeX;
  double? toFreeY;

  late String label;
  late double curvature;

  late FactionEdgeStyleE style;
  late FactionEdgeLabelPlacementE labelPlacement;
}

@embedded
class FactionEdgeStyleE {
  late int color;
  late double width;
  late bool dashed;
  late int arrowModeIndex;
}

@embedded
class FactionEdgeLabelPlacementE {
  late double t;
  late double dx;
  late double dy;
}

/// =======================================================
/// Isar Bootstrap
/// =======================================================

class WorldSeatIsar {
  WorldSeatIsar._();

  static Isar? _isar;

  static Future<Isar> get instance async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        GlossaryEntitySchema,
        MemoEntitySchema,
        CharacterEntitySchema,
        TimelineBarEntitySchema,
        FactionDocEntitySchema,
      ],
      directory: dir.path,
      name: 'world_seat',
    );

    return _isar!;
  }

  static Future<void> close() async {
    final isar = _isar;
    _isar = null;
    if (isar != null) {
      await isar.close();
    }
  }
}
