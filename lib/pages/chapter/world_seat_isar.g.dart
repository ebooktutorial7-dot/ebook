// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'world_seat_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGlossaryEntityCollection on Isar {
  IsarCollection<GlossaryEntity> get glossaryEntitys => this.collection();
}

const GlossaryEntitySchema = CollectionSchema(
  name: r'GlossaryEntity',
  id: -3474738175478308914,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.long,
    ),
    r'desc': PropertySchema(
      id: 1,
      name: r'desc',
      type: IsarType.string,
    ),
    r'documentId': PropertySchema(
      id: 2,
      name: r'documentId',
      type: IsarType.string,
    ),
    r'pinned': PropertySchema(
      id: 3,
      name: r'pinned',
      type: IsarType.bool,
    ),
    r'pinnedAt': PropertySchema(
      id: 4,
      name: r'pinnedAt',
      type: IsarType.long,
    ),
    r'term': PropertySchema(
      id: 5,
      name: r'term',
      type: IsarType.string,
    ),
    r'uid': PropertySchema(
      id: 6,
      name: r'uid',
      type: IsarType.string,
    )
  },
  estimateSize: _glossaryEntityEstimateSize,
  serialize: _glossaryEntitySerialize,
  deserialize: _glossaryEntityDeserialize,
  deserializeProp: _glossaryEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'documentId': IndexSchema(
      id: 4187168439921340405,
      name: r'documentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'documentId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'uid': IndexSchema(
      id: 8193695471701937315,
      name: r'uid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _glossaryEntityGetId,
  getLinks: _glossaryEntityGetLinks,
  attach: _glossaryEntityAttach,
  version: '3.1.0+1',
);

int _glossaryEntityEstimateSize(
  GlossaryEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.desc.length * 3;
  bytesCount += 3 + object.documentId.length * 3;
  bytesCount += 3 + object.term.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _glossaryEntitySerialize(
  GlossaryEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.desc);
  writer.writeString(offsets[2], object.documentId);
  writer.writeBool(offsets[3], object.pinned);
  writer.writeLong(offsets[4], object.pinnedAt);
  writer.writeString(offsets[5], object.term);
  writer.writeString(offsets[6], object.uid);
}

GlossaryEntity _glossaryEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GlossaryEntity();
  object.createdAt = reader.readLong(offsets[0]);
  object.desc = reader.readString(offsets[1]);
  object.documentId = reader.readString(offsets[2]);
  object.id = id;
  object.pinned = reader.readBool(offsets[3]);
  object.pinnedAt = reader.readLongOrNull(offsets[4]);
  object.term = reader.readString(offsets[5]);
  object.uid = reader.readString(offsets[6]);
  return object;
}

P _glossaryEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _glossaryEntityGetId(GlossaryEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _glossaryEntityGetLinks(GlossaryEntity object) {
  return [];
}

void _glossaryEntityAttach(
    IsarCollection<dynamic> col, Id id, GlossaryEntity object) {
  object.id = id;
}

extension GlossaryEntityByIndex on IsarCollection<GlossaryEntity> {
  Future<GlossaryEntity?> getByUid(String uid) {
    return getByIndex(r'uid', [uid]);
  }

  GlossaryEntity? getByUidSync(String uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<GlossaryEntity?>> getAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<GlossaryEntity?> getAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uid', values);
  }

  Future<int> deleteAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uid', values);
  }

  int deleteAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uid', values);
  }

  Future<Id> putByUid(GlossaryEntity object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(GlossaryEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<GlossaryEntity> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(List<GlossaryEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension GlossaryEntityQueryWhereSort
    on QueryBuilder<GlossaryEntity, GlossaryEntity, QWhere> {
  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GlossaryEntityQueryWhere
    on QueryBuilder<GlossaryEntity, GlossaryEntity, QWhereClause> {
  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterWhereClause>
      documentIdEqualTo(String documentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'documentId',
        value: [documentId],
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterWhereClause>
      documentIdNotEqualTo(String documentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterWhereClause> uidEqualTo(
      String uid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uid',
        value: [uid],
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterWhereClause> uidNotEqualTo(
      String uid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension GlossaryEntityQueryFilter
    on QueryBuilder<GlossaryEntity, GlossaryEntity, QFilterCondition> {
  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      createdAtEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      createdAtGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      createdAtLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      createdAtBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      descEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      descGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      descLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      descBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'desc',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      descStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      descEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      descContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      descMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'desc',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      descIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'desc',
        value: '',
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      descIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'desc',
        value: '',
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      documentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      documentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      documentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      documentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      documentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      documentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      documentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      documentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      documentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      documentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      pinnedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pinned',
        value: value,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      pinnedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pinnedAt',
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      pinnedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pinnedAt',
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      pinnedAtEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pinnedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      pinnedAtGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pinnedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      pinnedAtLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pinnedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      pinnedAtBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pinnedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      termEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'term',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      termGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'term',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      termLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'term',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      termBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'term',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      termStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'term',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      termEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'term',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      termContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'term',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      termMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'term',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      termIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'term',
        value: '',
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      termIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'term',
        value: '',
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      uidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      uidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterFilterCondition>
      uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }
}

extension GlossaryEntityQueryObject
    on QueryBuilder<GlossaryEntity, GlossaryEntity, QFilterCondition> {}

extension GlossaryEntityQueryLinks
    on QueryBuilder<GlossaryEntity, GlossaryEntity, QFilterCondition> {}

extension GlossaryEntityQuerySortBy
    on QueryBuilder<GlossaryEntity, GlossaryEntity, QSortBy> {
  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> sortByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'desc', Sort.asc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> sortByDescDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'desc', Sort.desc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy>
      sortByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy>
      sortByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> sortByPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinned', Sort.asc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy>
      sortByPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinned', Sort.desc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> sortByPinnedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinnedAt', Sort.asc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy>
      sortByPinnedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinnedAt', Sort.desc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> sortByTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.asc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> sortByTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.desc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension GlossaryEntityQuerySortThenBy
    on QueryBuilder<GlossaryEntity, GlossaryEntity, QSortThenBy> {
  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> thenByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'desc', Sort.asc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> thenByDescDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'desc', Sort.desc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy>
      thenByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy>
      thenByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> thenByPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinned', Sort.asc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy>
      thenByPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinned', Sort.desc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> thenByPinnedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinnedAt', Sort.asc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy>
      thenByPinnedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinnedAt', Sort.desc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> thenByTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.asc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> thenByTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.desc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension GlossaryEntityQueryWhereDistinct
    on QueryBuilder<GlossaryEntity, GlossaryEntity, QDistinct> {
  QueryBuilder<GlossaryEntity, GlossaryEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QDistinct> distinctByDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'desc', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QDistinct> distinctByDocumentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QDistinct> distinctByPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pinned');
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QDistinct> distinctByPinnedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pinnedAt');
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QDistinct> distinctByTerm(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'term', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GlossaryEntity, GlossaryEntity, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }
}

extension GlossaryEntityQueryProperty
    on QueryBuilder<GlossaryEntity, GlossaryEntity, QQueryProperty> {
  QueryBuilder<GlossaryEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GlossaryEntity, int, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<GlossaryEntity, String, QQueryOperations> descProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'desc');
    });
  }

  QueryBuilder<GlossaryEntity, String, QQueryOperations> documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentId');
    });
  }

  QueryBuilder<GlossaryEntity, bool, QQueryOperations> pinnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pinned');
    });
  }

  QueryBuilder<GlossaryEntity, int?, QQueryOperations> pinnedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pinnedAt');
    });
  }

  QueryBuilder<GlossaryEntity, String, QQueryOperations> termProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'term');
    });
  }

  QueryBuilder<GlossaryEntity, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMemoEntityCollection on Isar {
  IsarCollection<MemoEntity> get memoEntitys => this.collection();
}

const MemoEntitySchema = CollectionSchema(
  name: r'MemoEntity',
  id: 309624378462236035,
  properties: {
    r'documentId': PropertySchema(
      id: 0,
      name: r'documentId',
      type: IsarType.string,
    ),
    r'text': PropertySchema(
      id: 1,
      name: r'text',
      type: IsarType.string,
    ),
    r'uid': PropertySchema(
      id: 2,
      name: r'uid',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 3,
      name: r'updatedAt',
      type: IsarType.long,
    )
  },
  estimateSize: _memoEntityEstimateSize,
  serialize: _memoEntitySerialize,
  deserialize: _memoEntityDeserialize,
  deserializeProp: _memoEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'documentId': IndexSchema(
      id: 4187168439921340405,
      name: r'documentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'documentId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'uid': IndexSchema(
      id: 8193695471701937315,
      name: r'uid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'updatedAt': IndexSchema(
      id: -6238191080293565125,
      name: r'updatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updatedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _memoEntityGetId,
  getLinks: _memoEntityGetLinks,
  attach: _memoEntityAttach,
  version: '3.1.0+1',
);

int _memoEntityEstimateSize(
  MemoEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.documentId.length * 3;
  bytesCount += 3 + object.text.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _memoEntitySerialize(
  MemoEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.documentId);
  writer.writeString(offsets[1], object.text);
  writer.writeString(offsets[2], object.uid);
  writer.writeLong(offsets[3], object.updatedAt);
}

MemoEntity _memoEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MemoEntity();
  object.documentId = reader.readString(offsets[0]);
  object.id = id;
  object.text = reader.readString(offsets[1]);
  object.uid = reader.readString(offsets[2]);
  object.updatedAt = reader.readLong(offsets[3]);
  return object;
}

P _memoEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _memoEntityGetId(MemoEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _memoEntityGetLinks(MemoEntity object) {
  return [];
}

void _memoEntityAttach(IsarCollection<dynamic> col, Id id, MemoEntity object) {
  object.id = id;
}

extension MemoEntityByIndex on IsarCollection<MemoEntity> {
  Future<MemoEntity?> getByUid(String uid) {
    return getByIndex(r'uid', [uid]);
  }

  MemoEntity? getByUidSync(String uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<MemoEntity?>> getAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<MemoEntity?> getAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uid', values);
  }

  Future<int> deleteAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uid', values);
  }

  int deleteAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uid', values);
  }

  Future<Id> putByUid(MemoEntity object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(MemoEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<MemoEntity> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(List<MemoEntity> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension MemoEntityQueryWhereSort
    on QueryBuilder<MemoEntity, MemoEntity, QWhere> {
  QueryBuilder<MemoEntity, MemoEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterWhere> anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }
}

extension MemoEntityQueryWhere
    on QueryBuilder<MemoEntity, MemoEntity, QWhereClause> {
  QueryBuilder<MemoEntity, MemoEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterWhereClause> documentIdEqualTo(
      String documentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'documentId',
        value: [documentId],
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterWhereClause> documentIdNotEqualTo(
      String documentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterWhereClause> uidEqualTo(
      String uid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uid',
        value: [uid],
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterWhereClause> uidNotEqualTo(
      String uid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterWhereClause> updatedAtEqualTo(
      int updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updatedAt',
        value: [updatedAt],
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterWhereClause> updatedAtNotEqualTo(
      int updatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterWhereClause> updatedAtGreaterThan(
    int updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [updatedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterWhereClause> updatedAtLessThan(
    int updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [],
        upper: [updatedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterWhereClause> updatedAtBetween(
    int lowerUpdatedAt,
    int upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [lowerUpdatedAt],
        includeLower: includeLower,
        upper: [upperUpdatedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MemoEntityQueryFilter
    on QueryBuilder<MemoEntity, MemoEntity, QFilterCondition> {
  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> documentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition>
      documentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition>
      documentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> documentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition>
      documentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition>
      documentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition>
      documentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> documentIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition>
      documentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition>
      documentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> textEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> textGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> textLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> textBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'text',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> textStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> textEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> textContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> textMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'text',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> uidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> uidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> updatedAtEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> updatedAtLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterFilterCondition> updatedAtBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MemoEntityQueryObject
    on QueryBuilder<MemoEntity, MemoEntity, QFilterCondition> {}

extension MemoEntityQueryLinks
    on QueryBuilder<MemoEntity, MemoEntity, QFilterCondition> {}

extension MemoEntityQuerySortBy
    on QueryBuilder<MemoEntity, MemoEntity, QSortBy> {
  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> sortByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> sortByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> sortByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> sortByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension MemoEntityQuerySortThenBy
    on QueryBuilder<MemoEntity, MemoEntity, QSortThenBy> {
  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> thenByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> thenByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> thenByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> thenByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension MemoEntityQueryWhereDistinct
    on QueryBuilder<MemoEntity, MemoEntity, QDistinct> {
  QueryBuilder<MemoEntity, MemoEntity, QDistinct> distinctByDocumentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QDistinct> distinctByText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'text', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MemoEntity, MemoEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension MemoEntityQueryProperty
    on QueryBuilder<MemoEntity, MemoEntity, QQueryProperty> {
  QueryBuilder<MemoEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MemoEntity, String, QQueryOperations> documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentId');
    });
  }

  QueryBuilder<MemoEntity, String, QQueryOperations> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'text');
    });
  }

  QueryBuilder<MemoEntity, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<MemoEntity, int, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCharacterEntityCollection on Isar {
  IsarCollection<CharacterEntity> get characterEntitys => this.collection();
}

const CharacterEntitySchema = CollectionSchema(
  name: r'CharacterEntity',
  id: -4181760854785418745,
  properties: {
    r'birthday': PropertySchema(
      id: 0,
      name: r'birthday',
      type: IsarType.string,
    ),
    r'bloodType': PropertySchema(
      id: 1,
      name: r'bloodType',
      type: IsarType.string,
    ),
    r'colorArgb': PropertySchema(
      id: 2,
      name: r'colorArgb',
      type: IsarType.long,
    ),
    r'coverPath': PropertySchema(
      id: 3,
      name: r'coverPath',
      type: IsarType.string,
    ),
    r'dislikes': PropertySchema(
      id: 4,
      name: r'dislikes',
      type: IsarType.stringList,
    ),
    r'documentId': PropertySchema(
      id: 5,
      name: r'documentId',
      type: IsarType.string,
    ),
    r'height': PropertySchema(
      id: 6,
      name: r'height',
      type: IsarType.string,
    ),
    r'images': PropertySchema(
      id: 7,
      name: r'images',
      type: IsarType.objectList,
      target: r'CharacterImageE',
    ),
    r'kind': PropertySchema(
      id: 8,
      name: r'kind',
      type: IsarType.string,
    ),
    r'likes': PropertySchema(
      id: 9,
      name: r'likes',
      type: IsarType.stringList,
    ),
    r'name': PropertySchema(
      id: 10,
      name: r'name',
      type: IsarType.string,
    ),
    r'palette': PropertySchema(
      id: 11,
      name: r'palette',
      type: IsarType.objectList,
      target: r'CharacterPaletteE',
    ),
    r'personalityKeywords': PropertySchema(
      id: 12,
      name: r'personalityKeywords',
      type: IsarType.stringList,
    ),
    r'physicalNotes': PropertySchema(
      id: 13,
      name: r'physicalNotes',
      type: IsarType.stringList,
    ),
    r'sheetAssetPath': PropertySchema(
      id: 14,
      name: r'sheetAssetPath',
      type: IsarType.string,
    ),
    r'specialNote': PropertySchema(
      id: 15,
      name: r'specialNote',
      type: IsarType.string,
    ),
    r'uid': PropertySchema(
      id: 16,
      name: r'uid',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 17,
      name: r'updatedAt',
      type: IsarType.long,
    )
  },
  estimateSize: _characterEntityEstimateSize,
  serialize: _characterEntitySerialize,
  deserialize: _characterEntityDeserialize,
  deserializeProp: _characterEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'documentId': IndexSchema(
      id: 4187168439921340405,
      name: r'documentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'documentId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'uid': IndexSchema(
      id: 8193695471701937315,
      name: r'uid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'kind': IndexSchema(
      id: 1484550194077596484,
      name: r'kind',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'kind',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'updatedAt': IndexSchema(
      id: -6238191080293565125,
      name: r'updatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updatedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {
    r'CharacterPaletteE': CharacterPaletteESchema,
    r'CharacterImageE': CharacterImageESchema
  },
  getId: _characterEntityGetId,
  getLinks: _characterEntityGetLinks,
  attach: _characterEntityAttach,
  version: '3.1.0+1',
);

int _characterEntityEstimateSize(
  CharacterEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.birthday.length * 3;
  bytesCount += 3 + object.bloodType.length * 3;
  {
    final value = object.coverPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.dislikes.length * 3;
  {
    for (var i = 0; i < object.dislikes.length; i++) {
      final value = object.dislikes[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.documentId.length * 3;
  bytesCount += 3 + object.height.length * 3;
  bytesCount += 3 + object.images.length * 3;
  {
    final offsets = allOffsets[CharacterImageE]!;
    for (var i = 0; i < object.images.length; i++) {
      final value = object.images[i];
      bytesCount +=
          CharacterImageESchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.kind.length * 3;
  bytesCount += 3 + object.likes.length * 3;
  {
    for (var i = 0; i < object.likes.length; i++) {
      final value = object.likes[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.palette.length * 3;
  {
    final offsets = allOffsets[CharacterPaletteE]!;
    for (var i = 0; i < object.palette.length; i++) {
      final value = object.palette[i];
      bytesCount +=
          CharacterPaletteESchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.personalityKeywords.length * 3;
  {
    for (var i = 0; i < object.personalityKeywords.length; i++) {
      final value = object.personalityKeywords[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.physicalNotes.length * 3;
  {
    for (var i = 0; i < object.physicalNotes.length; i++) {
      final value = object.physicalNotes[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.sheetAssetPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.specialNote.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _characterEntitySerialize(
  CharacterEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.birthday);
  writer.writeString(offsets[1], object.bloodType);
  writer.writeLong(offsets[2], object.colorArgb);
  writer.writeString(offsets[3], object.coverPath);
  writer.writeStringList(offsets[4], object.dislikes);
  writer.writeString(offsets[5], object.documentId);
  writer.writeString(offsets[6], object.height);
  writer.writeObjectList<CharacterImageE>(
    offsets[7],
    allOffsets,
    CharacterImageESchema.serialize,
    object.images,
  );
  writer.writeString(offsets[8], object.kind);
  writer.writeStringList(offsets[9], object.likes);
  writer.writeString(offsets[10], object.name);
  writer.writeObjectList<CharacterPaletteE>(
    offsets[11],
    allOffsets,
    CharacterPaletteESchema.serialize,
    object.palette,
  );
  writer.writeStringList(offsets[12], object.personalityKeywords);
  writer.writeStringList(offsets[13], object.physicalNotes);
  writer.writeString(offsets[14], object.sheetAssetPath);
  writer.writeString(offsets[15], object.specialNote);
  writer.writeString(offsets[16], object.uid);
  writer.writeLong(offsets[17], object.updatedAt);
}

CharacterEntity _characterEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CharacterEntity();
  object.birthday = reader.readString(offsets[0]);
  object.bloodType = reader.readString(offsets[1]);
  object.colorArgb = reader.readLongOrNull(offsets[2]);
  object.coverPath = reader.readStringOrNull(offsets[3]);
  object.dislikes = reader.readStringList(offsets[4]) ?? [];
  object.documentId = reader.readString(offsets[5]);
  object.height = reader.readString(offsets[6]);
  object.id = id;
  object.images = reader.readObjectList<CharacterImageE>(
        offsets[7],
        CharacterImageESchema.deserialize,
        allOffsets,
        CharacterImageE(),
      ) ??
      [];
  object.kind = reader.readString(offsets[8]);
  object.likes = reader.readStringList(offsets[9]) ?? [];
  object.name = reader.readString(offsets[10]);
  object.palette = reader.readObjectList<CharacterPaletteE>(
        offsets[11],
        CharacterPaletteESchema.deserialize,
        allOffsets,
        CharacterPaletteE(),
      ) ??
      [];
  object.personalityKeywords = reader.readStringList(offsets[12]) ?? [];
  object.physicalNotes = reader.readStringList(offsets[13]) ?? [];
  object.sheetAssetPath = reader.readStringOrNull(offsets[14]);
  object.specialNote = reader.readString(offsets[15]);
  object.uid = reader.readString(offsets[16]);
  object.updatedAt = reader.readLong(offsets[17]);
  return object;
}

P _characterEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readObjectList<CharacterImageE>(
            offset,
            CharacterImageESchema.deserialize,
            allOffsets,
            CharacterImageE(),
          ) ??
          []) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringList(offset) ?? []) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readObjectList<CharacterPaletteE>(
            offset,
            CharacterPaletteESchema.deserialize,
            allOffsets,
            CharacterPaletteE(),
          ) ??
          []) as P;
    case 12:
      return (reader.readStringList(offset) ?? []) as P;
    case 13:
      return (reader.readStringList(offset) ?? []) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _characterEntityGetId(CharacterEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _characterEntityGetLinks(CharacterEntity object) {
  return [];
}

void _characterEntityAttach(
    IsarCollection<dynamic> col, Id id, CharacterEntity object) {
  object.id = id;
}

extension CharacterEntityByIndex on IsarCollection<CharacterEntity> {
  Future<CharacterEntity?> getByUid(String uid) {
    return getByIndex(r'uid', [uid]);
  }

  CharacterEntity? getByUidSync(String uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<CharacterEntity?>> getAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<CharacterEntity?> getAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uid', values);
  }

  Future<int> deleteAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uid', values);
  }

  int deleteAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uid', values);
  }

  Future<Id> putByUid(CharacterEntity object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(CharacterEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<CharacterEntity> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(List<CharacterEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension CharacterEntityQueryWhereSort
    on QueryBuilder<CharacterEntity, CharacterEntity, QWhere> {
  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhere> anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }
}

extension CharacterEntityQueryWhere
    on QueryBuilder<CharacterEntity, CharacterEntity, QWhereClause> {
  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhereClause>
      documentIdEqualTo(String documentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'documentId',
        value: [documentId],
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhereClause>
      documentIdNotEqualTo(String documentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhereClause> uidEqualTo(
      String uid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uid',
        value: [uid],
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhereClause>
      uidNotEqualTo(String uid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhereClause> kindEqualTo(
      String kind) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'kind',
        value: [kind],
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhereClause>
      kindNotEqualTo(String kind) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'kind',
              lower: [],
              upper: [kind],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'kind',
              lower: [kind],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'kind',
              lower: [kind],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'kind',
              lower: [],
              upper: [kind],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhereClause>
      updatedAtEqualTo(int updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updatedAt',
        value: [updatedAt],
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhereClause>
      updatedAtNotEqualTo(int updatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhereClause>
      updatedAtGreaterThan(
    int updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [updatedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhereClause>
      updatedAtLessThan(
    int updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [],
        upper: [updatedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterWhereClause>
      updatedAtBetween(
    int lowerUpdatedAt,
    int upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [lowerUpdatedAt],
        includeLower: includeLower,
        upper: [upperUpdatedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CharacterEntityQueryFilter
    on QueryBuilder<CharacterEntity, CharacterEntity, QFilterCondition> {
  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      birthdayEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'birthday',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      birthdayGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'birthday',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      birthdayLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'birthday',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      birthdayBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'birthday',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      birthdayStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'birthday',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      birthdayEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'birthday',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      birthdayContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'birthday',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      birthdayMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'birthday',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      birthdayIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'birthday',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      birthdayIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'birthday',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      bloodTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      bloodTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      bloodTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      bloodTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bloodType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      bloodTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      bloodTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      bloodTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      bloodTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bloodType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      bloodTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bloodType',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      bloodTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bloodType',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      colorArgbIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'colorArgb',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      colorArgbIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'colorArgb',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      colorArgbEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorArgb',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      colorArgbGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorArgb',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      colorArgbLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorArgb',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      colorArgbBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorArgb',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      coverPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coverPath',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      coverPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coverPath',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      coverPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      coverPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coverPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      coverPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coverPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      coverPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coverPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      coverPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'coverPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      coverPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'coverPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      coverPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'coverPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      coverPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'coverPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      coverPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverPath',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      coverPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'coverPath',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      dislikesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dislikes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      dislikesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dislikes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      dislikesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dislikes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      dislikesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dislikes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      dislikesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dislikes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      dislikesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dislikes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      dislikesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dislikes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      dislikesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dislikes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      dislikesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dislikes',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      dislikesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dislikes',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      dislikesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dislikes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      dislikesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dislikes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      dislikesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dislikes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      dislikesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dislikes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      dislikesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dislikes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      dislikesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dislikes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      documentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      documentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      documentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      documentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      documentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      documentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      documentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      documentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      documentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      documentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      heightEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'height',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      heightGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'height',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      heightLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'height',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      heightBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'height',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      heightStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'height',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      heightEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'height',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      heightContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'height',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      heightMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'height',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      heightIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'height',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      heightIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'height',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      imagesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'images',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      imagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'images',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      imagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'images',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      imagesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'images',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      imagesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'images',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      imagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'images',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      kindEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      kindGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      kindLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      kindBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kind',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      kindStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      kindEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      kindContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      kindMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'kind',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      likesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'likes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      likesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'likes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      likesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'likes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      likesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'likes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      likesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'likes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      likesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'likes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      likesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'likes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      likesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'likes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      likesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'likes',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      likesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'likes',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      likesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'likes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      likesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'likes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      likesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'likes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      likesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'likes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      likesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'likes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      likesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'likes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      paletteLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'palette',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      paletteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'palette',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      paletteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'palette',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      paletteLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'palette',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      paletteLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'palette',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      paletteLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'palette',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      personalityKeywordsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personalityKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      personalityKeywordsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'personalityKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      personalityKeywordsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'personalityKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      personalityKeywordsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'personalityKeywords',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      personalityKeywordsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'personalityKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      personalityKeywordsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'personalityKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      personalityKeywordsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'personalityKeywords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      personalityKeywordsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'personalityKeywords',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      personalityKeywordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personalityKeywords',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      personalityKeywordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'personalityKeywords',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      personalityKeywordsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personalityKeywords',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      personalityKeywordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personalityKeywords',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      personalityKeywordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personalityKeywords',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      personalityKeywordsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personalityKeywords',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      personalityKeywordsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personalityKeywords',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      personalityKeywordsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personalityKeywords',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      physicalNotesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'physicalNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      physicalNotesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'physicalNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      physicalNotesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'physicalNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      physicalNotesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'physicalNotes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      physicalNotesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'physicalNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      physicalNotesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'physicalNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      physicalNotesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'physicalNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      physicalNotesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'physicalNotes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      physicalNotesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'physicalNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      physicalNotesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'physicalNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      physicalNotesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'physicalNotes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      physicalNotesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'physicalNotes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      physicalNotesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'physicalNotes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      physicalNotesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'physicalNotes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      physicalNotesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'physicalNotes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      physicalNotesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'physicalNotes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      sheetAssetPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sheetAssetPath',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      sheetAssetPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sheetAssetPath',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      sheetAssetPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sheetAssetPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      sheetAssetPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sheetAssetPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      sheetAssetPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sheetAssetPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      sheetAssetPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sheetAssetPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      sheetAssetPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sheetAssetPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      sheetAssetPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sheetAssetPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      sheetAssetPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sheetAssetPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      sheetAssetPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sheetAssetPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      sheetAssetPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sheetAssetPath',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      sheetAssetPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sheetAssetPath',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      specialNoteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'specialNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      specialNoteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'specialNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      specialNoteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'specialNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      specialNoteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'specialNote',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      specialNoteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'specialNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      specialNoteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'specialNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      specialNoteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'specialNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      specialNoteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'specialNote',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      specialNoteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'specialNote',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      specialNoteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'specialNote',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      uidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      uidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      updatedAtEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      updatedAtLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      updatedAtBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CharacterEntityQueryObject
    on QueryBuilder<CharacterEntity, CharacterEntity, QFilterCondition> {
  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      imagesElement(FilterQuery<CharacterImageE> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'images');
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterFilterCondition>
      paletteElement(FilterQuery<CharacterPaletteE> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'palette');
    });
  }
}

extension CharacterEntityQueryLinks
    on QueryBuilder<CharacterEntity, CharacterEntity, QFilterCondition> {}

extension CharacterEntityQuerySortBy
    on QueryBuilder<CharacterEntity, CharacterEntity, QSortBy> {
  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortByBirthday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthday', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortByBirthdayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthday', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortByBloodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodType', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortByBloodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodType', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortByColorArgb() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorArgb', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortByColorArgbDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorArgb', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortByCoverPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverPath', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortByCoverPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverPath', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy> sortByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortBySheetAssetPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sheetAssetPath', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortBySheetAssetPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sheetAssetPath', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortBySpecialNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'specialNote', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortBySpecialNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'specialNote', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CharacterEntityQuerySortThenBy
    on QueryBuilder<CharacterEntity, CharacterEntity, QSortThenBy> {
  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenByBirthday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthday', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenByBirthdayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthday', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenByBloodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodType', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenByBloodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodType', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenByColorArgb() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorArgb', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenByColorArgbDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorArgb', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenByCoverPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverPath', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenByCoverPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverPath', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy> thenByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenBySheetAssetPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sheetAssetPath', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenBySheetAssetPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sheetAssetPath', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenBySpecialNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'specialNote', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenBySpecialNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'specialNote', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CharacterEntityQueryWhereDistinct
    on QueryBuilder<CharacterEntity, CharacterEntity, QDistinct> {
  QueryBuilder<CharacterEntity, CharacterEntity, QDistinct> distinctByBirthday(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'birthday', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QDistinct> distinctByBloodType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bloodType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QDistinct>
      distinctByColorArgb() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorArgb');
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QDistinct> distinctByCoverPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QDistinct>
      distinctByDislikes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dislikes');
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QDistinct>
      distinctByDocumentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QDistinct> distinctByHeight(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'height', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QDistinct> distinctByKind(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QDistinct> distinctByLikes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'likes');
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QDistinct>
      distinctByPersonalityKeywords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'personalityKeywords');
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QDistinct>
      distinctByPhysicalNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'physicalNotes');
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QDistinct>
      distinctBySheetAssetPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sheetAssetPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QDistinct>
      distinctBySpecialNote({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'specialNote', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CharacterEntity, CharacterEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension CharacterEntityQueryProperty
    on QueryBuilder<CharacterEntity, CharacterEntity, QQueryProperty> {
  QueryBuilder<CharacterEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CharacterEntity, String, QQueryOperations> birthdayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'birthday');
    });
  }

  QueryBuilder<CharacterEntity, String, QQueryOperations> bloodTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bloodType');
    });
  }

  QueryBuilder<CharacterEntity, int?, QQueryOperations> colorArgbProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorArgb');
    });
  }

  QueryBuilder<CharacterEntity, String?, QQueryOperations> coverPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverPath');
    });
  }

  QueryBuilder<CharacterEntity, List<String>, QQueryOperations>
      dislikesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dislikes');
    });
  }

  QueryBuilder<CharacterEntity, String, QQueryOperations> documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentId');
    });
  }

  QueryBuilder<CharacterEntity, String, QQueryOperations> heightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'height');
    });
  }

  QueryBuilder<CharacterEntity, List<CharacterImageE>, QQueryOperations>
      imagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'images');
    });
  }

  QueryBuilder<CharacterEntity, String, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<CharacterEntity, List<String>, QQueryOperations>
      likesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'likes');
    });
  }

  QueryBuilder<CharacterEntity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<CharacterEntity, List<CharacterPaletteE>, QQueryOperations>
      paletteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'palette');
    });
  }

  QueryBuilder<CharacterEntity, List<String>, QQueryOperations>
      personalityKeywordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'personalityKeywords');
    });
  }

  QueryBuilder<CharacterEntity, List<String>, QQueryOperations>
      physicalNotesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'physicalNotes');
    });
  }

  QueryBuilder<CharacterEntity, String?, QQueryOperations>
      sheetAssetPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sheetAssetPath');
    });
  }

  QueryBuilder<CharacterEntity, String, QQueryOperations>
      specialNoteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'specialNote');
    });
  }

  QueryBuilder<CharacterEntity, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<CharacterEntity, int, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTimelineBarEntityCollection on Isar {
  IsarCollection<TimelineBarEntity> get timelineBarEntitys => this.collection();
}

const TimelineBarEntitySchema = CollectionSchema(
  name: r'TimelineBarEntity',
  id: -4108923317462391967,
  properties: {
    r'colorArgb': PropertySchema(
      id: 0,
      name: r'colorArgb',
      type: IsarType.long,
    ),
    r'documentId': PropertySchema(
      id: 1,
      name: r'documentId',
      type: IsarType.string,
    ),
    r'events': PropertySchema(
      id: 2,
      name: r'events',
      type: IsarType.objectList,
      target: r'TimelineEventE',
    ),
    r'label': PropertySchema(
      id: 3,
      name: r'label',
      type: IsarType.string,
    ),
    r'order': PropertySchema(
      id: 4,
      name: r'order',
      type: IsarType.long,
    ),
    r'uid': PropertySchema(
      id: 5,
      name: r'uid',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.long,
    )
  },
  estimateSize: _timelineBarEntityEstimateSize,
  serialize: _timelineBarEntitySerialize,
  deserialize: _timelineBarEntityDeserialize,
  deserializeProp: _timelineBarEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'documentId': IndexSchema(
      id: 4187168439921340405,
      name: r'documentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'documentId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'uid': IndexSchema(
      id: 8193695471701937315,
      name: r'uid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'order': IndexSchema(
      id: 5897270977454184057,
      name: r'order',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'order',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'updatedAt': IndexSchema(
      id: -6238191080293565125,
      name: r'updatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updatedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'TimelineEventE': TimelineEventESchema},
  getId: _timelineBarEntityGetId,
  getLinks: _timelineBarEntityGetLinks,
  attach: _timelineBarEntityAttach,
  version: '3.1.0+1',
);

int _timelineBarEntityEstimateSize(
  TimelineBarEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.documentId.length * 3;
  bytesCount += 3 + object.events.length * 3;
  {
    final offsets = allOffsets[TimelineEventE]!;
    for (var i = 0; i < object.events.length; i++) {
      final value = object.events[i];
      bytesCount +=
          TimelineEventESchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.label.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _timelineBarEntitySerialize(
  TimelineBarEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.colorArgb);
  writer.writeString(offsets[1], object.documentId);
  writer.writeObjectList<TimelineEventE>(
    offsets[2],
    allOffsets,
    TimelineEventESchema.serialize,
    object.events,
  );
  writer.writeString(offsets[3], object.label);
  writer.writeLong(offsets[4], object.order);
  writer.writeString(offsets[5], object.uid);
  writer.writeLong(offsets[6], object.updatedAt);
}

TimelineBarEntity _timelineBarEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TimelineBarEntity();
  object.colorArgb = reader.readLong(offsets[0]);
  object.documentId = reader.readString(offsets[1]);
  object.events = reader.readObjectList<TimelineEventE>(
        offsets[2],
        TimelineEventESchema.deserialize,
        allOffsets,
        TimelineEventE(),
      ) ??
      [];
  object.id = id;
  object.label = reader.readString(offsets[3]);
  object.order = reader.readLong(offsets[4]);
  object.uid = reader.readString(offsets[5]);
  object.updatedAt = reader.readLong(offsets[6]);
  return object;
}

P _timelineBarEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readObjectList<TimelineEventE>(
            offset,
            TimelineEventESchema.deserialize,
            allOffsets,
            TimelineEventE(),
          ) ??
          []) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _timelineBarEntityGetId(TimelineBarEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _timelineBarEntityGetLinks(
    TimelineBarEntity object) {
  return [];
}

void _timelineBarEntityAttach(
    IsarCollection<dynamic> col, Id id, TimelineBarEntity object) {
  object.id = id;
}

extension TimelineBarEntityByIndex on IsarCollection<TimelineBarEntity> {
  Future<TimelineBarEntity?> getByUid(String uid) {
    return getByIndex(r'uid', [uid]);
  }

  TimelineBarEntity? getByUidSync(String uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<TimelineBarEntity?>> getAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<TimelineBarEntity?> getAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uid', values);
  }

  Future<int> deleteAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uid', values);
  }

  int deleteAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uid', values);
  }

  Future<Id> putByUid(TimelineBarEntity object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(TimelineBarEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<TimelineBarEntity> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(List<TimelineBarEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension TimelineBarEntityQueryWhereSort
    on QueryBuilder<TimelineBarEntity, TimelineBarEntity, QWhere> {
  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhere> anyOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'order'),
      );
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhere>
      anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }
}

extension TimelineBarEntityQueryWhere
    on QueryBuilder<TimelineBarEntity, TimelineBarEntity, QWhereClause> {
  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      documentIdEqualTo(String documentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'documentId',
        value: [documentId],
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      documentIdNotEqualTo(String documentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      uidEqualTo(String uid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uid',
        value: [uid],
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      uidNotEqualTo(String uid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      orderEqualTo(int order) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'order',
        value: [order],
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      orderNotEqualTo(int order) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'order',
              lower: [],
              upper: [order],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'order',
              lower: [order],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'order',
              lower: [order],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'order',
              lower: [],
              upper: [order],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      orderGreaterThan(
    int order, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'order',
        lower: [order],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      orderLessThan(
    int order, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'order',
        lower: [],
        upper: [order],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      orderBetween(
    int lowerOrder,
    int upperOrder, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'order',
        lower: [lowerOrder],
        includeLower: includeLower,
        upper: [upperOrder],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      updatedAtEqualTo(int updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updatedAt',
        value: [updatedAt],
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      updatedAtNotEqualTo(int updatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      updatedAtGreaterThan(
    int updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [updatedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      updatedAtLessThan(
    int updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [],
        upper: [updatedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterWhereClause>
      updatedAtBetween(
    int lowerUpdatedAt,
    int upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [lowerUpdatedAt],
        includeLower: includeLower,
        upper: [upperUpdatedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TimelineBarEntityQueryFilter
    on QueryBuilder<TimelineBarEntity, TimelineBarEntity, QFilterCondition> {
  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      colorArgbEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorArgb',
        value: value,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      colorArgbGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorArgb',
        value: value,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      colorArgbLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorArgb',
        value: value,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      colorArgbBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorArgb',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      documentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      documentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      documentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      documentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      documentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      documentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      documentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      documentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      documentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      documentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      eventsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'events',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      eventsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'events',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      eventsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'events',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      eventsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'events',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      eventsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'events',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      eventsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'events',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      labelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'label',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'label',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      orderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      orderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      orderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'order',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      uidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      uidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      updatedAtEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      updatedAtLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      updatedAtBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TimelineBarEntityQueryObject
    on QueryBuilder<TimelineBarEntity, TimelineBarEntity, QFilterCondition> {
  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterFilterCondition>
      eventsElement(FilterQuery<TimelineEventE> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'events');
    });
  }
}

extension TimelineBarEntityQueryLinks
    on QueryBuilder<TimelineBarEntity, TimelineBarEntity, QFilterCondition> {}

extension TimelineBarEntityQuerySortBy
    on QueryBuilder<TimelineBarEntity, TimelineBarEntity, QSortBy> {
  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      sortByColorArgb() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorArgb', Sort.asc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      sortByColorArgbDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorArgb', Sort.desc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      sortByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      sortByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TimelineBarEntityQuerySortThenBy
    on QueryBuilder<TimelineBarEntity, TimelineBarEntity, QSortThenBy> {
  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      thenByColorArgb() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorArgb', Sort.asc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      thenByColorArgbDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorArgb', Sort.desc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      thenByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      thenByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TimelineBarEntityQueryWhereDistinct
    on QueryBuilder<TimelineBarEntity, TimelineBarEntity, QDistinct> {
  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QDistinct>
      distinctByColorArgb() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorArgb');
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QDistinct>
      distinctByDocumentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QDistinct> distinctByLabel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QDistinct>
      distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TimelineBarEntity, TimelineBarEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension TimelineBarEntityQueryProperty
    on QueryBuilder<TimelineBarEntity, TimelineBarEntity, QQueryProperty> {
  QueryBuilder<TimelineBarEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TimelineBarEntity, int, QQueryOperations> colorArgbProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorArgb');
    });
  }

  QueryBuilder<TimelineBarEntity, String, QQueryOperations>
      documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentId');
    });
  }

  QueryBuilder<TimelineBarEntity, List<TimelineEventE>, QQueryOperations>
      eventsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'events');
    });
  }

  QueryBuilder<TimelineBarEntity, String, QQueryOperations> labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<TimelineBarEntity, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<TimelineBarEntity, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<TimelineBarEntity, int, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFactionDocEntityCollection on Isar {
  IsarCollection<FactionDocEntity> get factionDocEntitys => this.collection();
}

const FactionDocEntitySchema = CollectionSchema(
  name: r'FactionDocEntity',
  id: 255712405054161106,
  properties: {
    r'canvasH': PropertySchema(
      id: 0,
      name: r'canvasH',
      type: IsarType.double,
    ),
    r'canvasW': PropertySchema(
      id: 1,
      name: r'canvasW',
      type: IsarType.double,
    ),
    r'diagrams': PropertySchema(
      id: 2,
      name: r'diagrams',
      type: IsarType.objectList,
      target: r'FactionDiagramE',
    ),
    r'documentId': PropertySchema(
      id: 3,
      name: r'documentId',
      type: IsarType.string,
    ),
    r'edges': PropertySchema(
      id: 4,
      name: r'edges',
      type: IsarType.objectList,
      target: r'FactionEdgeE',
    ),
    r'schemaVersion': PropertySchema(
      id: 5,
      name: r'schemaVersion',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.long,
    )
  },
  estimateSize: _factionDocEntityEstimateSize,
  serialize: _factionDocEntitySerialize,
  deserialize: _factionDocEntityDeserialize,
  deserializeProp: _factionDocEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'documentId': IndexSchema(
      id: 4187168439921340405,
      name: r'documentId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'documentId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {
    r'FactionDiagramE': FactionDiagramESchema,
    r'FactionEdgeE': FactionEdgeESchema,
    r'FactionEdgeStyleE': FactionEdgeStyleESchema,
    r'FactionEdgeLabelPlacementE': FactionEdgeLabelPlacementESchema
  },
  getId: _factionDocEntityGetId,
  getLinks: _factionDocEntityGetLinks,
  attach: _factionDocEntityAttach,
  version: '3.1.0+1',
);

int _factionDocEntityEstimateSize(
  FactionDocEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.diagrams.length * 3;
  {
    final offsets = allOffsets[FactionDiagramE]!;
    for (var i = 0; i < object.diagrams.length; i++) {
      final value = object.diagrams[i];
      bytesCount +=
          FactionDiagramESchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.documentId.length * 3;
  bytesCount += 3 + object.edges.length * 3;
  {
    final offsets = allOffsets[FactionEdgeE]!;
    for (var i = 0; i < object.edges.length; i++) {
      final value = object.edges[i];
      bytesCount += FactionEdgeESchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _factionDocEntitySerialize(
  FactionDocEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.canvasH);
  writer.writeDouble(offsets[1], object.canvasW);
  writer.writeObjectList<FactionDiagramE>(
    offsets[2],
    allOffsets,
    FactionDiagramESchema.serialize,
    object.diagrams,
  );
  writer.writeString(offsets[3], object.documentId);
  writer.writeObjectList<FactionEdgeE>(
    offsets[4],
    allOffsets,
    FactionEdgeESchema.serialize,
    object.edges,
  );
  writer.writeLong(offsets[5], object.schemaVersion);
  writer.writeLong(offsets[6], object.updatedAt);
}

FactionDocEntity _factionDocEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FactionDocEntity();
  object.canvasH = reader.readDouble(offsets[0]);
  object.canvasW = reader.readDouble(offsets[1]);
  object.diagrams = reader.readObjectList<FactionDiagramE>(
        offsets[2],
        FactionDiagramESchema.deserialize,
        allOffsets,
        FactionDiagramE(),
      ) ??
      [];
  object.documentId = reader.readString(offsets[3]);
  object.edges = reader.readObjectList<FactionEdgeE>(
        offsets[4],
        FactionEdgeESchema.deserialize,
        allOffsets,
        FactionEdgeE(),
      ) ??
      [];
  object.id = id;
  object.schemaVersion = reader.readLong(offsets[5]);
  object.updatedAt = reader.readLong(offsets[6]);
  return object;
}

P _factionDocEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readObjectList<FactionDiagramE>(
            offset,
            FactionDiagramESchema.deserialize,
            allOffsets,
            FactionDiagramE(),
          ) ??
          []) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readObjectList<FactionEdgeE>(
            offset,
            FactionEdgeESchema.deserialize,
            allOffsets,
            FactionEdgeE(),
          ) ??
          []) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _factionDocEntityGetId(FactionDocEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _factionDocEntityGetLinks(FactionDocEntity object) {
  return [];
}

void _factionDocEntityAttach(
    IsarCollection<dynamic> col, Id id, FactionDocEntity object) {
  object.id = id;
}

extension FactionDocEntityByIndex on IsarCollection<FactionDocEntity> {
  Future<FactionDocEntity?> getByDocumentId(String documentId) {
    return getByIndex(r'documentId', [documentId]);
  }

  FactionDocEntity? getByDocumentIdSync(String documentId) {
    return getByIndexSync(r'documentId', [documentId]);
  }

  Future<bool> deleteByDocumentId(String documentId) {
    return deleteByIndex(r'documentId', [documentId]);
  }

  bool deleteByDocumentIdSync(String documentId) {
    return deleteByIndexSync(r'documentId', [documentId]);
  }

  Future<List<FactionDocEntity?>> getAllByDocumentId(
      List<String> documentIdValues) {
    final values = documentIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'documentId', values);
  }

  List<FactionDocEntity?> getAllByDocumentIdSync(
      List<String> documentIdValues) {
    final values = documentIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'documentId', values);
  }

  Future<int> deleteAllByDocumentId(List<String> documentIdValues) {
    final values = documentIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'documentId', values);
  }

  int deleteAllByDocumentIdSync(List<String> documentIdValues) {
    final values = documentIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'documentId', values);
  }

  Future<Id> putByDocumentId(FactionDocEntity object) {
    return putByIndex(r'documentId', object);
  }

  Id putByDocumentIdSync(FactionDocEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'documentId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDocumentId(List<FactionDocEntity> objects) {
    return putAllByIndex(r'documentId', objects);
  }

  List<Id> putAllByDocumentIdSync(List<FactionDocEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'documentId', objects, saveLinks: saveLinks);
  }
}

extension FactionDocEntityQueryWhereSort
    on QueryBuilder<FactionDocEntity, FactionDocEntity, QWhere> {
  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FactionDocEntityQueryWhere
    on QueryBuilder<FactionDocEntity, FactionDocEntity, QWhereClause> {
  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterWhereClause>
      documentIdEqualTo(String documentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'documentId',
        value: [documentId],
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterWhereClause>
      documentIdNotEqualTo(String documentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension FactionDocEntityQueryFilter
    on QueryBuilder<FactionDocEntity, FactionDocEntity, QFilterCondition> {
  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      canvasHEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'canvasH',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      canvasHGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'canvasH',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      canvasHLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'canvasH',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      canvasHBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'canvasH',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      canvasWEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'canvasW',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      canvasWGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'canvasW',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      canvasWLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'canvasW',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      canvasWBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'canvasW',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      diagramsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'diagrams',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      diagramsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'diagrams',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      diagramsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'diagrams',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      diagramsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'diagrams',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      diagramsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'diagrams',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      diagramsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'diagrams',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      documentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      documentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      documentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      documentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      documentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      documentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      documentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      documentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      documentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      documentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      edgesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'edges',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      edgesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'edges',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      edgesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'edges',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      edgesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'edges',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      edgesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'edges',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      edgesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'edges',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      schemaVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      schemaVersionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      schemaVersionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      schemaVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schemaVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      updatedAtEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      updatedAtLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      updatedAtBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FactionDocEntityQueryObject
    on QueryBuilder<FactionDocEntity, FactionDocEntity, QFilterCondition> {
  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      diagramsElement(FilterQuery<FactionDiagramE> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'diagrams');
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterFilterCondition>
      edgesElement(FilterQuery<FactionEdgeE> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'edges');
    });
  }
}

extension FactionDocEntityQueryLinks
    on QueryBuilder<FactionDocEntity, FactionDocEntity, QFilterCondition> {}

extension FactionDocEntityQuerySortBy
    on QueryBuilder<FactionDocEntity, FactionDocEntity, QSortBy> {
  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      sortByCanvasH() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canvasH', Sort.asc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      sortByCanvasHDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canvasH', Sort.desc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      sortByCanvasW() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canvasW', Sort.asc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      sortByCanvasWDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canvasW', Sort.desc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      sortByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      sortByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      sortBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      sortBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension FactionDocEntityQuerySortThenBy
    on QueryBuilder<FactionDocEntity, FactionDocEntity, QSortThenBy> {
  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      thenByCanvasH() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canvasH', Sort.asc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      thenByCanvasHDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canvasH', Sort.desc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      thenByCanvasW() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canvasW', Sort.asc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      thenByCanvasWDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canvasW', Sort.desc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      thenByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      thenByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      thenBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      thenBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension FactionDocEntityQueryWhereDistinct
    on QueryBuilder<FactionDocEntity, FactionDocEntity, QDistinct> {
  QueryBuilder<FactionDocEntity, FactionDocEntity, QDistinct>
      distinctByCanvasH() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'canvasH');
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QDistinct>
      distinctByCanvasW() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'canvasW');
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QDistinct>
      distinctByDocumentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QDistinct>
      distinctBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaVersion');
    });
  }

  QueryBuilder<FactionDocEntity, FactionDocEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension FactionDocEntityQueryProperty
    on QueryBuilder<FactionDocEntity, FactionDocEntity, QQueryProperty> {
  QueryBuilder<FactionDocEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FactionDocEntity, double, QQueryOperations> canvasHProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'canvasH');
    });
  }

  QueryBuilder<FactionDocEntity, double, QQueryOperations> canvasWProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'canvasW');
    });
  }

  QueryBuilder<FactionDocEntity, List<FactionDiagramE>, QQueryOperations>
      diagramsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'diagrams');
    });
  }

  QueryBuilder<FactionDocEntity, String, QQueryOperations>
      documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentId');
    });
  }

  QueryBuilder<FactionDocEntity, List<FactionEdgeE>, QQueryOperations>
      edgesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'edges');
    });
  }

  QueryBuilder<FactionDocEntity, int, QQueryOperations>
      schemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaVersion');
    });
  }

  QueryBuilder<FactionDocEntity, int, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const CharacterPaletteESchema = Schema(
  name: r'CharacterPaletteE',
  id: 6338645076677425407,
  properties: {
    r'colorsArgb': PropertySchema(
      id: 0,
      name: r'colorsArgb',
      type: IsarType.longList,
    ),
    r'label': PropertySchema(
      id: 1,
      name: r'label',
      type: IsarType.string,
    )
  },
  estimateSize: _characterPaletteEEstimateSize,
  serialize: _characterPaletteESerialize,
  deserialize: _characterPaletteEDeserialize,
  deserializeProp: _characterPaletteEDeserializeProp,
);

int _characterPaletteEEstimateSize(
  CharacterPaletteE object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.colorsArgb.length * 8;
  bytesCount += 3 + object.label.length * 3;
  return bytesCount;
}

void _characterPaletteESerialize(
  CharacterPaletteE object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLongList(offsets[0], object.colorsArgb);
  writer.writeString(offsets[1], object.label);
}

CharacterPaletteE _characterPaletteEDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CharacterPaletteE();
  object.colorsArgb = reader.readLongList(offsets[0]) ?? [];
  object.label = reader.readString(offsets[1]);
  return object;
}

P _characterPaletteEDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongList(offset) ?? []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension CharacterPaletteEQueryFilter
    on QueryBuilder<CharacterPaletteE, CharacterPaletteE, QFilterCondition> {
  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      colorsArgbElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorsArgb',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      colorsArgbElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorsArgb',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      colorsArgbElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorsArgb',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      colorsArgbElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorsArgb',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      colorsArgbLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'colorsArgb',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      colorsArgbIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'colorsArgb',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      colorsArgbIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'colorsArgb',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      colorsArgbLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'colorsArgb',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      colorsArgbLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'colorsArgb',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      colorsArgbLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'colorsArgb',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      labelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'label',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'label',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterPaletteE, CharacterPaletteE, QAfterFilterCondition>
      labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'label',
        value: '',
      ));
    });
  }
}

extension CharacterPaletteEQueryObject
    on QueryBuilder<CharacterPaletteE, CharacterPaletteE, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const CharacterImageESchema = Schema(
  name: r'CharacterImageE',
  id: 3109589292811224141,
  properties: {
    r'assetPath': PropertySchema(
      id: 0,
      name: r'assetPath',
      type: IsarType.string,
    ),
    r'label': PropertySchema(
      id: 1,
      name: r'label',
      type: IsarType.string,
    )
  },
  estimateSize: _characterImageEEstimateSize,
  serialize: _characterImageESerialize,
  deserialize: _characterImageEDeserialize,
  deserializeProp: _characterImageEDeserializeProp,
);

int _characterImageEEstimateSize(
  CharacterImageE object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.assetPath.length * 3;
  bytesCount += 3 + object.label.length * 3;
  return bytesCount;
}

void _characterImageESerialize(
  CharacterImageE object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.assetPath);
  writer.writeString(offsets[1], object.label);
}

CharacterImageE _characterImageEDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CharacterImageE();
  object.assetPath = reader.readString(offsets[0]);
  object.label = reader.readString(offsets[1]);
  return object;
}

P _characterImageEDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension CharacterImageEQueryFilter
    on QueryBuilder<CharacterImageE, CharacterImageE, QFilterCondition> {
  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      assetPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      assetPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assetPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      assetPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assetPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      assetPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assetPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      assetPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assetPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      assetPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assetPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      assetPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assetPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      assetPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assetPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      assetPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetPath',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      assetPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assetPath',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      labelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'label',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'label',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterImageE, CharacterImageE, QAfterFilterCondition>
      labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'label',
        value: '',
      ));
    });
  }
}

extension CharacterImageEQueryObject
    on QueryBuilder<CharacterImageE, CharacterImageE, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const TimelineEventESchema = Schema(
  name: r'TimelineEventE',
  id: -7670169752417761313,
  properties: {
    r'desc': PropertySchema(
      id: 0,
      name: r'desc',
      type: IsarType.string,
    ),
    r'year': PropertySchema(
      id: 1,
      name: r'year',
      type: IsarType.string,
    )
  },
  estimateSize: _timelineEventEEstimateSize,
  serialize: _timelineEventESerialize,
  deserialize: _timelineEventEDeserialize,
  deserializeProp: _timelineEventEDeserializeProp,
);

int _timelineEventEEstimateSize(
  TimelineEventE object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.desc.length * 3;
  bytesCount += 3 + object.year.length * 3;
  return bytesCount;
}

void _timelineEventESerialize(
  TimelineEventE object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.desc);
  writer.writeString(offsets[1], object.year);
}

TimelineEventE _timelineEventEDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TimelineEventE();
  object.desc = reader.readString(offsets[0]);
  object.year = reader.readString(offsets[1]);
  return object;
}

P _timelineEventEDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension TimelineEventEQueryFilter
    on QueryBuilder<TimelineEventE, TimelineEventE, QFilterCondition> {
  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      descEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      descGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      descLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      descBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'desc',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      descStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      descEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      descContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'desc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      descMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'desc',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      descIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'desc',
        value: '',
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      descIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'desc',
        value: '',
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      yearEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'year',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      yearGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'year',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      yearLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'year',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      yearBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'year',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      yearStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'year',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      yearEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'year',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      yearContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'year',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      yearMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'year',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      yearIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'year',
        value: '',
      ));
    });
  }

  QueryBuilder<TimelineEventE, TimelineEventE, QAfterFilterCondition>
      yearIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'year',
        value: '',
      ));
    });
  }
}

extension TimelineEventEQueryObject
    on QueryBuilder<TimelineEventE, TimelineEventE, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const FactionDiagramESchema = Schema(
  name: r'FactionDiagramE',
  id: 2940071855874707266,
  properties: {
    r'fillColor': PropertySchema(
      id: 0,
      name: r'fillColor',
      type: IsarType.long,
    ),
    r'id': PropertySchema(
      id: 1,
      name: r'id',
      type: IsarType.string,
    ),
    r'imageUrl': PropertySchema(
      id: 2,
      name: r'imageUrl',
      type: IsarType.string,
    ),
    r'insideText': PropertySchema(
      id: 3,
      name: r'insideText',
      type: IsarType.string,
    ),
    r'insideTextColor': PropertySchema(
      id: 4,
      name: r'insideTextColor',
      type: IsarType.long,
    ),
    r'locked': PropertySchema(
      id: 5,
      name: r'locked',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 6,
      name: r'name',
      type: IsarType.string,
    ),
    r'r': PropertySchema(
      id: 7,
      name: r'r',
      type: IsarType.double,
    ),
    r'shapeIndex': PropertySchema(
      id: 8,
      name: r'shapeIndex',
      type: IsarType.long,
    ),
    r'showInsideText': PropertySchema(
      id: 9,
      name: r'showInsideText',
      type: IsarType.bool,
    ),
    r'x': PropertySchema(
      id: 10,
      name: r'x',
      type: IsarType.double,
    ),
    r'y': PropertySchema(
      id: 11,
      name: r'y',
      type: IsarType.double,
    )
  },
  estimateSize: _factionDiagramEEstimateSize,
  serialize: _factionDiagramESerialize,
  deserialize: _factionDiagramEDeserialize,
  deserializeProp: _factionDiagramEDeserializeProp,
);

int _factionDiagramEEstimateSize(
  FactionDiagramE object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.imageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.insideText.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _factionDiagramESerialize(
  FactionDiagramE object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.fillColor);
  writer.writeString(offsets[1], object.id);
  writer.writeString(offsets[2], object.imageUrl);
  writer.writeString(offsets[3], object.insideText);
  writer.writeLong(offsets[4], object.insideTextColor);
  writer.writeBool(offsets[5], object.locked);
  writer.writeString(offsets[6], object.name);
  writer.writeDouble(offsets[7], object.r);
  writer.writeLong(offsets[8], object.shapeIndex);
  writer.writeBool(offsets[9], object.showInsideText);
  writer.writeDouble(offsets[10], object.x);
  writer.writeDouble(offsets[11], object.y);
}

FactionDiagramE _factionDiagramEDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FactionDiagramE();
  object.fillColor = reader.readLongOrNull(offsets[0]);
  object.id = reader.readString(offsets[1]);
  object.imageUrl = reader.readStringOrNull(offsets[2]);
  object.insideText = reader.readString(offsets[3]);
  object.insideTextColor = reader.readLongOrNull(offsets[4]);
  object.locked = reader.readBool(offsets[5]);
  object.name = reader.readString(offsets[6]);
  object.r = reader.readDouble(offsets[7]);
  object.shapeIndex = reader.readLong(offsets[8]);
  object.showInsideText = reader.readBool(offsets[9]);
  object.x = reader.readDouble(offsets[10]);
  object.y = reader.readDouble(offsets[11]);
  return object;
}

P _factionDiagramEDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension FactionDiagramEQueryFilter
    on QueryBuilder<FactionDiagramE, FactionDiagramE, QFilterCondition> {
  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      fillColorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fillColor',
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      fillColorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fillColor',
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      fillColorEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fillColor',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      fillColorGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fillColor',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      fillColorLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fillColor',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      fillColorBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fillColor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      imageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      imageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      imageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      imageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      imageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      imageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      imageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      imageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      imageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      imageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      imageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      imageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      insideTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insideText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      insideTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'insideText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      insideTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'insideText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      insideTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'insideText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      insideTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'insideText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      insideTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'insideText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      insideTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'insideText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      insideTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'insideText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      insideTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insideText',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      insideTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'insideText',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      insideTextColorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'insideTextColor',
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      insideTextColorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'insideTextColor',
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      insideTextColorEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insideTextColor',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      insideTextColorGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'insideTextColor',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      insideTextColorLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'insideTextColor',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      insideTextColorBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'insideTextColor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      lockedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locked',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      rEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'r',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      rGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'r',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      rLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'r',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      rBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'r',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      shapeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shapeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      shapeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shapeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      shapeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shapeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      shapeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shapeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      showInsideTextEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showInsideText',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      xEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'x',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      xGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'x',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      xLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'x',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      xBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'x',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      yEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'y',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      yGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'y',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      yLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'y',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionDiagramE, FactionDiagramE, QAfterFilterCondition>
      yBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'y',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension FactionDiagramEQueryObject
    on QueryBuilder<FactionDiagramE, FactionDiagramE, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const FactionEdgeESchema = Schema(
  name: r'FactionEdgeE',
  id: -2230550740523266008,
  properties: {
    r'curvature': PropertySchema(
      id: 0,
      name: r'curvature',
      type: IsarType.double,
    ),
    r'from': PropertySchema(
      id: 1,
      name: r'from',
      type: IsarType.string,
    ),
    r'fromAnchor': PropertySchema(
      id: 2,
      name: r'fromAnchor',
      type: IsarType.long,
    ),
    r'fromFreeX': PropertySchema(
      id: 3,
      name: r'fromFreeX',
      type: IsarType.double,
    ),
    r'fromFreeY': PropertySchema(
      id: 4,
      name: r'fromFreeY',
      type: IsarType.double,
    ),
    r'id': PropertySchema(
      id: 5,
      name: r'id',
      type: IsarType.string,
    ),
    r'label': PropertySchema(
      id: 6,
      name: r'label',
      type: IsarType.string,
    ),
    r'labelPlacement': PropertySchema(
      id: 7,
      name: r'labelPlacement',
      type: IsarType.object,
      target: r'FactionEdgeLabelPlacementE',
    ),
    r'style': PropertySchema(
      id: 8,
      name: r'style',
      type: IsarType.object,
      target: r'FactionEdgeStyleE',
    ),
    r'to': PropertySchema(
      id: 9,
      name: r'to',
      type: IsarType.string,
    ),
    r'toAnchor': PropertySchema(
      id: 10,
      name: r'toAnchor',
      type: IsarType.long,
    ),
    r'toFreeX': PropertySchema(
      id: 11,
      name: r'toFreeX',
      type: IsarType.double,
    ),
    r'toFreeY': PropertySchema(
      id: 12,
      name: r'toFreeY',
      type: IsarType.double,
    )
  },
  estimateSize: _factionEdgeEEstimateSize,
  serialize: _factionEdgeESerialize,
  deserialize: _factionEdgeEDeserialize,
  deserializeProp: _factionEdgeEDeserializeProp,
);

int _factionEdgeEEstimateSize(
  FactionEdgeE object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.from.length * 3;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.label.length * 3;
  bytesCount += 3 +
      FactionEdgeLabelPlacementESchema.estimateSize(object.labelPlacement,
          allOffsets[FactionEdgeLabelPlacementE]!, allOffsets);
  bytesCount += 3 +
      FactionEdgeStyleESchema.estimateSize(
          object.style, allOffsets[FactionEdgeStyleE]!, allOffsets);
  bytesCount += 3 + object.to.length * 3;
  return bytesCount;
}

void _factionEdgeESerialize(
  FactionEdgeE object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.curvature);
  writer.writeString(offsets[1], object.from);
  writer.writeLong(offsets[2], object.fromAnchor);
  writer.writeDouble(offsets[3], object.fromFreeX);
  writer.writeDouble(offsets[4], object.fromFreeY);
  writer.writeString(offsets[5], object.id);
  writer.writeString(offsets[6], object.label);
  writer.writeObject<FactionEdgeLabelPlacementE>(
    offsets[7],
    allOffsets,
    FactionEdgeLabelPlacementESchema.serialize,
    object.labelPlacement,
  );
  writer.writeObject<FactionEdgeStyleE>(
    offsets[8],
    allOffsets,
    FactionEdgeStyleESchema.serialize,
    object.style,
  );
  writer.writeString(offsets[9], object.to);
  writer.writeLong(offsets[10], object.toAnchor);
  writer.writeDouble(offsets[11], object.toFreeX);
  writer.writeDouble(offsets[12], object.toFreeY);
}

FactionEdgeE _factionEdgeEDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FactionEdgeE();
  object.curvature = reader.readDouble(offsets[0]);
  object.from = reader.readString(offsets[1]);
  object.fromAnchor = reader.readLong(offsets[2]);
  object.fromFreeX = reader.readDoubleOrNull(offsets[3]);
  object.fromFreeY = reader.readDoubleOrNull(offsets[4]);
  object.id = reader.readString(offsets[5]);
  object.label = reader.readString(offsets[6]);
  object.labelPlacement = reader.readObjectOrNull<FactionEdgeLabelPlacementE>(
        offsets[7],
        FactionEdgeLabelPlacementESchema.deserialize,
        allOffsets,
      ) ??
      FactionEdgeLabelPlacementE();
  object.style = reader.readObjectOrNull<FactionEdgeStyleE>(
        offsets[8],
        FactionEdgeStyleESchema.deserialize,
        allOffsets,
      ) ??
      FactionEdgeStyleE();
  object.to = reader.readString(offsets[9]);
  object.toAnchor = reader.readLong(offsets[10]);
  object.toFreeX = reader.readDoubleOrNull(offsets[11]);
  object.toFreeY = reader.readDoubleOrNull(offsets[12]);
  return object;
}

P _factionEdgeEDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readObjectOrNull<FactionEdgeLabelPlacementE>(
            offset,
            FactionEdgeLabelPlacementESchema.deserialize,
            allOffsets,
          ) ??
          FactionEdgeLabelPlacementE()) as P;
    case 8:
      return (reader.readObjectOrNull<FactionEdgeStyleE>(
            offset,
            FactionEdgeStyleESchema.deserialize,
            allOffsets,
          ) ??
          FactionEdgeStyleE()) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readDoubleOrNull(offset)) as P;
    case 12:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension FactionEdgeEQueryFilter
    on QueryBuilder<FactionEdgeE, FactionEdgeE, QFilterCondition> {
  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      curvatureEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'curvature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      curvatureGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'curvature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      curvatureLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'curvature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      curvatureBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'curvature',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> fromEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> fromLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> fromBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'from',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> fromEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> fromContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> fromMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'from',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'from',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'from',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromAnchorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromAnchor',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromAnchorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fromAnchor',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromAnchorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fromAnchor',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromAnchorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fromAnchor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromFreeXIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fromFreeX',
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromFreeXIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fromFreeX',
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromFreeXEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromFreeX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromFreeXGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fromFreeX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromFreeXLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fromFreeX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromFreeXBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fromFreeX',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromFreeYIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fromFreeY',
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromFreeYIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fromFreeY',
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromFreeYEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromFreeY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromFreeYGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fromFreeY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromFreeYLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fromFreeY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      fromFreeYBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fromFreeY',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> idContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> labelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'label',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> labelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> labelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'label',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> toEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'to',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> toGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'to',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> toLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'to',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> toBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'to',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> toStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'to',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> toEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'to',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> toContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'to',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> toMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'to',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> toIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'to',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      toIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'to',
        value: '',
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      toAnchorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toAnchor',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      toAnchorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'toAnchor',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      toAnchorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'toAnchor',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      toAnchorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'toAnchor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      toFreeXIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'toFreeX',
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      toFreeXIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'toFreeX',
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      toFreeXEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toFreeX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      toFreeXGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'toFreeX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      toFreeXLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'toFreeX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      toFreeXBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'toFreeX',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      toFreeYIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'toFreeY',
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      toFreeYIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'toFreeY',
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      toFreeYEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toFreeY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      toFreeYGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'toFreeY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      toFreeYLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'toFreeY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      toFreeYBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'toFreeY',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension FactionEdgeEQueryObject
    on QueryBuilder<FactionEdgeE, FactionEdgeE, QFilterCondition> {
  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition>
      labelPlacement(FilterQuery<FactionEdgeLabelPlacementE> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'labelPlacement');
    });
  }

  QueryBuilder<FactionEdgeE, FactionEdgeE, QAfterFilterCondition> style(
      FilterQuery<FactionEdgeStyleE> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'style');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const FactionEdgeStyleESchema = Schema(
  name: r'FactionEdgeStyleE',
  id: -6651470834831235705,
  properties: {
    r'arrowModeIndex': PropertySchema(
      id: 0,
      name: r'arrowModeIndex',
      type: IsarType.long,
    ),
    r'color': PropertySchema(
      id: 1,
      name: r'color',
      type: IsarType.long,
    ),
    r'dashed': PropertySchema(
      id: 2,
      name: r'dashed',
      type: IsarType.bool,
    ),
    r'width': PropertySchema(
      id: 3,
      name: r'width',
      type: IsarType.double,
    )
  },
  estimateSize: _factionEdgeStyleEEstimateSize,
  serialize: _factionEdgeStyleESerialize,
  deserialize: _factionEdgeStyleEDeserialize,
  deserializeProp: _factionEdgeStyleEDeserializeProp,
);

int _factionEdgeStyleEEstimateSize(
  FactionEdgeStyleE object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _factionEdgeStyleESerialize(
  FactionEdgeStyleE object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.arrowModeIndex);
  writer.writeLong(offsets[1], object.color);
  writer.writeBool(offsets[2], object.dashed);
  writer.writeDouble(offsets[3], object.width);
}

FactionEdgeStyleE _factionEdgeStyleEDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FactionEdgeStyleE();
  object.arrowModeIndex = reader.readLong(offsets[0]);
  object.color = reader.readLong(offsets[1]);
  object.dashed = reader.readBool(offsets[2]);
  object.width = reader.readDouble(offsets[3]);
  return object;
}

P _factionEdgeStyleEDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension FactionEdgeStyleEQueryFilter
    on QueryBuilder<FactionEdgeStyleE, FactionEdgeStyleE, QFilterCondition> {
  QueryBuilder<FactionEdgeStyleE, FactionEdgeStyleE, QAfterFilterCondition>
      arrowModeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'arrowModeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionEdgeStyleE, FactionEdgeStyleE, QAfterFilterCondition>
      arrowModeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'arrowModeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionEdgeStyleE, FactionEdgeStyleE, QAfterFilterCondition>
      arrowModeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'arrowModeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionEdgeStyleE, FactionEdgeStyleE, QAfterFilterCondition>
      arrowModeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'arrowModeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FactionEdgeStyleE, FactionEdgeStyleE, QAfterFilterCondition>
      colorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'color',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionEdgeStyleE, FactionEdgeStyleE, QAfterFilterCondition>
      colorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'color',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionEdgeStyleE, FactionEdgeStyleE, QAfterFilterCondition>
      colorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'color',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionEdgeStyleE, FactionEdgeStyleE, QAfterFilterCondition>
      colorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'color',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FactionEdgeStyleE, FactionEdgeStyleE, QAfterFilterCondition>
      dashedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dashed',
        value: value,
      ));
    });
  }

  QueryBuilder<FactionEdgeStyleE, FactionEdgeStyleE, QAfterFilterCondition>
      widthEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'width',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeStyleE, FactionEdgeStyleE, QAfterFilterCondition>
      widthGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'width',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeStyleE, FactionEdgeStyleE, QAfterFilterCondition>
      widthLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'width',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeStyleE, FactionEdgeStyleE, QAfterFilterCondition>
      widthBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'width',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension FactionEdgeStyleEQueryObject
    on QueryBuilder<FactionEdgeStyleE, FactionEdgeStyleE, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const FactionEdgeLabelPlacementESchema = Schema(
  name: r'FactionEdgeLabelPlacementE',
  id: -5852623482571611902,
  properties: {
    r'dx': PropertySchema(
      id: 0,
      name: r'dx',
      type: IsarType.double,
    ),
    r'dy': PropertySchema(
      id: 1,
      name: r'dy',
      type: IsarType.double,
    ),
    r't': PropertySchema(
      id: 2,
      name: r't',
      type: IsarType.double,
    )
  },
  estimateSize: _factionEdgeLabelPlacementEEstimateSize,
  serialize: _factionEdgeLabelPlacementESerialize,
  deserialize: _factionEdgeLabelPlacementEDeserialize,
  deserializeProp: _factionEdgeLabelPlacementEDeserializeProp,
);

int _factionEdgeLabelPlacementEEstimateSize(
  FactionEdgeLabelPlacementE object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _factionEdgeLabelPlacementESerialize(
  FactionEdgeLabelPlacementE object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.dx);
  writer.writeDouble(offsets[1], object.dy);
  writer.writeDouble(offsets[2], object.t);
}

FactionEdgeLabelPlacementE _factionEdgeLabelPlacementEDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FactionEdgeLabelPlacementE();
  object.dx = reader.readDouble(offsets[0]);
  object.dy = reader.readDouble(offsets[1]);
  object.t = reader.readDouble(offsets[2]);
  return object;
}

P _factionEdgeLabelPlacementEDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension FactionEdgeLabelPlacementEQueryFilter on QueryBuilder<
    FactionEdgeLabelPlacementE, FactionEdgeLabelPlacementE, QFilterCondition> {
  QueryBuilder<FactionEdgeLabelPlacementE, FactionEdgeLabelPlacementE,
      QAfterFilterCondition> dxEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dx',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeLabelPlacementE, FactionEdgeLabelPlacementE,
      QAfterFilterCondition> dxGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dx',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeLabelPlacementE, FactionEdgeLabelPlacementE,
      QAfterFilterCondition> dxLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dx',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeLabelPlacementE, FactionEdgeLabelPlacementE,
      QAfterFilterCondition> dxBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dx',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeLabelPlacementE, FactionEdgeLabelPlacementE,
      QAfterFilterCondition> dyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeLabelPlacementE, FactionEdgeLabelPlacementE,
      QAfterFilterCondition> dyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeLabelPlacementE, FactionEdgeLabelPlacementE,
      QAfterFilterCondition> dyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeLabelPlacementE, FactionEdgeLabelPlacementE,
      QAfterFilterCondition> dyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeLabelPlacementE, FactionEdgeLabelPlacementE,
      QAfterFilterCondition> tEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r't',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeLabelPlacementE, FactionEdgeLabelPlacementE,
      QAfterFilterCondition> tGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r't',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeLabelPlacementE, FactionEdgeLabelPlacementE,
      QAfterFilterCondition> tLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r't',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FactionEdgeLabelPlacementE, FactionEdgeLabelPlacementE,
      QAfterFilterCondition> tBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r't',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension FactionEdgeLabelPlacementEQueryObject on QueryBuilder<
    FactionEdgeLabelPlacementE, FactionEdgeLabelPlacementE, QFilterCondition> {}
