import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'main.dart';

class OrderEntryDto{
  final int count;
  final int bookId;
  late double cost;
  String bookName = "";
  Uint8List img = Uint8List(0);

  OrderEntryDto(this.count, this.bookId);


  OrderEntryDto.fromMap(Map<String, dynamic> map)
      : count = map["quantity"],
        cost = map['price'],
        bookId = map['bookId']
      {
        orderEntities.forEach((element) {
          if(element.book.id == bookId){
              bookName = element.book.title;
              return;
          }
        });
      }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'quantity': count
    };
  }
}
class OrderDto{
  late int? userId;
  late List<OrderEntryDto> orderEntries;

  OrderDto(this.userId, this.orderEntries);
  OrderDto.fromMap(Map<String, dynamic> map){
    orderEntries = [];
    List<dynamic> list = map['bookOrders'];
    for(Map<String, dynamic> m in list){
      orderEntries.add(OrderEntryDto.fromMap(m));
    }
  }
  Map<String, dynamic> toMap(){
    List<Map<String, dynamic>> list = [];
    for(var order in orderEntries){
      list.add(order.toMap());
    }
    return {
      "userId": userId==null?0:userId,
      "bookOrders": list
    };
  }
}
class OrderFullDto{

  final String date;
  final int orderId;
  final double totalPrice;

  List<OrderEntryDto> orderEntries = [];

  OrderFullDto(this.date, this.orderId, this.orderEntries, this.totalPrice);
  OrderFullDto.fromMap(Map<String, dynamic> map)
  :
        date = map['orderDate'],
        orderId = map['id'],
        totalPrice = map['totalPrice']
  ;
}