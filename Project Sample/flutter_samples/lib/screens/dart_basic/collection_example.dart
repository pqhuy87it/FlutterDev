import 'package:flutter/material.dart';
import 'dart:core';

/*
  Because of null safety, you can't perform a spread operation (...) on a value that might be null.
  The following example produces a compile-time error because the extraOptions parameter is nullable and the spread operator used on extraOptions is not null-aware.
   */
List<String> buildCommandLine(
  String executable,
  List<String> options, [
  List<String>? extraOptions,
]) {
  return [
    executable,
    ...options,
    // ...extraOptions, // <-- Error
    ...?extraOptions, // <-- OK now.
  ];
}

class Weight {
  final String date;
  final double weight;
  bool selected = false;

  Weight(this.date, this.weight);
}

Map<String, dynamic> mapData = {'2021': 10, '2022': 20, '2023': 30};
List<Weight> weightData =
    mapData.entries.map((entry) => Weight(entry.key, entry.value)).toList();

class Customer {
  String name;
  int age;

  Customer(this.name, this.age);

  @override
  String toString() {
    return '{ ${this.name}, ${this.age} }';
  }
}

void main() {
  Map map = {'Jack': 23, 'Adam': 27, 'Katherin': 25};
  var list = [];

  /*
  Using Map forEach() method
  Now we convert our Map to List above using forEach() method.
   */
  map.forEach((k, v) => list.add(Customer(k, v)));
  print(list);

  /*
  Using Iterable forEach() method
  We can also convert a Dart Map to List using Iterable forEach() method instead.
   */
  map.entries.forEach((e) => list.add(Customer(e.key, e.value)));
  print(list);

  /*
  Using Iterable map() method
  Another way to convert Map to a Dart List is to use Iterable map() method.
   */
  list = map.entries.map((e) => Customer(e.key, e.value)).toList();
  print(list);

  /*
  Using Map.fromIterable()
  We convert List<Customer> into Map using fromIterable() constructor.
   */
  List list1 = [];
  list1.add(Customer('Jack', 23));
  list1.add(Customer('Adam', 27));
  list1.add(Customer('Katherin', 25));

  var map1 = Map.fromIterable(list1, key: (e) => e.name, value: (e) => e.age);
  print(map1);

  /*
  Using Map.fromIterable()
  We convert List<Customer> into Map using fromIterable() constructor.
   */
  var map2 = Map.fromIterable(list, key: (e) => e.name, value: (e) => e.age);
  print(map2);

  /*
  Using Iterable forEach() method
  We can convert Dart List to Map in another way: forEach() method.
   */

  var map3 = {};
  list.forEach((customer) => map3[customer.name] = customer.age);
  print(map3);
}

void createFixedLength() {
  List<String> myList = List<String>.filled(3, '');
  myList[0] = 'one';
  myList[1] = 'two';
  myList[2] = 'three';
  // myList.add('four');
  /* throw UnsupportedError
(Unsupported operation: Cannot add to a fixed-length list) */

  print(myList);

  // Khai báo List<dynamic> cố định 3 phần tử,
  // khởi tạo tất cả các phần tử bằng 'null'.
  List<dynamic> fixedDynamicList = List<dynamic>.filled(
    3,
    null,
    growable: false,
  );

  // 'growable: false' là mấu chốt để làm cho danh sách có kích thước cố định.

  // ---- Ví dụ sử dụng ----

  // Bạn có thể gán lại giá trị tại các vị trí (index)
  // vì là 'dynamic', bạn có thể gán bất kỳ kiểu dữ liệu nào
  fixedDynamicList[0] = 'Flutter'; // Kiểu String
  fixedDynamicList[1] = 100; // Kiểu int
  fixedDynamicList[2] = true; // Kiểu bool

  print(fixedDynamicList); // Output: [Flutter, 100, true]

  // Bạn KHÔNG THỂ thêm hoặc xóa phần tử (sẽ gây lỗi 'Unsupported operation')
  // fixedDynamicList.add('New Item'); // Lỗi
  // fixedDynamicList.removeAt(0);    // Lỗi
}

void combineList() {
  var list1 = [1, 2, 3];
  var list2 = [4, 5];
  var list3 = [6, 7, 8];

  // from() and addAll() method
  var combinedList1 =
      List.from(list1)
        ..addAll(list2)
        ..addAll(list3);

  // expand() method
  var combinedList2 = [list1, list2, list3].expand((x) => x).toList();

  // operator +
  var combinedList3 = list1 + list2 + list3;

  // spread operator
  var combinedList4 = [...list1, ...list2, ...list3];
}

void combineListWithNullValue() {
  var list1 = [1, 2, 3];
  var list2 = null;
  var list3 = [6, 7, 8];

  var combinedList5 = [...list1, ...?list2, ...list3];
}

void accessItemFromList() {
  var myList = [0, 'one', 'two', 'three', 'four', 'five'];

  myList.isEmpty; // false
  myList.isNotEmpty; // true

  myList.length; // 6

  myList.elementAt(2); // two
  myList[2]; // two
  myList[myList.length - 1]; // five

  myList[3] = 3; // myList: [0, one, two, 3, four, five]
  myList.getRange(1, 3).toList(); // [one, two]

  myList.take(3).toList(); // [0, one, two]
}

void removeItemFromList() {
  var myList = [0, 'one', 'two', 'three', 'four', 'five'];

  // remove the item at index '3'
  myList.removeAt(3);
  /* myList:
[0, one, two, four, five]
*/

  // remove() returns false if the item does not exist in the List
  bool isRemoved = myList.remove('three');
  /* isRemoved:
false
*/

  bool isRemoved4thItem = myList.remove('four');
  /* isRemoved4thItem :
true

myList:
[0, one, two, five]
*/

  // remove all items which length > 3
  myList.removeWhere((item) => item.toString().length > 3);
  /* myList:
[0, one, two]
*/

  // remove all items in the List
  myList.clear();
  /* myList:
[]
*/

  var anotherList = [0, 'one', 'two', 'three', 'four', 'five'];
  // remove items from index 2 to 4
  anotherList.removeRange(2, 5);
  /* myList:
[0, one, five]
*/
}

void updateListItem() {
  var myList = [0, 'one', 'two', 'three', 'four', 'five'];

  // replace the item at index '3'
  myList[3] = 3;
  /* myList:
[0, one, two, 3, four, five]
*/

  // replace the item at index '1'
  myList.replaceRange(1, 2, [1]);
  /* myList:
[0, 1, two, 3, four, five]
*/

  // replace the items from index 2 to 4
  myList.replaceRange(2, 5, ['new 2', '3 and 4']);
  /* myList:
[0, 1, new 2, 3 and 4, five]
*/
}

void iterateOverListItem() {
  var myList = [0, 'one', 'two', 'three', 'four', 'five'];

  // use forEach()
  myList.forEach((item) => print(item));
  // or
  myList.forEach(print);

  // use iterator
  var listIterator = myList.iterator;
  while (listIterator.moveNext()) {
    print(listIterator.current);
  }

  // use every()
  myList.every((item) {
    print(item);
    return true;
  });

  // simple for-each
  for (var item in myList) {
    print(item);
  }

  // for loop with item index
  for (var i = 0; i < myList.length; i++) {
    print(myList[i]);
  }
}

void findItemInList() {
  var myList = [0, 2, 4, 6, 8, 2, 8];
  myList.contains(2); // true
  myList.contains(5); // false
  myList.indexOf(2); // 1
  myList.lastIndexOf(2); // 5
  myList.indexWhere((item) => item > 5); // 3
  myList.lastIndexWhere((item) => item > 5); // 6
}

void filterItemInList() {
  var myList = [0, 2, 4, 6, 8, 2, 7];
  myList.where((item) => item > 5).toList(); // [6, 8, 7]
  myList.firstWhere((item) => item > 5); // 6
  myList.lastWhere((item) => item > 5); // 7

  var intList = [5, 8, 17, 11];
  if (intList.every((n) => n > 4)) {
    print('All numbers > 4');
  }

  var intList2 = [5, 8, 17, 11];

  if (intList2.any((n) => n > 10)) {
    print('At least one number > 10');
  }
}

void mapListItemsToNewList() {
  var myList = ['zero', 'one', 'two', 'three', 'four', 'five'];
  var uppers = myList.map((item) => item.toUpperCase()).toList();
  /*
myList: [zero, one, two, three, four, five]
uppers: [ZRO, ONE, TWO, THREE, FOUR, FIVE]
*/
}

void listCollectionIfCondition() {
  var mobile = true;
  var web = false;
  var tringList = ['kotlin', 'dart', if (mobile) 'flutter', if (web) 'react'];
  // [kotlin, dart, flutter]

  var intList = [for (var i = 1; i < 10; i++) i];
  // [1, 2, 3, 4, 5, 6, 7, 8, 9]

  var evenList = [
    for (var i = 1; i < 10; i++)
      if (i % 2 == 0) i,
  ];
  // [2, 4, 6, 8]
}

void sortList() {
  var intList = [0, 5, 2, 3, 8, 17, 11];
  intList.sort();
  print(intList);

  var tringList = ['vue', 'kotlin', 'dart', 'angular', 'flutter'];
  tringList.sort();
  print(tringList);
}

void sortListObjects() {
  List customers = [];
  customers.add(Customer('Jack', 23));
  customers.add(Customer('Adam', 27));
  customers.add(Customer('Katherin', 25));

  customers.sort((a, b) => a.age.compareTo(b.age));
  print('Sort by Age: ' + customers.toString());

  customers.sort((a, b) => a.name.compareTo(b.name));
  print('Sort by Name: ' + customers.toString());
  /*
  Sort by Age: [{ Jack, 23 }, { Katherin, 25 }, { Adam, 27 }]
  Sort by Name: [{ Adam, 27 }, { Jack, 23 }, { Katherin, 25 }]
   */
}

class SortedCustomer implements Comparable {
  String name;
  int age;

  SortedCustomer(this.name, this.age);

  @override
  String toString() {
    return '{ ${this.name}, ${this.age} }';
  }

  // sort by Name (asc), then age (desc)
  @override
  int compareTo(other) {
    int nameComp = this.name.compareTo(other.name);
    if (nameComp == 0) {
      return -this.age.compareTo(other.age); // '-' for descending
    }
    return nameComp;
  }
}

void sortedCustomer() {
  List customers = [];
  customers.add(SortedCustomer('Jack', 23));
  customers.add(SortedCustomer('Adam', 27));
  customers.add(SortedCustomer('Katherin', 25));
  customers.add(SortedCustomer('Jack', 32));

  customers.sort();
  print(customers);
  /*
  [{ Adam, 27 }, { Jack, 32 }, { Jack, 23 }, { Katherin, 25 }]
   */
}

void reverseList() {
  var tringList = ['vue', 'kotlin','dart', 'angular', 'flutter'];

  var reversed = List.of(tringList.reversed);
// [flutter, angular, dart, kotlin, vue]
}

void listOfList() {
  var list1 = [1, 2];
  var list2 = [3, 4];
  var list3 = [5, 6];

  var listOfLists = [list1, list2, list3];
  // [[1, 2], [3, 4], [5, 6]]

  // Sửa lỗi cú pháp: List>  ->  List<List<int>>
  List<List<int>> listOfNumbers =
  List.generate(3, (i) => [i * 2 + 1, i * 2 + 2]); // [[1, 2], [3, 4], [5, 6]]
}

void iterateOverList() {
  var listOfNumbers = [[1, 2], [3, 4, 5], [6, 7, 8]];

  listOfNumbers.forEach((nums) => nums.forEach((number) => print(number)));

  listOfNumbers.every((nums) {
    nums.forEach((number) => print(number));
    return true;
  });

  for (var nums in listOfNumbers) {
    for (var number in nums) {
      print(number);
    }
  }

  for (var i = 0; i < listOfNumbers.length; i++) {
    for (var j = 0; j < listOfNumbers[i].length; j++) {
      print(listOfNumbers[i][j]);
    }
  }

  /* Result:
  1
  2
  3
  4
  5
  6
  7
  8
  */
}

void flattenList() {
  var listOfNumbers = [[1, 2], [3, 4, 5], [6, 7, 8]];

  var flattenList1 = [];
  listOfNumbers
      .forEach((nums) => nums.forEach((number) => flattenList1.add(number)));
  // [1, 2, 3, 4, 5, 6, 7, 8]

  var flattenList2 = [];
  flattenList2 = listOfNumbers.expand((number) => number).toList();
  // [1, 2, 3, 4, 5, 6, 7, 8]
}