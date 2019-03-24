var myApp = angular.module('myApp',['ngRoute']);

myApp.config(function($routeProvider){
	$routeProvider.when('/', {
		controller:'UsersController',
		templateUrl: 'views/users.html'
	})
	.when('/users', {
		controller:'UsersController',
		templateUrl: 'views/users.html'
	})
	.when('/users/details/:id',{
		controller:'UsersController',
		templateUrl: 'views/user_details.html'
	})
	.when('/users/add',{
		controller:'UsersController',
		templateUrl: 'views/add_user.html'
	})
	.when('/users/edit/:id',{
		controller:'UsersController',
		templateUrl: 'views/edit_user.html'
	})
	.otherwise({
		redirectTo: '/'
	});
});