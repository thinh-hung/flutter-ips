import 'package:flutter/material.dart';

import 'Drawer.dart';
import 'draweruser.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("ABOUT IPS CIT")),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.location_on),)
        ],
      ),
      drawer: draweruser(),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width*0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20,),
              Text("Luận văn tốt nghiệp",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
              SizedBox(height: 20,),
              Text("- Đây là dự án luận văn năm 2022, đề tài về định vị trong tòa nhà sử dụng công nghệ bluetooth năng lượng thấp. Do nhóm sinh viên nghành Mạng máy tính & truyền thông dữ liệu khóa 44 thực hiện:\n\n- Lê Quang Long        B1807570\n- Huỳnh Hữu Nhân    B1807580\n- Lương Hưng Thịnh  B1807596",
                style: TextStyle(fontSize: 16),),
            ],
          ),
        ),
      ),
    );
  }
}