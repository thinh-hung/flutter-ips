class Matrix2d {
  int? sizex;
  int? sizey;
  List<List<int>>? array;

  Matrix2d(this.sizex, this.sizey, {this.array});

  factory Matrix2d.init(int sizex, int sizey) {
    List<List<int>> array = [];
    //Khoi tao ma tran rong nxn gan tat ca phan tu bang 0
    for (var i = 0; i < sizex; i++) {
      List<int> arr = [];
      for (var j = 0; j < sizey; j++) {
        arr.add(0);
      }
      array.add(arr);
    }
    return Matrix2d(sizex, sizey, array: array);
  }

  factory Matrix2d.room(int sizex, int sizey) {
    List<List<int>> array = [];
    //Khoi tao ma tran rong nxn gan tat ca phan tu bang 0
    for (var i = 0; i < sizex; i++) {
      List<int> arr = [];
      for (var j = 0; j < sizey; j++) {
        arr.add(0);
      }
      array.add(arr);
    }

    int count = 1;
    int top = 0;
    int left = 0;
    int bottom = sizex - 1;
    int right = sizey - 1;

    //duyet tu trai sang phai
    for (var i = left; i <= right; i++) {
      array[top][i] = count;
    }

    //duyet tu tren xuong duoi
    for (var i = top; i <= bottom; i++) {
      array[i][right] = count;
    }

    //duyet tu phai sang trai
    for (var i = right; i >= left; i--) {
      array[bottom][i] = count;
    }

    //duyet tu duoi len tren
    for (var i = bottom; i >= top; i--) {
      array[i][left] = count;
    }
    return Matrix2d(sizex, sizey, array: array);
  }
}

List<List<int>> matrix(int sizex, int sizey) {
  Matrix2d matrix2d = new Matrix2d.init(sizex, sizey);
  List<List<int>> result = matrix2d.array ?? [];
  return result;
}

List<List<int>> room(int sizex, int sizey) {
  Matrix2d matrix2d = new Matrix2d.room(sizex, sizey);
  List<List<int>> result = matrix2d.array ?? [];
  return result;
}

// void main() {
//   List<List<int>> m = matrix(4, 6);
//   print(m);
//   m[2][2] = 1;
//   m[3][5] = 1;
//   print(m);
//
//   List<List<int>> r = room(4, 6);
//   print(r);
// }