Vue.component("modal", {
	template: "#modal-template"
});

var app = new Vue({
	el: "#app",

	data: {
		service: "https://info3103.cs.unb.ca:8046",
		creds: {
			username: "",
			password: ""
		},
		user: {
			id: "",
			first_name: "",
			last_name: "",
			dob: "",
			username: "",
			password: ""
		},
		profile: {
			id: "",
			fname: "",
			lname: "",
			dob: ""
		},
		auth: false,
		loggedInID: "",
		displayUserSettings: false,
		userSearchString: "",
		userSearchResult: {},
		creatingPresent: false,
		present: {
			name: "",
			description: "",
			cost: "",
			url: ""
		},
		presentSearchString: "",
		presentSearchResult: {}
	},

	methods: {

		login() {
			if (this.creds.username != "" && this.creds.password != "") {
				axios.post(this.service + "/login", {
					"username": this.creds.username,
					"password": this.creds.password
				}).then(response => {
					alert("Success");
					this.auth = true;

					this.userSearchString = this.creds.username;
					this.getUsers().then(response => {
						for(var i = 0; i < this.userSearchResult.length; i++){
							if(this.userSearchResult[i].username === this.creds.username){
								this.loggedInID = this.userSearchResult[i].user_id;
								break;
							}
						}
					});

				}).catch(e => {
					alert("Invalid credentials");
				});
			} else {
				alert("No credentials provided");
			}
		},

		logout() {
			axios.delete(this.service + "/login")
			.then(response => {
				location.reload();
			}).catch(e => {
				console.log(e);
			});
		},

		createUser() {
			if (this.user.first_name != "" && this.user.last_name != "") {
				axios.post(this.service + "/users", {
					"first_name": this.user.first_name,
					"last_name": this.user.last_name,
					"dob": this.profile.dob,
					"username": this.user.username,
					"password": this.user.password
				}).then(response => {
					alert("Success");
					this.auth = true;
				}).catch(e => {
					alert("Error");
				});
			} else {
				alert("fwhjfjkha");
			}
		},

		deleteUser() {

		},

		getUsers() {
			return axios.get(this.service + "/users?name=" + this.userSearchString)
			.then(response => {
				this.userSearchResult = response.data;
			}).catch(e => {
				alert("Error");
			});
		},

		getUser() {
			axios.get(this.service + "/users/" + this.user.id)
			.then(response => {
				alert("Success");
				this.auth = true;
			}).catch(e => {
				alert("Error");
			});
		},

		updateUser() {

		},

		addCreatePresentRow() {
			this.creatingPresent = true;
		},

		createPresent() {
			if (this.present.name != "") {
				axios.post(this.service + "/users/" + this.loggedInID + "/presents", {
					"name": this.present.name,
					"description": this.present.description,
					"cost": this.present.cost,
					"url": this.present.url
				}).then(response => {
					alert("Successfully created present");
					this.creatingPresent = false;
				}).catch(e => {
					alert("Error");
				});
			} else {
				alert("fwhjfjkha");
			}
		},

		getPresent(presentId) {

		},

		getPresents() {
			axios
			.get(this.service +"/users/" + this.loggedInID + "/presents?name=" + this.presentSearchString)
			.then(response => {
				this.presentSearchResult = response.data;
			})
			.catch(e => {
			  alert("Failed to fetch da presents");
			  console.log(e);
			});
		},

		updatePresent() {

		},

		deletePresent(presentId) {
			axios.delete(this.service + "/users/" + this.loggedInID + "/presents/" + presentId)
			.then(response => {
				alert("Successfully deleted present");
			}).catch(e => {
				alert("Error");
			});
		},

		showUserSettings() {
			this.displayUserSettings = true;
		},

		hideUserSettings() {
			this.displayUserSettings = false;
		}
	}

});
