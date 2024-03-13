var app = angular.module('AppBanHang', []);
app.controller("CartCtrl", function ($scope, $http) {
    $scope.listcart = [];
    $scope.TenKhachHang;
    $scope.DiaChi;
    $scope.SoDienThoai;
    $scope.Email;
    $scope.LoadCart = function () {
        $scope.listcart = JSON.parse(localStorage.getItem('cart')) || [];
        makeScript('js/main.js');
    };
    $scope.save = function () {
         let obj= {};
         obj.khach = {};
         obj.khach.TenKhachHang= $scope.TenKhachHang;
         obj.khach.DiaChi= $scope.DiaChi;
         obj.khach.SoDienThoai= $scope.SoDienThoai;
         obj.khach.Email= $scope.Email;
         obj.listchitiet = [];
         let list = JSON.parse(localStorage.getItem('cart'));
         for(var i = 0; i < list.length; i++) {
            obj.listchitiet.push({MaSanPham:list[i].maSanPham, SoLuong: list[i].quantity,GiaMua:10, MaDonHangNavigation:{}})
        }
        $http({
            method: 'POST', 
            data: obj, 
            url: current_url + '/api/KhachHang/create-donhang',
        }).then(function (response) {	
           alert('Thêm đơn hàng thành công');
        });
    };
    
    $scope.LoadCart();
});

