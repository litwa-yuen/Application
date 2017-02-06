///<reference path="../bower_components/DefinitelyTyped/angular/index.d.ts" />
///<reference path="./FormController.ts"/>
///<reference path="./FormService.ts" />

module Input.Form {

	var form = angular.module('Input.Form', [])
	.service('FormService', Input.Form.FormService)
	.controller('FormController', Input.Form.FormController);

	form.run(($rootScope)=>{
		
	});

}