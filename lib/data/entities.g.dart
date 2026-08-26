// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entities.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWorkoutRecordCollection on Isar {
  IsarCollection<WorkoutRecord> get workoutRecords => this.collection();
}

const WorkoutRecordSchema = CollectionSchema(
  name: r'WorkoutRecord',
  id: -7749833127528171173,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(id: 1, name: r'name', type: IsarType.string),
    r'repeats': PropertySchema(
      id: 2,
      name: r'repeats',
      type: IsarType.objectList,

      target: r'RepeatRecord',
    ),
    r'stages': PropertySchema(
      id: 3,
      name: r'stages',
      type: IsarType.objectList,

      target: r'StageRecord',
    ),
    r'templateKey': PropertySchema(
      id: 4,
      name: r'templateKey',
      type: IsarType.string,
    ),
    r'uid': PropertySchema(id: 5, name: r'uid', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _workoutRecordEstimateSize,
  serialize: _workoutRecordSerialize,
  deserialize: _workoutRecordDeserialize,
  deserializeProp: _workoutRecordDeserializeProp,
  idName: r'id',
  indexes: {
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
        ),
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
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {
    r'StageRecord': StageRecordSchema,
    r'RepeatRecord': RepeatRecordSchema,
  },

  getId: _workoutRecordGetId,
  getLinks: _workoutRecordGetLinks,
  attach: _workoutRecordAttach,
  version: '3.3.2',
);

int _workoutRecordEstimateSize(
  WorkoutRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.repeats.length * 3;
  {
    final offsets = allOffsets[RepeatRecord]!;
    for (var i = 0; i < object.repeats.length; i++) {
      final value = object.repeats[i];
      bytesCount += RepeatRecordSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.stages.length * 3;
  {
    final offsets = allOffsets[StageRecord]!;
    for (var i = 0; i < object.stages.length; i++) {
      final value = object.stages[i];
      bytesCount += StageRecordSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.templateKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _workoutRecordSerialize(
  WorkoutRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.name);
  writer.writeObjectList<RepeatRecord>(
    offsets[2],
    allOffsets,
    RepeatRecordSchema.serialize,
    object.repeats,
  );
  writer.writeObjectList<StageRecord>(
    offsets[3],
    allOffsets,
    StageRecordSchema.serialize,
    object.stages,
  );
  writer.writeString(offsets[4], object.templateKey);
  writer.writeString(offsets[5], object.uid);
  writer.writeDateTime(offsets[6], object.updatedAt);
}

WorkoutRecord _workoutRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorkoutRecord();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.name = reader.readString(offsets[1]);
  object.repeats =
      reader.readObjectList<RepeatRecord>(
        offsets[2],
        RepeatRecordSchema.deserialize,
        allOffsets,
        RepeatRecord(),
      ) ??
      [];
  object.stages =
      reader.readObjectList<StageRecord>(
        offsets[3],
        StageRecordSchema.deserialize,
        allOffsets,
        StageRecord(),
      ) ??
      [];
  object.templateKey = reader.readStringOrNull(offsets[4]);
  object.uid = reader.readString(offsets[5]);
  object.updatedAt = reader.readDateTime(offsets[6]);
  return object;
}

P _workoutRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readObjectList<RepeatRecord>(
                offset,
                RepeatRecordSchema.deserialize,
                allOffsets,
                RepeatRecord(),
              ) ??
              [])
          as P;
    case 3:
      return (reader.readObjectList<StageRecord>(
                offset,
                StageRecordSchema.deserialize,
                allOffsets,
                StageRecord(),
              ) ??
              [])
          as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _workoutRecordGetId(WorkoutRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _workoutRecordGetLinks(WorkoutRecord object) {
  return [];
}

void _workoutRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  WorkoutRecord object,
) {
  object.id = id;
}

extension WorkoutRecordByIndex on IsarCollection<WorkoutRecord> {
  Future<WorkoutRecord?> getByUid(String uid) {
    return getByIndex(r'uid', [uid]);
  }

  WorkoutRecord? getByUidSync(String uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<WorkoutRecord?>> getAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<WorkoutRecord?> getAllByUidSync(List<String> uidValues) {
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

  Future<Id> putByUid(WorkoutRecord object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(WorkoutRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<WorkoutRecord> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(
    List<WorkoutRecord> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension WorkoutRecordQueryWhereSort
    on QueryBuilder<WorkoutRecord, WorkoutRecord, QWhere> {
  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterWhere> anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }
}

extension WorkoutRecordQueryWhere
    on QueryBuilder<WorkoutRecord, WorkoutRecord, QWhereClause> {
  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterWhereClause> uidEqualTo(
    String uid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uid', value: [uid]),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterWhereClause> uidNotEqualTo(
    String uid,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [],
                upper: [uid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [uid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [uid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [],
                upper: [uid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterWhereClause>
  updatedAtEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'updatedAt', value: [updatedAt]),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterWhereClause>
  updatedAtNotEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterWhereClause>
  updatedAtGreaterThan(DateTime updatedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [updatedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterWhereClause>
  updatedAtLessThan(DateTime updatedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [],
          upper: [updatedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterWhereClause>
  updatedAtBetween(
    DateTime lowerUpdatedAt,
    DateTime upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [lowerUpdatedAt],
          includeLower: includeLower,
          upper: [upperUpdatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension WorkoutRecordQueryFilter
    on QueryBuilder<WorkoutRecord, WorkoutRecord, QFilterCondition> {
  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  repeatsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'repeats', length, true, length, true);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  repeatsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'repeats', 0, true, 0, true);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  repeatsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'repeats', 0, false, 999999, true);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  repeatsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'repeats', 0, true, length, include);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  repeatsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'repeats', length, include, 999999, true);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  repeatsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repeats',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  stagesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'stages', length, true, length, true);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  stagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'stages', 0, true, 0, true);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  stagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'stages', 0, false, 999999, true);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  stagesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'stages', 0, true, length, include);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  stagesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'stages', length, include, 999999, true);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  stagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stages',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  templateKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'templateKey'),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  templateKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'templateKey'),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  templateKeyEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'templateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  templateKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'templateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  templateKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'templateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  templateKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'templateKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  templateKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'templateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  templateKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'templateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  templateKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'templateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  templateKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'templateKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  templateKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'templateKey', value: ''),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  templateKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'templateKey', value: ''),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  uidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition> uidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition> uidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uid', value: ''),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uid', value: ''),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension WorkoutRecordQueryObject
    on QueryBuilder<WorkoutRecord, WorkoutRecord, QFilterCondition> {
  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  repeatsElement(FilterQuery<RepeatRecord> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'repeats');
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterFilterCondition>
  stagesElement(FilterQuery<StageRecord> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'stages');
    });
  }
}

extension WorkoutRecordQueryLinks
    on QueryBuilder<WorkoutRecord, WorkoutRecord, QFilterCondition> {}

extension WorkoutRecordQuerySortBy
    on QueryBuilder<WorkoutRecord, WorkoutRecord, QSortBy> {
  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy> sortByTemplateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateKey', Sort.asc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy>
  sortByTemplateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateKey', Sort.desc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension WorkoutRecordQuerySortThenBy
    on QueryBuilder<WorkoutRecord, WorkoutRecord, QSortThenBy> {
  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy> thenByTemplateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateKey', Sort.asc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy>
  thenByTemplateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateKey', Sort.desc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension WorkoutRecordQueryWhereDistinct
    on QueryBuilder<WorkoutRecord, WorkoutRecord, QDistinct> {
  QueryBuilder<WorkoutRecord, WorkoutRecord, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QDistinct> distinctByTemplateKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'templateKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QDistinct> distinctByUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutRecord, WorkoutRecord, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension WorkoutRecordQueryProperty
    on QueryBuilder<WorkoutRecord, WorkoutRecord, QQueryProperty> {
  QueryBuilder<WorkoutRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WorkoutRecord, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<WorkoutRecord, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<WorkoutRecord, List<RepeatRecord>, QQueryOperations>
  repeatsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repeats');
    });
  }

  QueryBuilder<WorkoutRecord, List<StageRecord>, QQueryOperations>
  stagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stages');
    });
  }

  QueryBuilder<WorkoutRecord, String?, QQueryOperations> templateKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'templateKey');
    });
  }

  QueryBuilder<WorkoutRecord, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<WorkoutRecord, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlanRecordCollection on Isar {
  IsarCollection<PlanRecord> get planRecords => this.collection();
}

const PlanRecordSchema = CollectionSchema(
  name: r'PlanRecord',
  id: -4315508632021592620,
  properties: {
    r'active': PropertySchema(id: 0, name: r'active', type: IsarType.bool),
    r'baseMinutes': PropertySchema(
      id: 1,
      name: r'baseMinutes',
      type: IsarType.long,
    ),
    r'effort': PropertySchema(
      id: 2,
      name: r'effort',
      type: IsarType.string,
      enumMap: _PlanRecordeffortEnumValueMap,
    ),
    r'progress': PropertySchema(
      id: 3,
      name: r'progress',
      type: IsarType.objectList,

      target: r'PlanProgressRecord',
    ),
    r'sessionsPerWeek': PropertySchema(
      id: 4,
      name: r'sessionsPerWeek',
      type: IsarType.long,
    ),
    r'startedAt': PropertySchema(
      id: 5,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'uid': PropertySchema(id: 6, name: r'uid', type: IsarType.string),
    r'weeks': PropertySchema(id: 7, name: r'weeks', type: IsarType.long),
  },

  estimateSize: _planRecordEstimateSize,
  serialize: _planRecordSerialize,
  deserialize: _planRecordDeserialize,
  deserializeProp: _planRecordDeserializeProp,
  idName: r'id',
  indexes: {
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
        ),
      ],
    ),
    r'active': IndexSchema(
      id: -7515327150349743717,
      name: r'active',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'active',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'PlanProgressRecord': PlanProgressRecordSchema},

  getId: _planRecordGetId,
  getLinks: _planRecordGetLinks,
  attach: _planRecordAttach,
  version: '3.3.2',
);

int _planRecordEstimateSize(
  PlanRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.effort.name.length * 3;
  bytesCount += 3 + object.progress.length * 3;
  {
    final offsets = allOffsets[PlanProgressRecord]!;
    for (var i = 0; i < object.progress.length; i++) {
      final value = object.progress[i];
      bytesCount += PlanProgressRecordSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _planRecordSerialize(
  PlanRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.active);
  writer.writeLong(offsets[1], object.baseMinutes);
  writer.writeString(offsets[2], object.effort.name);
  writer.writeObjectList<PlanProgressRecord>(
    offsets[3],
    allOffsets,
    PlanProgressRecordSchema.serialize,
    object.progress,
  );
  writer.writeLong(offsets[4], object.sessionsPerWeek);
  writer.writeDateTime(offsets[5], object.startedAt);
  writer.writeString(offsets[6], object.uid);
  writer.writeLong(offsets[7], object.weeks);
}

PlanRecord _planRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlanRecord();
  object.active = reader.readBool(offsets[0]);
  object.baseMinutes = reader.readLong(offsets[1]);
  object.effort =
      _PlanRecordeffortValueEnumMap[reader.readStringOrNull(offsets[2])] ??
      EffortValue.easy;
  object.id = id;
  object.progress =
      reader.readObjectList<PlanProgressRecord>(
        offsets[3],
        PlanProgressRecordSchema.deserialize,
        allOffsets,
        PlanProgressRecord(),
      ) ??
      [];
  object.sessionsPerWeek = reader.readLong(offsets[4]);
  object.startedAt = reader.readDateTime(offsets[5]);
  object.uid = reader.readString(offsets[6]);
  object.weeks = reader.readLong(offsets[7]);
  return object;
}

P _planRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (_PlanRecordeffortValueEnumMap[reader.readStringOrNull(offset)] ??
              EffortValue.easy)
          as P;
    case 3:
      return (reader.readObjectList<PlanProgressRecord>(
                offset,
                PlanProgressRecordSchema.deserialize,
                allOffsets,
                PlanProgressRecord(),
              ) ??
              [])
          as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PlanRecordeffortEnumValueMap = {
  r'easy': r'easy',
  r'moderate': r'moderate',
  r'hard': r'hard',
};
const _PlanRecordeffortValueEnumMap = {
  r'easy': EffortValue.easy,
  r'moderate': EffortValue.moderate,
  r'hard': EffortValue.hard,
};

Id _planRecordGetId(PlanRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _planRecordGetLinks(PlanRecord object) {
  return [];
}

void _planRecordAttach(IsarCollection<dynamic> col, Id id, PlanRecord object) {
  object.id = id;
}

extension PlanRecordByIndex on IsarCollection<PlanRecord> {
  Future<PlanRecord?> getByUid(String uid) {
    return getByIndex(r'uid', [uid]);
  }

  PlanRecord? getByUidSync(String uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<PlanRecord?>> getAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<PlanRecord?> getAllByUidSync(List<String> uidValues) {
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

  Future<Id> putByUid(PlanRecord object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(PlanRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<PlanRecord> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(List<PlanRecord> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension PlanRecordQueryWhereSort
    on QueryBuilder<PlanRecord, PlanRecord, QWhere> {
  QueryBuilder<PlanRecord, PlanRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterWhere> anyActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'active'),
      );
    });
  }
}

extension PlanRecordQueryWhere
    on QueryBuilder<PlanRecord, PlanRecord, QWhereClause> {
  QueryBuilder<PlanRecord, PlanRecord, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PlanRecord, PlanRecord, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterWhereClause> uidEqualTo(
    String uid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uid', value: [uid]),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterWhereClause> uidNotEqualTo(
    String uid,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [],
                upper: [uid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [uid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [uid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uid',
                lower: [],
                upper: [uid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterWhereClause> activeEqualTo(
    bool active,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'active', value: [active]),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterWhereClause> activeNotEqualTo(
    bool active,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'active',
                lower: [],
                upper: [active],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'active',
                lower: [active],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'active',
                lower: [active],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'active',
                lower: [],
                upper: [active],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension PlanRecordQueryFilter
    on QueryBuilder<PlanRecord, PlanRecord, QFilterCondition> {
  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> activeEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'active', value: value),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition>
  baseMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'baseMinutes', value: value),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition>
  baseMinutesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'baseMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition>
  baseMinutesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'baseMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition>
  baseMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'baseMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> effortEqualTo(
    EffortValue value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'effort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> effortGreaterThan(
    EffortValue value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'effort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> effortLessThan(
    EffortValue value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'effort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> effortBetween(
    EffortValue lower,
    EffortValue upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'effort',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> effortStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'effort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> effortEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'effort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> effortContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'effort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> effortMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'effort',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> effortIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'effort', value: ''),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition>
  effortIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'effort', value: ''),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition>
  progressLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'progress', length, true, length, true);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition>
  progressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'progress', 0, true, 0, true);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition>
  progressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'progress', 0, false, 999999, true);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition>
  progressLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'progress', 0, true, length, include);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition>
  progressLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'progress', length, include, 999999, true);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition>
  progressLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'progress',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition>
  sessionsPerWeekEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sessionsPerWeek', value: value),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition>
  sessionsPerWeekGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sessionsPerWeek',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition>
  sessionsPerWeekLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sessionsPerWeek',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition>
  sessionsPerWeekBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sessionsPerWeek',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> startedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startedAt', value: value),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition>
  startedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> startedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> uidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> uidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uid', value: ''),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uid', value: ''),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> weeksEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'weeks', value: value),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> weeksGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'weeks',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> weeksLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'weeks',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> weeksBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'weeks',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PlanRecordQueryObject
    on QueryBuilder<PlanRecord, PlanRecord, QFilterCondition> {
  QueryBuilder<PlanRecord, PlanRecord, QAfterFilterCondition> progressElement(
    FilterQuery<PlanProgressRecord> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'progress');
    });
  }
}

extension PlanRecordQueryLinks
    on QueryBuilder<PlanRecord, PlanRecord, QFilterCondition> {}

extension PlanRecordQuerySortBy
    on QueryBuilder<PlanRecord, PlanRecord, QSortBy> {
  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> sortByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.asc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> sortByActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.desc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> sortByBaseMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseMinutes', Sort.asc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> sortByBaseMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseMinutes', Sort.desc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> sortByEffort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effort', Sort.asc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> sortByEffortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effort', Sort.desc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> sortBySessionsPerWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionsPerWeek', Sort.asc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy>
  sortBySessionsPerWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionsPerWeek', Sort.desc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> sortByWeeks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeks', Sort.asc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> sortByWeeksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeks', Sort.desc);
    });
  }
}

extension PlanRecordQuerySortThenBy
    on QueryBuilder<PlanRecord, PlanRecord, QSortThenBy> {
  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> thenByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.asc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> thenByActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.desc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> thenByBaseMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseMinutes', Sort.asc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> thenByBaseMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseMinutes', Sort.desc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> thenByEffort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effort', Sort.asc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> thenByEffortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effort', Sort.desc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> thenBySessionsPerWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionsPerWeek', Sort.asc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy>
  thenBySessionsPerWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionsPerWeek', Sort.desc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> thenByWeeks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeks', Sort.asc);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QAfterSortBy> thenByWeeksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeks', Sort.desc);
    });
  }
}

extension PlanRecordQueryWhereDistinct
    on QueryBuilder<PlanRecord, PlanRecord, QDistinct> {
  QueryBuilder<PlanRecord, PlanRecord, QDistinct> distinctByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'active');
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QDistinct> distinctByBaseMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseMinutes');
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QDistinct> distinctByEffort({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'effort', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QDistinct> distinctBySessionsPerWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionsPerWeek');
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QDistinct> distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QDistinct> distinctByUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlanRecord, PlanRecord, QDistinct> distinctByWeeks() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weeks');
    });
  }
}

extension PlanRecordQueryProperty
    on QueryBuilder<PlanRecord, PlanRecord, QQueryProperty> {
  QueryBuilder<PlanRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlanRecord, bool, QQueryOperations> activeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'active');
    });
  }

  QueryBuilder<PlanRecord, int, QQueryOperations> baseMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseMinutes');
    });
  }

  QueryBuilder<PlanRecord, EffortValue, QQueryOperations> effortProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'effort');
    });
  }

  QueryBuilder<PlanRecord, List<PlanProgressRecord>, QQueryOperations>
  progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<PlanRecord, int, QQueryOperations> sessionsPerWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionsPerWeek');
    });
  }

  QueryBuilder<PlanRecord, DateTime, QQueryOperations> startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<PlanRecord, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<PlanRecord, int, QQueryOperations> weeksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weeks');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSessionRecordCollection on Isar {
  IsarCollection<SessionRecord> get sessionRecords => this.collection();
}

const SessionRecordSchema = CollectionSchema(
  name: r'SessionRecord',
  id: -4767949293416338608,
  properties: {
    r'actualSeconds': PropertySchema(
      id: 0,
      name: r'actualSeconds',
      type: IsarType.long,
    ),
    r'completedStages': PropertySchema(
      id: 1,
      name: r'completedStages',
      type: IsarType.long,
    ),
    r'effort': PropertySchema(id: 2, name: r'effort', type: IsarType.long),
    r'endedAt': PropertySchema(
      id: 3,
      name: r'endedAt',
      type: IsarType.dateTime,
    ),
    r'finishedRoute': PropertySchema(
      id: 4,
      name: r'finishedRoute',
      type: IsarType.bool,
    ),
    r'note': PropertySchema(id: 5, name: r'note', type: IsarType.string),
    r'plannedSeconds': PropertySchema(
      id: 6,
      name: r'plannedSeconds',
      type: IsarType.long,
    ),
    r'spans': PropertySchema(
      id: 7,
      name: r'spans',
      type: IsarType.objectList,

      target: r'TempoSpanRecord',
    ),
    r'startedAt': PropertySchema(
      id: 8,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'templateKey': PropertySchema(
      id: 9,
      name: r'templateKey',
      type: IsarType.string,
    ),
    r'totalStages': PropertySchema(
      id: 10,
      name: r'totalStages',
      type: IsarType.long,
    ),
    r'workoutName': PropertySchema(
      id: 11,
      name: r'workoutName',
      type: IsarType.string,
    ),
    r'workoutUid': PropertySchema(
      id: 12,
      name: r'workoutUid',
      type: IsarType.string,
    ),
  },

  estimateSize: _sessionRecordEstimateSize,
  serialize: _sessionRecordSerialize,
  deserialize: _sessionRecordDeserialize,
  deserializeProp: _sessionRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'startedAt': IndexSchema(
      id: 8114395319341636597,
      name: r'startedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'TempoSpanRecord': TempoSpanRecordSchema},

  getId: _sessionRecordGetId,
  getLinks: _sessionRecordGetLinks,
  attach: _sessionRecordAttach,
  version: '3.3.2',
);

int _sessionRecordEstimateSize(
  SessionRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.spans.length * 3;
  {
    final offsets = allOffsets[TempoSpanRecord]!;
    for (var i = 0; i < object.spans.length; i++) {
      final value = object.spans[i];
      bytesCount += TempoSpanRecordSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  {
    final value = object.templateKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.workoutName.length * 3;
  bytesCount += 3 + object.workoutUid.length * 3;
  return bytesCount;
}

void _sessionRecordSerialize(
  SessionRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.actualSeconds);
  writer.writeLong(offsets[1], object.completedStages);
  writer.writeLong(offsets[2], object.effort);
  writer.writeDateTime(offsets[3], object.endedAt);
  writer.writeBool(offsets[4], object.finishedRoute);
  writer.writeString(offsets[5], object.note);
  writer.writeLong(offsets[6], object.plannedSeconds);
  writer.writeObjectList<TempoSpanRecord>(
    offsets[7],
    allOffsets,
    TempoSpanRecordSchema.serialize,
    object.spans,
  );
  writer.writeDateTime(offsets[8], object.startedAt);
  writer.writeString(offsets[9], object.templateKey);
  writer.writeLong(offsets[10], object.totalStages);
  writer.writeString(offsets[11], object.workoutName);
  writer.writeString(offsets[12], object.workoutUid);
}

SessionRecord _sessionRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SessionRecord();
  object.actualSeconds = reader.readLong(offsets[0]);
  object.completedStages = reader.readLong(offsets[1]);
  object.effort = reader.readLong(offsets[2]);
  object.endedAt = reader.readDateTime(offsets[3]);
  object.finishedRoute = reader.readBool(offsets[4]);
  object.id = id;
  object.note = reader.readStringOrNull(offsets[5]);
  object.plannedSeconds = reader.readLong(offsets[6]);
  object.spans =
      reader.readObjectList<TempoSpanRecord>(
        offsets[7],
        TempoSpanRecordSchema.deserialize,
        allOffsets,
        TempoSpanRecord(),
      ) ??
      [];
  object.startedAt = reader.readDateTime(offsets[8]);
  object.templateKey = reader.readStringOrNull(offsets[9]);
  object.totalStages = reader.readLong(offsets[10]);
  object.workoutName = reader.readString(offsets[11]);
  object.workoutUid = reader.readString(offsets[12]);
  return object;
}

P _sessionRecordDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readObjectList<TempoSpanRecord>(
                offset,
                TempoSpanRecordSchema.deserialize,
                allOffsets,
                TempoSpanRecord(),
              ) ??
              [])
          as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sessionRecordGetId(SessionRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sessionRecordGetLinks(SessionRecord object) {
  return [];
}

void _sessionRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  SessionRecord object,
) {
  object.id = id;
}

extension SessionRecordQueryWhereSort
    on QueryBuilder<SessionRecord, SessionRecord, QWhere> {
  QueryBuilder<SessionRecord, SessionRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterWhere> anyStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startedAt'),
      );
    });
  }
}

extension SessionRecordQueryWhere
    on QueryBuilder<SessionRecord, SessionRecord, QWhereClause> {
  QueryBuilder<SessionRecord, SessionRecord, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<SessionRecord, SessionRecord, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterWhereClause>
  startedAtEqualTo(DateTime startedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'startedAt', value: [startedAt]),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterWhereClause>
  startedAtNotEqualTo(DateTime startedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startedAt',
                lower: [],
                upper: [startedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startedAt',
                lower: [startedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startedAt',
                lower: [startedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startedAt',
                lower: [],
                upper: [startedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterWhereClause>
  startedAtGreaterThan(DateTime startedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startedAt',
          lower: [startedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterWhereClause>
  startedAtLessThan(DateTime startedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startedAt',
          lower: [],
          upper: [startedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterWhereClause>
  startedAtBetween(
    DateTime lowerStartedAt,
    DateTime upperStartedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startedAt',
          lower: [lowerStartedAt],
          includeLower: includeLower,
          upper: [upperStartedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SessionRecordQueryFilter
    on QueryBuilder<SessionRecord, SessionRecord, QFilterCondition> {
  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  actualSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'actualSeconds', value: value),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  actualSecondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'actualSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  actualSecondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'actualSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  actualSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'actualSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  completedStagesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedStages', value: value),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  completedStagesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedStages',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  completedStagesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedStages',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  completedStagesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedStages',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  effortEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'effort', value: value),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  effortGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'effort',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  effortLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'effort',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  effortBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'effort',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  endedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endedAt', value: value),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  endedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'endedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  endedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'endedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  endedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  finishedRouteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'finishedRoute', value: value),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'note'),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'note'),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'note',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  noteStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  noteEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition> noteMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'note',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  plannedSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'plannedSeconds', value: value),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  plannedSecondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'plannedSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  plannedSecondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'plannedSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  plannedSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'plannedSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  spansLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'spans', length, true, length, true);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  spansIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'spans', 0, true, 0, true);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  spansIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'spans', 0, false, 999999, true);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  spansLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'spans', 0, true, length, include);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  spansLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'spans', length, include, 999999, true);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  spansLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'spans',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  startedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startedAt', value: value),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  startedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  startedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  templateKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'templateKey'),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  templateKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'templateKey'),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  templateKeyEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'templateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  templateKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'templateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  templateKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'templateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  templateKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'templateKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  templateKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'templateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  templateKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'templateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  templateKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'templateKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  templateKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'templateKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  templateKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'templateKey', value: ''),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  templateKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'templateKey', value: ''),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  totalStagesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalStages', value: value),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  totalStagesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalStages',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  totalStagesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalStages',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  totalStagesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalStages',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'workoutName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'workoutName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'workoutName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'workoutName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'workoutName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'workoutName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'workoutName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'workoutName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'workoutName', value: ''),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'workoutName', value: ''),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutUidEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'workoutUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutUidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'workoutUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutUidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'workoutUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutUidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'workoutUid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutUidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'workoutUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutUidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'workoutUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutUidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'workoutUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutUidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'workoutUid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'workoutUid', value: ''),
      );
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  workoutUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'workoutUid', value: ''),
      );
    });
  }
}

extension SessionRecordQueryObject
    on QueryBuilder<SessionRecord, SessionRecord, QFilterCondition> {
  QueryBuilder<SessionRecord, SessionRecord, QAfterFilterCondition>
  spansElement(FilterQuery<TempoSpanRecord> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'spans');
    });
  }
}

extension SessionRecordQueryLinks
    on QueryBuilder<SessionRecord, SessionRecord, QFilterCondition> {}

extension SessionRecordQuerySortBy
    on QueryBuilder<SessionRecord, SessionRecord, QSortBy> {
  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  sortByActualSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualSeconds', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  sortByActualSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualSeconds', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  sortByCompletedStages() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedStages', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  sortByCompletedStagesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedStages', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> sortByEffort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effort', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> sortByEffortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effort', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> sortByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> sortByEndedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  sortByFinishedRoute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedRoute', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  sortByFinishedRouteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedRoute', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  sortByPlannedSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedSeconds', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  sortByPlannedSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedSeconds', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> sortByTemplateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateKey', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  sortByTemplateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateKey', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> sortByTotalStages() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStages', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  sortByTotalStagesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStages', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> sortByWorkoutName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutName', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  sortByWorkoutNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutName', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> sortByWorkoutUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutUid', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  sortByWorkoutUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutUid', Sort.desc);
    });
  }
}

extension SessionRecordQuerySortThenBy
    on QueryBuilder<SessionRecord, SessionRecord, QSortThenBy> {
  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  thenByActualSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualSeconds', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  thenByActualSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualSeconds', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  thenByCompletedStages() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedStages', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  thenByCompletedStagesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedStages', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> thenByEffort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effort', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> thenByEffortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effort', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> thenByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> thenByEndedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  thenByFinishedRoute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedRoute', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  thenByFinishedRouteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedRoute', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  thenByPlannedSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedSeconds', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  thenByPlannedSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedSeconds', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> thenByTemplateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateKey', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  thenByTemplateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateKey', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> thenByTotalStages() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStages', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  thenByTotalStagesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStages', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> thenByWorkoutName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutName', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  thenByWorkoutNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutName', Sort.desc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy> thenByWorkoutUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutUid', Sort.asc);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QAfterSortBy>
  thenByWorkoutUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutUid', Sort.desc);
    });
  }
}

extension SessionRecordQueryWhereDistinct
    on QueryBuilder<SessionRecord, SessionRecord, QDistinct> {
  QueryBuilder<SessionRecord, SessionRecord, QDistinct>
  distinctByActualSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualSeconds');
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QDistinct>
  distinctByCompletedStages() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedStages');
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QDistinct> distinctByEffort() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'effort');
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QDistinct> distinctByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endedAt');
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QDistinct>
  distinctByFinishedRoute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'finishedRoute');
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QDistinct> distinctByNote({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QDistinct>
  distinctByPlannedSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plannedSeconds');
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QDistinct> distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QDistinct> distinctByTemplateKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'templateKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QDistinct>
  distinctByTotalStages() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalStages');
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QDistinct> distinctByWorkoutName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'workoutName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessionRecord, SessionRecord, QDistinct> distinctByWorkoutUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'workoutUid', caseSensitive: caseSensitive);
    });
  }
}

extension SessionRecordQueryProperty
    on QueryBuilder<SessionRecord, SessionRecord, QQueryProperty> {
  QueryBuilder<SessionRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SessionRecord, int, QQueryOperations> actualSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualSeconds');
    });
  }

  QueryBuilder<SessionRecord, int, QQueryOperations> completedStagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedStages');
    });
  }

  QueryBuilder<SessionRecord, int, QQueryOperations> effortProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'effort');
    });
  }

  QueryBuilder<SessionRecord, DateTime, QQueryOperations> endedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endedAt');
    });
  }

  QueryBuilder<SessionRecord, bool, QQueryOperations> finishedRouteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'finishedRoute');
    });
  }

  QueryBuilder<SessionRecord, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<SessionRecord, int, QQueryOperations> plannedSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plannedSeconds');
    });
  }

  QueryBuilder<SessionRecord, List<TempoSpanRecord>, QQueryOperations>
  spansProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spans');
    });
  }

  QueryBuilder<SessionRecord, DateTime, QQueryOperations> startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<SessionRecord, String?, QQueryOperations> templateKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'templateKey');
    });
  }

  QueryBuilder<SessionRecord, int, QQueryOperations> totalStagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalStages');
    });
  }

  QueryBuilder<SessionRecord, String, QQueryOperations> workoutNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workoutName');
    });
  }

  QueryBuilder<SessionRecord, String, QQueryOperations> workoutUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workoutUid');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const RepeatRecordSchema = Schema(
  name: r'RepeatRecord',
  id: -5427851459516154145,
  properties: {
    r'groupId': PropertySchema(id: 0, name: r'groupId', type: IsarType.string),
    r'times': PropertySchema(id: 1, name: r'times', type: IsarType.long),
  },

  estimateSize: _repeatRecordEstimateSize,
  serialize: _repeatRecordSerialize,
  deserialize: _repeatRecordDeserialize,
  deserializeProp: _repeatRecordDeserializeProp,
);

int _repeatRecordEstimateSize(
  RepeatRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.groupId.length * 3;
  return bytesCount;
}

void _repeatRecordSerialize(
  RepeatRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.groupId);
  writer.writeLong(offsets[1], object.times);
}

RepeatRecord _repeatRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RepeatRecord();
  object.groupId = reader.readString(offsets[0]);
  object.times = reader.readLong(offsets[1]);
  return object;
}

P _repeatRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension RepeatRecordQueryFilter
    on QueryBuilder<RepeatRecord, RepeatRecord, QFilterCondition> {
  QueryBuilder<RepeatRecord, RepeatRecord, QAfterFilterCondition>
  groupIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepeatRecord, RepeatRecord, QAfterFilterCondition>
  groupIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepeatRecord, RepeatRecord, QAfterFilterCondition>
  groupIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepeatRecord, RepeatRecord, QAfterFilterCondition>
  groupIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'groupId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepeatRecord, RepeatRecord, QAfterFilterCondition>
  groupIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepeatRecord, RepeatRecord, QAfterFilterCondition>
  groupIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepeatRecord, RepeatRecord, QAfterFilterCondition>
  groupIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepeatRecord, RepeatRecord, QAfterFilterCondition>
  groupIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'groupId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepeatRecord, RepeatRecord, QAfterFilterCondition>
  groupIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupId', value: ''),
      );
    });
  }

  QueryBuilder<RepeatRecord, RepeatRecord, QAfterFilterCondition>
  groupIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'groupId', value: ''),
      );
    });
  }

  QueryBuilder<RepeatRecord, RepeatRecord, QAfterFilterCondition> timesEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'times', value: value),
      );
    });
  }

  QueryBuilder<RepeatRecord, RepeatRecord, QAfterFilterCondition>
  timesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'times',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RepeatRecord, RepeatRecord, QAfterFilterCondition> timesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'times',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RepeatRecord, RepeatRecord, QAfterFilterCondition> timesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'times',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension RepeatRecordQueryObject
    on QueryBuilder<RepeatRecord, RepeatRecord, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const StageRecordSchema = Schema(
  name: r'StageRecord',
  id: -5569330711463374791,
  properties: {
    r'cadence': PropertySchema(id: 0, name: r'cadence', type: IsarType.long),
    r'durationSeconds': PropertySchema(
      id: 1,
      name: r'durationSeconds',
      type: IsarType.long,
    ),
    r'groupId': PropertySchema(id: 2, name: r'groupId', type: IsarType.string),
    r'marker': PropertySchema(
      id: 3,
      name: r'marker',
      type: IsarType.string,
      enumMap: _StageRecordmarkerEnumValueMap,
    ),
    r'note': PropertySchema(id: 4, name: r'note', type: IsarType.string),
    r'tempo': PropertySchema(
      id: 5,
      name: r'tempo',
      type: IsarType.string,
      enumMap: _StageRecordtempoEnumValueMap,
    ),
    r'uid': PropertySchema(id: 6, name: r'uid', type: IsarType.string),
  },

  estimateSize: _stageRecordEstimateSize,
  serialize: _stageRecordSerialize,
  deserialize: _stageRecordDeserialize,
  deserializeProp: _stageRecordDeserializeProp,
);

int _stageRecordEstimateSize(
  StageRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.groupId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.marker.name.length * 3;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.tempo.name.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _stageRecordSerialize(
  StageRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cadence);
  writer.writeLong(offsets[1], object.durationSeconds);
  writer.writeString(offsets[2], object.groupId);
  writer.writeString(offsets[3], object.marker.name);
  writer.writeString(offsets[4], object.note);
  writer.writeString(offsets[5], object.tempo.name);
  writer.writeString(offsets[6], object.uid);
}

StageRecord _stageRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StageRecord();
  object.cadence = reader.readLong(offsets[0]);
  object.durationSeconds = reader.readLong(offsets[1]);
  object.groupId = reader.readStringOrNull(offsets[2]);
  object.marker =
      _StageRecordmarkerValueEnumMap[reader.readStringOrNull(offsets[3])] ??
      MarkerValue.none;
  object.note = reader.readStringOrNull(offsets[4]);
  object.tempo =
      _StageRecordtempoValueEnumMap[reader.readStringOrNull(offsets[5])] ??
      TempoValue.walk;
  object.uid = reader.readString(offsets[6]);
  return object;
}

P _stageRecordDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (_StageRecordmarkerValueEnumMap[reader.readStringOrNull(offset)] ??
              MarkerValue.none)
          as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (_StageRecordtempoValueEnumMap[reader.readStringOrNull(offset)] ??
              TempoValue.walk)
          as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _StageRecordmarkerEnumValueMap = {
  r'none': r'none',
  r'checkpoint': r'checkpoint',
  r'tempoChange': r'tempoChange',
  r'recovery': r'recovery',
};
const _StageRecordmarkerValueEnumMap = {
  r'none': MarkerValue.none,
  r'checkpoint': MarkerValue.checkpoint,
  r'tempoChange': MarkerValue.tempoChange,
  r'recovery': MarkerValue.recovery,
};
const _StageRecordtempoEnumValueMap = {
  r'walk': r'walk',
  r'easyRun': r'easyRun',
  r'run': r'run',
  r'fastRun': r'fastRun',
  r'recovery': r'recovery',
  r'stop': r'stop',
};
const _StageRecordtempoValueEnumMap = {
  r'walk': TempoValue.walk,
  r'easyRun': TempoValue.easyRun,
  r'run': TempoValue.run,
  r'fastRun': TempoValue.fastRun,
  r'recovery': TempoValue.recovery,
  r'stop': TempoValue.stop,
};

extension StageRecordQueryFilter
    on QueryBuilder<StageRecord, StageRecord, QFilterCondition> {
  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> cadenceEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cadence', value: value),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  cadenceGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cadence',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> cadenceLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cadence',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> cadenceBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cadence',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  durationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'durationSeconds', value: value),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  durationSecondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'durationSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  durationSecondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'durationSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  durationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'durationSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  groupIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'groupId'),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  groupIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'groupId'),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> groupIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  groupIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> groupIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> groupIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'groupId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  groupIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> groupIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> groupIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> groupIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'groupId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  groupIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupId', value: ''),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  groupIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'groupId', value: ''),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> markerEqualTo(
    MarkerValue value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'marker',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  markerGreaterThan(
    MarkerValue value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'marker',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> markerLessThan(
    MarkerValue value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'marker',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> markerBetween(
    MarkerValue lower,
    MarkerValue upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'marker',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  markerStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'marker',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> markerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'marker',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> markerContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'marker',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> markerMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'marker',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  markerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'marker', value: ''),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  markerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'marker', value: ''),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'note'),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'note'),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'note',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> noteContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> noteMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'note',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> tempoEqualTo(
    TempoValue value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tempo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  tempoGreaterThan(
    TempoValue value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tempo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> tempoLessThan(
    TempoValue value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tempo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> tempoBetween(
    TempoValue lower,
    TempoValue upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tempo',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> tempoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tempo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> tempoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tempo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> tempoContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tempo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> tempoMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tempo',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> tempoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tempo', value: ''),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  tempoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tempo', value: ''),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> uidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> uidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uid', value: ''),
      );
    });
  }

  QueryBuilder<StageRecord, StageRecord, QAfterFilterCondition>
  uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uid', value: ''),
      );
    });
  }
}

extension StageRecordQueryObject
    on QueryBuilder<StageRecord, StageRecord, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const PlanProgressRecordSchema = Schema(
  name: r'PlanProgressRecord',
  id: 2514118320518875288,
  properties: {
    r'completedAt': PropertySchema(
      id: 0,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'sessionKey': PropertySchema(
      id: 1,
      name: r'sessionKey',
      type: IsarType.string,
    ),
  },

  estimateSize: _planProgressRecordEstimateSize,
  serialize: _planProgressRecordSerialize,
  deserialize: _planProgressRecordDeserialize,
  deserializeProp: _planProgressRecordDeserializeProp,
);

int _planProgressRecordEstimateSize(
  PlanProgressRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.sessionKey.length * 3;
  return bytesCount;
}

void _planProgressRecordSerialize(
  PlanProgressRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.completedAt);
  writer.writeString(offsets[1], object.sessionKey);
}

PlanProgressRecord _planProgressRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlanProgressRecord();
  object.completedAt = reader.readDateTime(offsets[0]);
  object.sessionKey = reader.readString(offsets[1]);
  return object;
}

P _planProgressRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension PlanProgressRecordQueryFilter
    on QueryBuilder<PlanProgressRecord, PlanProgressRecord, QFilterCondition> {
  QueryBuilder<PlanProgressRecord, PlanProgressRecord, QAfterFilterCondition>
  completedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedAt', value: value),
      );
    });
  }

  QueryBuilder<PlanProgressRecord, PlanProgressRecord, QAfterFilterCondition>
  completedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlanProgressRecord, PlanProgressRecord, QAfterFilterCondition>
  completedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlanProgressRecord, PlanProgressRecord, QAfterFilterCondition>
  completedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlanProgressRecord, PlanProgressRecord, QAfterFilterCondition>
  sessionKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sessionKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanProgressRecord, PlanProgressRecord, QAfterFilterCondition>
  sessionKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sessionKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanProgressRecord, PlanProgressRecord, QAfterFilterCondition>
  sessionKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sessionKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanProgressRecord, PlanProgressRecord, QAfterFilterCondition>
  sessionKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sessionKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanProgressRecord, PlanProgressRecord, QAfterFilterCondition>
  sessionKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sessionKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanProgressRecord, PlanProgressRecord, QAfterFilterCondition>
  sessionKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sessionKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanProgressRecord, PlanProgressRecord, QAfterFilterCondition>
  sessionKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sessionKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanProgressRecord, PlanProgressRecord, QAfterFilterCondition>
  sessionKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sessionKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlanProgressRecord, PlanProgressRecord, QAfterFilterCondition>
  sessionKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sessionKey', value: ''),
      );
    });
  }

  QueryBuilder<PlanProgressRecord, PlanProgressRecord, QAfterFilterCondition>
  sessionKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sessionKey', value: ''),
      );
    });
  }
}

extension PlanProgressRecordQueryObject
    on QueryBuilder<PlanProgressRecord, PlanProgressRecord, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const TempoSpanRecordSchema = Schema(
  name: r'TempoSpanRecord',
  id: 8823251402758871085,
  properties: {
    r'seconds': PropertySchema(id: 0, name: r'seconds', type: IsarType.long),
    r'tempo': PropertySchema(
      id: 1,
      name: r'tempo',
      type: IsarType.string,
      enumMap: _TempoSpanRecordtempoEnumValueMap,
    ),
  },

  estimateSize: _tempoSpanRecordEstimateSize,
  serialize: _tempoSpanRecordSerialize,
  deserialize: _tempoSpanRecordDeserialize,
  deserializeProp: _tempoSpanRecordDeserializeProp,
);

int _tempoSpanRecordEstimateSize(
  TempoSpanRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.tempo.name.length * 3;
  return bytesCount;
}

void _tempoSpanRecordSerialize(
  TempoSpanRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.seconds);
  writer.writeString(offsets[1], object.tempo.name);
}

TempoSpanRecord _tempoSpanRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TempoSpanRecord();
  object.seconds = reader.readLong(offsets[0]);
  object.tempo =
      _TempoSpanRecordtempoValueEnumMap[reader.readStringOrNull(offsets[1])] ??
      TempoValue.walk;
  return object;
}

P _tempoSpanRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (_TempoSpanRecordtempoValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              TempoValue.walk)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TempoSpanRecordtempoEnumValueMap = {
  r'walk': r'walk',
  r'easyRun': r'easyRun',
  r'run': r'run',
  r'fastRun': r'fastRun',
  r'recovery': r'recovery',
  r'stop': r'stop',
};
const _TempoSpanRecordtempoValueEnumMap = {
  r'walk': TempoValue.walk,
  r'easyRun': TempoValue.easyRun,
  r'run': TempoValue.run,
  r'fastRun': TempoValue.fastRun,
  r'recovery': TempoValue.recovery,
  r'stop': TempoValue.stop,
};

extension TempoSpanRecordQueryFilter
    on QueryBuilder<TempoSpanRecord, TempoSpanRecord, QFilterCondition> {
  QueryBuilder<TempoSpanRecord, TempoSpanRecord, QAfterFilterCondition>
  secondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'seconds', value: value),
      );
    });
  }

  QueryBuilder<TempoSpanRecord, TempoSpanRecord, QAfterFilterCondition>
  secondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'seconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TempoSpanRecord, TempoSpanRecord, QAfterFilterCondition>
  secondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'seconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TempoSpanRecord, TempoSpanRecord, QAfterFilterCondition>
  secondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'seconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TempoSpanRecord, TempoSpanRecord, QAfterFilterCondition>
  tempoEqualTo(TempoValue value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tempo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TempoSpanRecord, TempoSpanRecord, QAfterFilterCondition>
  tempoGreaterThan(
    TempoValue value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tempo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TempoSpanRecord, TempoSpanRecord, QAfterFilterCondition>
  tempoLessThan(
    TempoValue value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tempo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TempoSpanRecord, TempoSpanRecord, QAfterFilterCondition>
  tempoBetween(
    TempoValue lower,
    TempoValue upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tempo',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TempoSpanRecord, TempoSpanRecord, QAfterFilterCondition>
  tempoStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tempo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TempoSpanRecord, TempoSpanRecord, QAfterFilterCondition>
  tempoEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tempo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TempoSpanRecord, TempoSpanRecord, QAfterFilterCondition>
  tempoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tempo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TempoSpanRecord, TempoSpanRecord, QAfterFilterCondition>
  tempoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tempo',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TempoSpanRecord, TempoSpanRecord, QAfterFilterCondition>
  tempoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tempo', value: ''),
      );
    });
  }

  QueryBuilder<TempoSpanRecord, TempoSpanRecord, QAfterFilterCondition>
  tempoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tempo', value: ''),
      );
    });
  }
}

extension TempoSpanRecordQueryObject
    on QueryBuilder<TempoSpanRecord, TempoSpanRecord, QFilterCondition> {}
