import 'package:flutter/material.dart';
import 'dart:collection';

class MapExamplePage {
  void test() {
    var gifts = Map<String, String>();
    gifts['first'] = 'partridge';
    gifts['second'] = 'turtledoves';
    gifts['fifth'] = 'golden rings';

    var nobleGases = Map<int, String>();
    nobleGases[2] = 'helium';
    nobleGases[10] = 'neon';
    nobleGases[18] = 'argon';

    print(gifts);
    print(nobleGases);
  }
}

class Customer {
  String name;
  int age;

  Customer(this.name, this.age);

  @override
  String toString() {
    return '{ ${this.name}, ${this.age} }';
  }
}

void main() {}

void createNewMap() {
  HashMap hashMap = new HashMap<int, String>();
  LinkedHashMap linkedHashMap = new LinkedHashMap<int, String>();
  SplayTreeMap treeMap = new SplayTreeMap<int, String>();
}

void initializeMapWithValue() {
  Map<String, int> map1 = {'zero': 0, 'one': 1, 'two': 2};
  print(map1);

  List<String> letters = ['I', 'V', 'X'];
  List<int> numbers = [1, 5, 10];

  Map<String, int> map = Map.fromIterables(letters, numbers);
  print(map); // {I: 1, V: 5, X: 10}

  List<int> numbers2 = [1, 2, 3];

  Map<String, int> map2 = { for (var e in numbers2) 'double ' + e.toString() : e * 2 };

  print(map2); // {double 1: 2, double 2: 4, double 3: 6}
}

void mapCollectionIfAndFor() {
  var mobile = true;
  var myMap = {1: 'kotlin', 2: 'dart', if (mobile) 3: 'flutter'};
  // {1: kotlin, 2: dart, 3: flutter}

  var squareMap = {
    for (var i = 1; i <= 5; i++) i: i * i
  };
  // {1: 1, 2: 4, 3: 9, 4: 16, 5: 25}

  var tringList = ['kotlin', 'dart', 'flutter', 'react'];
  var i = 0;
  var data = {for (var s in tringList) if (s.length > 5) i++: s};
  // {0: kotlin, 1: flutter}
}

void addItemToMap() {
  Map map = {1: 'one', 2: 'two'};

  map[3] = 'three';
  print(map);

  var threeValue = map.putIfAbsent(3, () => 'THREE');
  print(map);
  print(threeValue); // the value associated to key, if there is one

  map.putIfAbsent(4, () => 'four');
  print(map);
  /*
  {1: one, 2: two, 3: three}
  {1: one, 2: two, 3: three}
  three
  {1: one, 2: two, 3: three, 4: four}
   */

  Map map2 = {1: 'one', 2: 'two'};
  map2.addAll({3: 'three', 4: 'four', 5: 'five'});
  print(map2);
  /*
  {1: one, 2: two, 3: three, 4: four, 5: five}
   */
}

void updateValueMap() {
  Map map = {1: 'one', 2: 'two'};

  map[1] = 'ONE';
  print(map);

  map.update(2, (v) {
    print('old value before update: ' + v);
    return 'TWO';
  });
  print(map);

  map.update(3, (v) => 'THREE', ifAbsent: () => 'addedThree');
  print(map);
  /*
  {1: ONE, 2: two}
  old value before update: two
  {1: ONE, 2: TWO}
  {1: ONE, 2: TWO, 3: addedThree}
   */
}

void accessItemFromMap() {
  Map map = {1: 'one', 2: 'two'};

  print(map.length);      // 2

  print(map.isEmpty);     // false
  print(map.isNotEmpty);  // true

  print(map.keys);        // (1, 2)
  print(map.values);      // (one, two)

  print(map[2]);          // two
  print(map[3]);          // null
}

void checkExistenceKeyAndValue() {
  Map map = {1: 'one', 2: 'two'};

  print(map.containsKey(1));       // true
  print(map.containsKey(3));       // false

  print(map.containsValue('two')); // true
  print(map.containsKey('three')); // false
}

void removeObjectFromMap() {
  Map map = {1: 'one', 2: 'two', 3: 'three', 4: 'four', 5: 'five'};

  map.remove(2);
  print(map);

  map.removeWhere((k, v) => v.startsWith('f'));
  print(map);

  map.clear();
  print(map);
}

void combineMergeMultipleMaps() {
  Map map1 = {1: 'one', 2: 'two'};
  Map map2 = {3: 'three'};
  Map map3 = {4: 'four', 5: 'five'};

  // addAll() method
  var combinedMap1 = {}..addAll(map1)..addAll(map2)..addAll(map3);
  print(combinedMap1);

  // from() and addAll() method
  var combinedMap2 = Map.from(map1)..addAll(map2)..addAll(map3);
  print(combinedMap2);

  // spread operator
  var combinedMap3 = {...map1, ...map2, ...map3};
  print(combinedMap3);
  //{1: one, 2: two, 3: three, 4: four, 5: five}

  Map map4 = {1: 'one', 2: 'two'};
  Null map5 = null;
  Map map6 = {4: 'four', 5: 'five'};

  var combinedMap = {...map1, ...?map2, ...map3};
  print(combinedMap);
  // {1: one, 2: two, 4: four, 5: five}
}

void iterateOverMap() {
  Map map = {1: 'one', 2: 'two', 3: 'three'};

  map.forEach((k, v) {
    print('{ key: $k, value: $v }');
  });

  map.entries.forEach((e) {
    print('{ key: ${e.key}, value: ${e.value} }');
  });
  /*
  { key: 1, value: one }
  { key: 2, value: two }
  { key: 3, value: three }
   */

  map.keys.forEach((k) => print(k));
  map.values.forEach((v) => print(v));
}

void getKeyByValue() {
  Map map = {1: 'one', 2: 'two', 3: 'three'};

  var key = map.keys.firstWhere((k) => map[k] == 'two', orElse: () => null);
  print(key);
// 2
}

void sortMap() {
  Map map = {1: 'one', 2: 'two', 3: 'three', 4: 'four', 5: 'five'};

  var sortedMap = Map.fromEntries(
      map.entries.toList()
        ..sort((e1, e2) => e1.value.compareTo(e2.value)));

  print(sortedMap);
  // {5: five, 4: four, 1: one, 3: three, 2: two}
}

void transformMap() {
  Map map = {1: 'one', 2: 'two', 3: 'three'};

  var transformedMap = map.map((k, v) {
    return MapEntry('($k)', v.toUpperCase());
  });

  print(transformedMap);
  // {(1): ONE, (2): TWO, (3): THREE}
}

void convertMapToListObject() {
  var list = [];
  Map map = {'Jack': 23, 'Adam': 27, 'Katherin': 25};

  map.forEach((k, v) => list.add(Customer(k, v)));
  print(list);
  // [{ Jack, 23 }, { Adam, 27 }, { Katherin, 25 }]

  map.entries.forEach((e) => list.add(Customer(e.key, e.value)));
  print(list);

  list = map.entries.map((e) => Customer(e.key, e.value)).toList();
  print(list);
}

void convertListToMap() {
  List list = [];
  list.add(Customer('Jack', 23));
  list.add(Customer('Adam', 27));
  list.add(Customer('Katherin', 25));

  var map1 = Map.fromIterable(list, key: (e) => e.name, value: (e) => e.age);
  print(map1);

  var map2 = {};
  list.forEach((customer) => map2[customer.name] = customer.age);
  print(map2);
  // {Jack: 23, Adam: 27, Katherin: 25}
}



