// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBudgetCollection on Isar {
  IsarCollection<Budget> get budgets => this.collection();
}

const BudgetSchema = CollectionSchema(
  name: r'Budget',
  id: -3383598594604670326,
  properties: {
    r'budgetAmount': PropertySchema(
      id: 0,
      name: r'budgetAmount',
      type: IsarType.double,
    ),
    r'firedThresholds': PropertySchema(
      id: 1,
      name: r'firedThresholds',
      type: IsarType.longList,
    ),
    r'ledgerScope': PropertySchema(
      id: 2,
      name: r'ledgerScope',
      type: IsarType.byte,
      enumMap: _BudgetledgerScopeEnumValueMap,
    ),
    r'month': PropertySchema(
      id: 3,
      name: r'month',
      type: IsarType.long,
    ),
    r'notify100': PropertySchema(
      id: 4,
      name: r'notify100',
      type: IsarType.bool,
    ),
    r'notify50': PropertySchema(
      id: 5,
      name: r'notify50',
      type: IsarType.bool,
    ),
    r'notify75': PropertySchema(
      id: 6,
      name: r'notify75',
      type: IsarType.bool,
    ),
    r'notify90': PropertySchema(
      id: 7,
      name: r'notify90',
      type: IsarType.bool,
    ),
    r'year': PropertySchema(
      id: 8,
      name: r'year',
      type: IsarType.long,
    )
  },
  estimateSize: _budgetEstimateSize,
  serialize: _budgetSerialize,
  deserialize: _budgetDeserialize,
  deserializeProp: _budgetDeserializeProp,
  idName: r'id',
  indexes: {
    r'month_year_ledgerScope': IndexSchema(
      id: 2716741590372094852,
      name: r'month_year_ledgerScope',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'month',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'year',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'ledgerScope',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _budgetGetId,
  getLinks: _budgetGetLinks,
  attach: _budgetAttach,
  version: '3.1.0+1',
);

int _budgetEstimateSize(
  Budget object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.firedThresholds.length * 8;
  return bytesCount;
}

void _budgetSerialize(
  Budget object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.budgetAmount);
  writer.writeLongList(offsets[1], object.firedThresholds);
  writer.writeByte(offsets[2], object.ledgerScope.index);
  writer.writeLong(offsets[3], object.month);
  writer.writeBool(offsets[4], object.notify100);
  writer.writeBool(offsets[5], object.notify50);
  writer.writeBool(offsets[6], object.notify75);
  writer.writeBool(offsets[7], object.notify90);
  writer.writeLong(offsets[8], object.year);
}

Budget _budgetDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Budget(
    budgetAmount: reader.readDouble(offsets[0]),
    firedThresholds: reader.readLongList(offsets[1]) ?? const <int>[],
    ledgerScope:
        _BudgetledgerScopeValueEnumMap[reader.readByteOrNull(offsets[2])] ??
            LedgerScope.personal,
    month: reader.readLong(offsets[3]),
    notify100: reader.readBoolOrNull(offsets[4]) ?? true,
    notify50: reader.readBoolOrNull(offsets[5]) ?? true,
    notify75: reader.readBoolOrNull(offsets[6]) ?? true,
    notify90: reader.readBoolOrNull(offsets[7]) ?? true,
    year: reader.readLong(offsets[8]),
  );
  object.id = id;
  return object;
}

P _budgetDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readLongList(offset) ?? const <int>[]) as P;
    case 2:
      return (_BudgetledgerScopeValueEnumMap[reader.readByteOrNull(offset)] ??
          LedgerScope.personal) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 7:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BudgetledgerScopeEnumValueMap = {
  'personal': 0,
  'home': 1,
  'combined': 2,
};
const _BudgetledgerScopeValueEnumMap = {
  0: LedgerScope.personal,
  1: LedgerScope.home,
  2: LedgerScope.combined,
};

Id _budgetGetId(Budget object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _budgetGetLinks(Budget object) {
  return [];
}

void _budgetAttach(IsarCollection<dynamic> col, Id id, Budget object) {
  object.id = id;
}

extension BudgetByIndex on IsarCollection<Budget> {
  Future<Budget?> getByMonthYearLedgerScope(
      int month, int year, LedgerScope ledgerScope) {
    return getByIndex(r'month_year_ledgerScope', [month, year, ledgerScope]);
  }

  Budget? getByMonthYearLedgerScopeSync(
      int month, int year, LedgerScope ledgerScope) {
    return getByIndexSync(
        r'month_year_ledgerScope', [month, year, ledgerScope]);
  }

  Future<bool> deleteByMonthYearLedgerScope(
      int month, int year, LedgerScope ledgerScope) {
    return deleteByIndex(r'month_year_ledgerScope', [month, year, ledgerScope]);
  }

  bool deleteByMonthYearLedgerScopeSync(
      int month, int year, LedgerScope ledgerScope) {
    return deleteByIndexSync(
        r'month_year_ledgerScope', [month, year, ledgerScope]);
  }

  Future<List<Budget?>> getAllByMonthYearLedgerScope(List<int> monthValues,
      List<int> yearValues, List<LedgerScope> ledgerScopeValues) {
    final len = monthValues.length;
    assert(yearValues.length == len && ledgerScopeValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([monthValues[i], yearValues[i], ledgerScopeValues[i]]);
    }

    return getAllByIndex(r'month_year_ledgerScope', values);
  }

  List<Budget?> getAllByMonthYearLedgerScopeSync(List<int> monthValues,
      List<int> yearValues, List<LedgerScope> ledgerScopeValues) {
    final len = monthValues.length;
    assert(yearValues.length == len && ledgerScopeValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([monthValues[i], yearValues[i], ledgerScopeValues[i]]);
    }

    return getAllByIndexSync(r'month_year_ledgerScope', values);
  }

  Future<int> deleteAllByMonthYearLedgerScope(List<int> monthValues,
      List<int> yearValues, List<LedgerScope> ledgerScopeValues) {
    final len = monthValues.length;
    assert(yearValues.length == len && ledgerScopeValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([monthValues[i], yearValues[i], ledgerScopeValues[i]]);
    }

    return deleteAllByIndex(r'month_year_ledgerScope', values);
  }

  int deleteAllByMonthYearLedgerScopeSync(List<int> monthValues,
      List<int> yearValues, List<LedgerScope> ledgerScopeValues) {
    final len = monthValues.length;
    assert(yearValues.length == len && ledgerScopeValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([monthValues[i], yearValues[i], ledgerScopeValues[i]]);
    }

    return deleteAllByIndexSync(r'month_year_ledgerScope', values);
  }

  Future<Id> putByMonthYearLedgerScope(Budget object) {
    return putByIndex(r'month_year_ledgerScope', object);
  }

  Id putByMonthYearLedgerScopeSync(Budget object, {bool saveLinks = true}) {
    return putByIndexSync(r'month_year_ledgerScope', object,
        saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMonthYearLedgerScope(List<Budget> objects) {
    return putAllByIndex(r'month_year_ledgerScope', objects);
  }

  List<Id> putAllByMonthYearLedgerScopeSync(List<Budget> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'month_year_ledgerScope', objects,
        saveLinks: saveLinks);
  }
}

extension BudgetQueryWhereSort on QueryBuilder<Budget, Budget, QWhere> {
  QueryBuilder<Budget, Budget, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhere> anyMonthYearLedgerScope() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'month_year_ledgerScope'),
      );
    });
  }
}

extension BudgetQueryWhere on QueryBuilder<Budget, Budget, QWhereClause> {
  QueryBuilder<Budget, Budget, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Budget, Budget, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhereClause> idBetween(
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

  QueryBuilder<Budget, Budget, QAfterWhereClause>
      monthEqualToAnyYearLedgerScope(int month) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'month_year_ledgerScope',
        value: [month],
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhereClause>
      monthNotEqualToAnyYearLedgerScope(int month) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month_year_ledgerScope',
              lower: [],
              upper: [month],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month_year_ledgerScope',
              lower: [month],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month_year_ledgerScope',
              lower: [month],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month_year_ledgerScope',
              lower: [],
              upper: [month],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhereClause>
      monthGreaterThanAnyYearLedgerScope(
    int month, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'month_year_ledgerScope',
        lower: [month],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhereClause>
      monthLessThanAnyYearLedgerScope(
    int month, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'month_year_ledgerScope',
        lower: [],
        upper: [month],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhereClause>
      monthBetweenAnyYearLedgerScope(
    int lowerMonth,
    int upperMonth, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'month_year_ledgerScope',
        lower: [lowerMonth],
        includeLower: includeLower,
        upper: [upperMonth],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhereClause>
      monthYearEqualToAnyLedgerScope(int month, int year) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'month_year_ledgerScope',
        value: [month, year],
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhereClause>
      monthEqualToYearNotEqualToAnyLedgerScope(int month, int year) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month_year_ledgerScope',
              lower: [month],
              upper: [month, year],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month_year_ledgerScope',
              lower: [month, year],
              includeLower: false,
              upper: [month],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month_year_ledgerScope',
              lower: [month, year],
              includeLower: false,
              upper: [month],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month_year_ledgerScope',
              lower: [month],
              upper: [month, year],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhereClause>
      monthEqualToYearGreaterThanAnyLedgerScope(
    int month,
    int year, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'month_year_ledgerScope',
        lower: [month, year],
        includeLower: include,
        upper: [month],
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhereClause>
      monthEqualToYearLessThanAnyLedgerScope(
    int month,
    int year, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'month_year_ledgerScope',
        lower: [month],
        upper: [month, year],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhereClause>
      monthEqualToYearBetweenAnyLedgerScope(
    int month,
    int lowerYear,
    int upperYear, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'month_year_ledgerScope',
        lower: [month, lowerYear],
        includeLower: includeLower,
        upper: [month, upperYear],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhereClause> monthYearLedgerScopeEqualTo(
      int month, int year, LedgerScope ledgerScope) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'month_year_ledgerScope',
        value: [month, year, ledgerScope],
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhereClause>
      monthYearEqualToLedgerScopeNotEqualTo(
          int month, int year, LedgerScope ledgerScope) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month_year_ledgerScope',
              lower: [month, year],
              upper: [month, year, ledgerScope],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month_year_ledgerScope',
              lower: [month, year, ledgerScope],
              includeLower: false,
              upper: [month, year],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month_year_ledgerScope',
              lower: [month, year, ledgerScope],
              includeLower: false,
              upper: [month, year],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'month_year_ledgerScope',
              lower: [month, year],
              upper: [month, year, ledgerScope],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhereClause>
      monthYearEqualToLedgerScopeGreaterThan(
    int month,
    int year,
    LedgerScope ledgerScope, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'month_year_ledgerScope',
        lower: [month, year, ledgerScope],
        includeLower: include,
        upper: [month, year],
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhereClause>
      monthYearEqualToLedgerScopeLessThan(
    int month,
    int year,
    LedgerScope ledgerScope, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'month_year_ledgerScope',
        lower: [month, year],
        upper: [month, year, ledgerScope],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterWhereClause>
      monthYearEqualToLedgerScopeBetween(
    int month,
    int year,
    LedgerScope lowerLedgerScope,
    LedgerScope upperLedgerScope, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'month_year_ledgerScope',
        lower: [month, year, lowerLedgerScope],
        includeLower: includeLower,
        upper: [month, year, upperLedgerScope],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BudgetQueryFilter on QueryBuilder<Budget, Budget, QFilterCondition> {
  QueryBuilder<Budget, Budget, QAfterFilterCondition> budgetAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'budgetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> budgetAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'budgetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> budgetAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'budgetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> budgetAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'budgetAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition>
      firedThresholdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firedThresholds',
        value: value,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition>
      firedThresholdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'firedThresholds',
        value: value,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition>
      firedThresholdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'firedThresholds',
        value: value,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition>
      firedThresholdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'firedThresholds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition>
      firedThresholdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'firedThresholds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> firedThresholdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'firedThresholds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition>
      firedThresholdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'firedThresholds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition>
      firedThresholdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'firedThresholds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition>
      firedThresholdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'firedThresholds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition>
      firedThresholdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'firedThresholds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Budget, Budget, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Budget, Budget, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Budget, Budget, QAfterFilterCondition> ledgerScopeEqualTo(
      LedgerScope value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ledgerScope',
        value: value,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> ledgerScopeGreaterThan(
    LedgerScope value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ledgerScope',
        value: value,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> ledgerScopeLessThan(
    LedgerScope value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ledgerScope',
        value: value,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> ledgerScopeBetween(
    LedgerScope lower,
    LedgerScope upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ledgerScope',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> monthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'month',
        value: value,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> monthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'month',
        value: value,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> monthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'month',
        value: value,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> monthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'month',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> notify100EqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notify100',
        value: value,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> notify50EqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notify50',
        value: value,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> notify75EqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notify75',
        value: value,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> notify90EqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notify90',
        value: value,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> yearEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> yearGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> yearLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<Budget, Budget, QAfterFilterCondition> yearBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'year',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BudgetQueryObject on QueryBuilder<Budget, Budget, QFilterCondition> {}

extension BudgetQueryLinks on QueryBuilder<Budget, Budget, QFilterCondition> {}

extension BudgetQuerySortBy on QueryBuilder<Budget, Budget, QSortBy> {
  QueryBuilder<Budget, Budget, QAfterSortBy> sortByBudgetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetAmount', Sort.asc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> sortByBudgetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetAmount', Sort.desc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> sortByLedgerScope() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ledgerScope', Sort.asc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> sortByLedgerScopeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ledgerScope', Sort.desc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> sortByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.asc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> sortByMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.desc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> sortByNotify100() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notify100', Sort.asc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> sortByNotify100Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notify100', Sort.desc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> sortByNotify50() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notify50', Sort.asc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> sortByNotify50Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notify50', Sort.desc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> sortByNotify75() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notify75', Sort.asc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> sortByNotify75Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notify75', Sort.desc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> sortByNotify90() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notify90', Sort.asc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> sortByNotify90Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notify90', Sort.desc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> sortByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> sortByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension BudgetQuerySortThenBy on QueryBuilder<Budget, Budget, QSortThenBy> {
  QueryBuilder<Budget, Budget, QAfterSortBy> thenByBudgetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetAmount', Sort.asc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> thenByBudgetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetAmount', Sort.desc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> thenByLedgerScope() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ledgerScope', Sort.asc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> thenByLedgerScopeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ledgerScope', Sort.desc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> thenByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.asc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> thenByMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.desc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> thenByNotify100() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notify100', Sort.asc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> thenByNotify100Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notify100', Sort.desc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> thenByNotify50() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notify50', Sort.asc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> thenByNotify50Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notify50', Sort.desc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> thenByNotify75() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notify75', Sort.asc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> thenByNotify75Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notify75', Sort.desc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> thenByNotify90() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notify90', Sort.asc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> thenByNotify90Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notify90', Sort.desc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> thenByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<Budget, Budget, QAfterSortBy> thenByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension BudgetQueryWhereDistinct on QueryBuilder<Budget, Budget, QDistinct> {
  QueryBuilder<Budget, Budget, QDistinct> distinctByBudgetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'budgetAmount');
    });
  }

  QueryBuilder<Budget, Budget, QDistinct> distinctByFiredThresholds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firedThresholds');
    });
  }

  QueryBuilder<Budget, Budget, QDistinct> distinctByLedgerScope() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ledgerScope');
    });
  }

  QueryBuilder<Budget, Budget, QDistinct> distinctByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'month');
    });
  }

  QueryBuilder<Budget, Budget, QDistinct> distinctByNotify100() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notify100');
    });
  }

  QueryBuilder<Budget, Budget, QDistinct> distinctByNotify50() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notify50');
    });
  }

  QueryBuilder<Budget, Budget, QDistinct> distinctByNotify75() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notify75');
    });
  }

  QueryBuilder<Budget, Budget, QDistinct> distinctByNotify90() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notify90');
    });
  }

  QueryBuilder<Budget, Budget, QDistinct> distinctByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'year');
    });
  }
}

extension BudgetQueryProperty on QueryBuilder<Budget, Budget, QQueryProperty> {
  QueryBuilder<Budget, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Budget, double, QQueryOperations> budgetAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'budgetAmount');
    });
  }

  QueryBuilder<Budget, List<int>, QQueryOperations> firedThresholdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firedThresholds');
    });
  }

  QueryBuilder<Budget, LedgerScope, QQueryOperations> ledgerScopeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ledgerScope');
    });
  }

  QueryBuilder<Budget, int, QQueryOperations> monthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'month');
    });
  }

  QueryBuilder<Budget, bool, QQueryOperations> notify100Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notify100');
    });
  }

  QueryBuilder<Budget, bool, QQueryOperations> notify50Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notify50');
    });
  }

  QueryBuilder<Budget, bool, QQueryOperations> notify75Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notify75');
    });
  }

  QueryBuilder<Budget, bool, QQueryOperations> notify90Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notify90');
    });
  }

  QueryBuilder<Budget, int, QQueryOperations> yearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'year');
    });
  }
}
