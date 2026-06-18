class Shop{
  final String id;
  final String name;
  final String? groupId;

  Shop({
    required this.id,
    required this.name,
    this.groupId
  });
  factory Shop.fromFirestore(Map<String,dynamic>data,String id){
    return Shop(id: id, name: data['name']??'',groupId: data['groupId']);
  }
  Map<String,dynamic> toFirestore(){
    return{
      'name':name,
      'groupId':groupId,
    };
  }
}