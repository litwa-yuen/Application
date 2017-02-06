///<reference path="../bower_components/DefinitelyTyped/angular/index.d.ts" />

module Input.Form {
	'use strict';

	export class FormModel {
		public label: string;
		public required: boolean;
		public choices: string[];
		public default: string;
		public displayAlpha: boolean;

		constructor(init:any) {

			this.label = init.label;
			this.required = init.required;
			this.default = init.default;
			this.displayAlpha = init.displayAlpha;
			this.choices = [];
			angular.forEach(init.choices, (choice)=> {
				this.choices.push(choice);
			});
		}
	}
}