import { LightningElement, api, track } from "lwc";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";
import { FlowNavigationNextEvent } from "lightning/flowSupport";

/* eslint-disable no-alert */
/* eslint-disable no-console */

export default class selectUserFsc extends LightningElement {
	@api value;
	@track item;
	@api choiceLabels; //string collection
	@api choiceValues; //string collection
    @api choiceIcons; //string collection
    @api prompt = "Select User";
	@api autoNext = false;
	@api iconSize = "large";
	@api required;
	@api outputLabel;
	@api outputUniqueId;
	@api iconVariant = "circle";
	@api boxSize = 60;

	@track items = [];

	connectedCallback() {
		console.log("initializing visualPicker ");
		console.log(this.choiceIcons.length, "choiceIcons is: " + this.choiceIcons);
		let items = [];
		let index = 0;
		console.log(
			this.choiceLabels.length,
			"choiceLabels is: " + this.choiceLabels
		);
		this.choiceLabels.forEach((label) => {
			console.log("item", index, label);
			items.push({
				label: label,
				value: this.choiceValues[index],
				icon: this.choiceIcons[index] ? this.choiceIcons[index] : null,
				uniqueId: this.choiceValues[index] + "+" + index,
			});
			index += 1;
		});
		this.items = items;
	}

	@api
	validate() {
		//If the component is invalid, return the isValid parameter as false and return an error message.
		console.log(
			"entering validate: required=" + this.required + " value=" + this.value
		);
		let errorMessage = "You must make a selection to continue";

		if (this.required === true && !this.value) {
			return {
				isValid: false,
				errorMessage: errorMessage,
			};
		}

		return {
			isValid: true,
		};
	}

	handleChange(event) {
		this.outputLabel = event.target.dataset.outputlabel;
		this.value = event.target.dataset.outputvalue;
		this.outputUniqueId = event.target.dataset.outputunique;
		console.log("outputLabel: ", this.outputLabel);
		console.log("value: ", this.value);
		console.log("uniqueId: ", this.outputUniqueId);
		this.dispatchEvent(new FlowAttributeChangeEvent("value", this.value));
		this.dispatchEvent(
			new FlowAttributeChangeEvent("outputLabel", this.outputLabel)
		);
		this.dispatchEvent(
			new FlowAttributeChangeEvent("outputSubLabel", this.outputSubLabel)
		);
		if (this.autoNext === true) {
			console.log("autoNext: ", this.autoNext);
			const nextNavigationEvent = new FlowNavigationNextEvent("navigate");
			this.dispatchEvent(nextNavigationEvent);
		}
	}

	handleKeyUp(event) {
		console.log("keyCode: ", event.keyCode);
		this.outputLabel = event.target.dataset.outputlabel;
		this.value = event.target.dataset.outputvalue;
		this.outputUniqueId = event.target.dataset.outputunique;
		console.log("outputLabel: ", this.outputLabel);
		console.log("value: ", this.value);
		console.log("uniqueId: ", this.outputUniqueId);
		this.dispatchEvent(new FlowAttributeChangeEvent("value", this.value));
		this.dispatchEvent(
			new FlowAttributeChangeEvent("outputLabel", this.outputLabel)
		);
		this.dispatchEvent(
			new FlowAttributeChangeEvent("outputSubLabel", this.outputSubLabel)
		);
		if (event.keyCode === 13 || event.keyCode === 32) {
			const nextNavigationEvent = new FlowNavigationNextEvent("navigate");
			this.dispatchEvent(nextNavigationEvent);
		}
	}

	get sizeWidth() {
		return (
			"width: " + this.boxSize + "px ; height: " + this.boxSize + "px"
		);
	}
}
