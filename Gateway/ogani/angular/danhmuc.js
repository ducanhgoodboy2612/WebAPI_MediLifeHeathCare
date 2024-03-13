 var app = angular.module('AppBanHang', []);
app.controller("DanhMucCtrl", function ($scope, $http) {
    $scope.listSanPham; 
    $scope.pageSize="5";   
    $scope.LoadSanPham = function () {	
        
        var key = 'id';
		var value = window.location.search.substring(window.location.search.indexOf(key)+key.length+1);		 
        let obj =  {};
        obj.page = "1";
        obj.pageSize = $scope.pageSize;
        debugger;
        obj.MaDanhMuc = value;
        $http({
            method: 'POST', 
            data: obj, 
            url: current_url + '/api/DanhMuc/search',
        }).then(function (response) {	
            $scope.listSanPham = response.data.data;
			makeScript('js/main.js')
        });
    };  
    $scope.LoadSanPham();     
});
