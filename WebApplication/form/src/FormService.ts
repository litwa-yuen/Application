///<reference path="../bower_components/DefinitelyTyped/angular/index.d.ts" />
///<reference path="./FormModel.ts"/>
module Input.Form {
	'use strict';
	export class FormService  {
		
		static $inject = [
			'$http',
			'$q'
		]

		constructor(private $http, private $q) {
		}

		public getField(id:string): ng.IPromise<any> {
			var deferred = this.$q.defer(); 
			var form = {
		  		label: "Sales region",
		  		required: true,
		  		choices: [
					"Asia",
					"Australia",
					"Western Europe",
					"North America",
					"Eastern Europe",
					"Latin America",
					"Middle East and Africa"
		  		],
		  		displayAlpha: "true",
		  		default: "North America"
			};
			deferred.resolve(form);
			return deferred.promise;

		}
	
		public submit(form: FormModel): ng.IPromise<any> {
			console.log(form);
			var deferred = this.$q.defer(); 
			var success = {"status":"success"};
			deferred.resolve(success);
			return deferred.promise;

		}
	}
}