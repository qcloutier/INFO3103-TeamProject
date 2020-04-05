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
		present: {
			name: "",
			description: "",
			cost: "",
			url: ""
		},

		auth: false,
		loggedInID: "",
		selectedUserId: 0,

		selectedUserHeader: "",
		selectedUserBday: "",

		displayUserSettings: false,

		userSearchString: "",
		userSearchResult: {},
		userSearchDropdown: {},

		creatingPresent: false,

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
					//this.userSearchString = this.creds.username;
					this.getUsers().then(response => {
						for(var i = 0; i < this.userSearchResult.length; i++){
							if(this.userSearchResult[i].username === this.creds.username){

								break;
							}
						}
						this.initializePageForUser(this.selectedUserId);
					});
					this.loggedInID = response.data.user_id;
					this.selectedUserId = this.loggedInID;
					this.profile.id = response.data.user_id;
					this.profile.dob = response.data.dob;
					this.profile.fname = response.data.first_name;
					this.profile.lname = response.data.last_name;

					this.auth = true;

					document.getElementById("app").setAttribute("class", "");
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
					"dob": this.user.dob,
					"username": this.user.username,
					"password": this.user.password
				}).then(response => {
					alert("Success");
				}).catch(e => {
					alert("Error");
				});

			} else {
				alert("fwhjfjkha");
			}
		},

		deleteUser() {
			var areTheySure = confirm("Are you sure you want to delete your profile?");
			if(areTheySure){
				axios.delete(this.service + "/users/" + this.loggedInID)
				.then(response => {
					alert("Successfully deleted your profile");
					location.reload();
				}).catch(e => {
					alert("Error");
				});
			}
		},

		getUsers() {
			return axios.get(this.service + "/users?first_name=" + this.userSearchString)
			.then(response => {
				this.userSearchResult = response.data;
			}).catch(e => {
				alert("Error");
			});
		},

		selectUser(userId){
			this.selectedUserId = userId;
			getPresents();
		},

		getUser(userId) {
			return axios.get(this.service + "/users/" + userId);
		},

		updateUser() {
			axios
			.put(this.service + "/users/" + this.profile.id, {
				"first_name": this.profile.fname,
				"last_name": this.profile.lname,
				"dob": this.profile.dob,
			})
			.then(response => {
				alert("Successfully updated user");
			})
			.catch(e => {
				alert("Failed to update  user");
				console.log(e);
			});
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
					this.getPresents();
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
			.get(this.service +"/users/" + this.selectedUserId + "/presents?name=" + this.presentSearchString)
			.then(response => {
				for(var i = 0; i < response.data.length; i++){
					response.data[i].updatingPresent = false;
				}
				this.presentSearchResult = response.data;
			})
			.catch(e => {
				alert("Failed to fetch da presents");
				console.log(e);
			});
		},

		updatePresent(present) {
			if(present.user_id != this.loggedInID){
				alert("You may not alter other people's presents");
				return;
			}
			if(present.updatingPresent){
				axios
				.put(this.service + "/users/" + present.user_id + "/presents/" + present.present_id , {
					"name": present.name,
					"description": present.description,
					"cost": present.cost,
					"url": present.url
				})
				.then(response => {
					alert("Successfully updated present");
					this.getPresents();
				})
				.catch(e => {
					alert("Failed to update present");
					console.log(e);
				});

				present.updatingPresent = false;
			} else{
				present.updatingPresent = true;
			}
		},

		deletePresent(presentId) {
			axios.delete(this.service + "/users/" + this.loggedInID + "/presents/" + presentId)
			.then(response => {
				alert("Successfully deleted present");
				this.getPresents();
			}).catch(e => {
				alert("Error");
			});
		},

		initializePageForUser(userId) {
			this.getUser(userId).then(response => {
				this.selectedUserHeader = response.data.first_name + " " + response.data.last_name;
				if(response.data.dob != null){
					this.selectedUserBday = response.data.dob;
				}
			}).catch(e => {
				alert("Error");
			});

			this.getPresents();
		},

		userChanged() {
			var id = this.userSearchDropdown.id;
			this.selectedUserId = id;
			this.initializePageForUser(id);
		},

		showUserSettings() {
			this.displayUserSettings = true;
		},

		hideUserSettings() {
			this.displayUserSettings = false;
		},

		randomPattern() {
			var classes = document.getElementById("app").getAttribute("class");

			switch (Math.floor(Math.random() * 6)) {
				case 0: classes += " ptn-dots"; break;
				case 1: classes += " ptn-stripes-d"; break;
				case 2: classes += " ptn-stripes-h"; break;
				case 3: classes += " ptn-stripes-v"; break;
				case 4: classes += " ptn-waves"; break;
				case 5: classes += " ptn-zigzag"; break;
			}

			switch (Math.floor(Math.random() * 3)) {
				case 0: classes += " bg-blue"; break;
				case 1: classes += " bg-red"; break;
				case 2: classes += " bg-yellow"; break;
			}

			document.getElementById("app").setAttribute("class", classes);
		}
	},

	mounted() {
		this.randomPattern();
	}

});
