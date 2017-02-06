/// <reference path="./FormService.ts"/>
/// <reference path="./FormModel.ts"/>

module Input.Form {
	'use strict';
	export class FormController  {
		static $inject = [
			'$scope',
			'FormService'
		]
		constructor(
			private $scope,
			private FormService: Input.Form.FormService
			) {

 			$scope.availableOptions = [
      			{id: "true", name: 'A-Z' },
      			{id: "false", name: 'Z-A' }
      		];

			$scope.submit = () => this.submit();
			$scope.reorder = () => this.reorder();
			this.getField();


		}

		public getField() {
			this.FormService.getField("1").then((data) => {
				this.$scope.form = new FormModel(data);
			})
		}

		public submit() {
			if(this.isValid()) {
				this.FormService.submit(this.$scope.form).then((data)=> {
					console.log("success");
				})
			}
			else {
				console.log("fail");
			}
		}

		public reorder() {
			if(this.$scope.form.displayAlpha == "true") {
				this.$scope.form.choices.sort(function(a, b) { return a > b});
			}
			else {
				this.$scope.form.choices.sort(function(a, b) { return a < b});
			}
		}

		public isValid() {

			//check each choice and compare to default value
			if(this.$scope.form.default != "") {
					var found = false;
					angular.forEach(this.$scope.form.choices, (choice)=> {
					if(choice == this.$scope.form.default) 
						found = true;
					});

					if(!found) {
						//if default value is not in choices +1
						this.$scope.form.choices.push(this.$scope.form.default); 
						if(this.$scope.form.displayAlpha == "true") {
							this.$scope.form.choices.sort(function(a, b) { return a > b});
						}
						else {
							this.$scope.form.choices.sort(function(a, b) { return a < b});
						}
					}
			}
			return this.$scope.form.choices.length <=50;
		
			//check excess 50 choices

		}
	}
}