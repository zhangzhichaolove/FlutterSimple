import 'package:firstflutter/net/HttpController.dart';
import 'package:flutter/material.dart';

//void main() {
//  runApp(new MaterialApp(
//    title: "ListView",
//    debugShowCheckedModeBanner: false,
//    home: new ListViewPage(),
//  ));
//}

class ListViewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyState();
}

class MyState extends State {
  List<ItemEntity> entityList = [];
  ScrollController _scrollController = new ScrollController();
  bool isLoadData = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print("------------加载更多-------------");
        _getMoreData();
      }
    });
    for (int i = 0; i < 10; i++) {
      entityList.add(ItemEntity("Item  $i", Icons.add_location));
    }
    Map map = new Map<String, String>();
    map["page"] = "1";
    map["count"] = "5";
    HttpController.post(
        "https://api.apiopen.top/getJoke", (data) => {print(data)},
        params: map);
  }

  Future<Null> _getMoreData() async {
    await Future.delayed(Duration(seconds: 2), () {
      //模拟延时操作
      if (!isLoadData) {
        isLoadData = true;
        setState(() {
          isLoadData = false;
          List<ItemEntity> newList = List.generate(
              5,
              (index) => new ItemEntity(
                  "上拉加载--item ${index + entityList.length}", Icons.ac_unit));
          entityList.addAll(newList);
        });
      }
    });
  }

  Future<Null> _handleRefresh() async {
    print('-------开始刷新------------');
    await Future.delayed(Duration(seconds: 2), () {
      //模拟延时
      setState(() {
        entityList.clear();
        entityList = List.generate(
            8,
            (index) =>
                new ItemEntity("下拉刷新后--item $index", Icons.bluetooth_audio));
        return null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("ListView"),
        ),
        body: RefreshIndicator(
            displacement: 50,
            color: Colors.redAccent,
            backgroundColor: Colors.blue,
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                if (index == entityList.length) {
                  return LoadMoreView();
                } else {
                  return ItemView(entityList[index]);
                }
              },
              itemCount: entityList.length + 1,
              controller: _scrollController,
            ),
            onRefresh: _handleRefresh));
  }
}

/**
 * 渲染Item的实体类
 */
class ItemEntity {
  String title;
  IconData iconData;

  ItemEntity(this.title, this.iconData);
}

/**
 * ListView builder生成的Item布局，读者可类比成原生Android的Adapter的角色
 */
class ItemView extends StatelessWidget {
  ItemEntity itemEntity;

  ItemView(this.itemEntity);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Text(
              itemEntity.title,
              style: TextStyle(color: Colors.black87),
            ),
            Positioned(
                child: Icon(
                  itemEntity.iconData,
                  size: 30,
                  color: Colors.blue,
                ),
                left: 5)
          ],
        ));
  }
}

class LoadMoreView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: Row(
            children: <Widget>[
              new CircularProgressIndicator(),
              Padding(padding: EdgeInsets.all(10)),
              Text('加载中...')
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
      color: Colors.white70,
    );
  }
}
