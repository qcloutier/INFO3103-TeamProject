Vue.component("modal", {
	template: "#modal-template"
});

var app = new Vue({
	el: "#app",

	data: {
		service: "https://info3103.cs.unb.ca:8037",
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
		displayUserSettings: false
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

		showUserSettings() {
			this.displayUserSettings = true;
		},

		hideUserSettings() {
			this.displayUserSettings = false;
		}
	}

});
