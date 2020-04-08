Vue.component("modal", {
	template: "#modal-template"
});

var app = new Vue({
	el: "#app",

	data: {
		service: "https://info3103.cs.unb.ca:8046",

		signin: { username: "", password: "", auth: false, error: "" },
		signup: { first_name: "", last_name: "", dob: "", username: "", password: "", error: "" },

		account: { user_id: "", first_name: "", last_name: "", dob: "", updating: false, msg: "" },
		profile: { user_id: "", name: "", birthday: "" },
		userSearch: { query: "", results: {}, dropdown: {} },

		present: { present_id: "", name: "", description: "", cost: "", url: "", creating: false, updating: false, error: "" },
		presentSearch: { query: "", results: {} }
	},

	methods: {
		/*
		Pick a random pattern and colour for
		the background of the application.
		*/
		randomPattern() {
			var ptn = "";
			var bg = "";

			switch (Math.floor(Math.random() * 6)) {
				case 0: ptn = "ptn-dots"; break;
				case 1: ptn = "ptn-stripes-d"; break;
				case 2: ptn = "ptn-stripes-h"; break;
				case 3: ptn = "ptn-stripes-v"; break;
				case 4: ptn = "ptn-waves"; break;
				case 5: ptn = "ptn-zigzag"; break;
			}

			switch (Math.floor(Math.random() * 3)) {
				case 0: bg = "bg-blue"; break;
				case 1: bg = "bg-red"; break;
				case 2: bg = "bg-yellow"; break;
			}

			document.getElementById("app").classList.add(bg, ptn);
		},

		/*
		Login to the service using the
		values in the sigin object.
		*/
		login() {
			if (this.signin.username != "" && this.signin.password != "") {
				axios.post(this.service + "/login", {
					"username": this.signin.username,
					"password": this.signin.password
				}).then(response => {
					this.getUser(response.data.user_id).then(response => {
						this.account.user_id    = response.data.user_id;
						this.account.dob        = response.data.dob;
						this.account.first_name = response.data.first_name;
						this.account.last_name  = response.data.last_name;
					}).catch(e => {
						console.log(e);
					});

					this.getUsers();
					this.showProfile(response.data.user_id);
					this.signin.auth = true;
				}).catch(e => {
					this.signin.error = "Incorrect username or password.";
				});
			} else {
				this.signin.error = "Username and password are required.";
			}
		},

		/*
		Register a new user with the service
		using the values in the signup object.
		*/
		createUser() {
			if (this.signup.first_name != "" && this.signup.last_name != ""
					&& this.signup.username != "" && this.signup.password != "") {
				axios.post(this.service + "/users", {
					"first_name": this.signup.first_name,
					"last_name":  this.signup.last_name,
					"dob":        this.signup.dob,
					"username":   this.signup.username,
					"password":   this.signup.password
				}).then(response => {
					this.signin.username = this.signup.username;
					this.signin.password = this.signup.password;
					this.login();
				}).catch(e => {
					this.signup.error = "Invalid username or password.";
				});
			} else {
				this.signup.error = "All required fields must be filled.";
			}
		},

		/*
		Logout the current user and reset
		the state of the application.
		*/
		logout() {
			axios.delete(this.service + "/login")
			.then(response => {
				location.reload();
			}).catch(e => {
				console.log(e);
			});
		},

		/*
		Show or hide the modal dialog
		for the user's account settings.
		*/
		showUserSettings() {
			this.showProfile(this.account.user_id);
			this.account.updating = true;
			this.account.msg = "";
		},
		hideUserSettings() {
			this.showProfile(this.account.user_id);
			this.account.updating = false;
			this.account.msg = "";
		},

		/*
		Update the user's account information
		using the values in the account object.
		*/
		updateUser() {
			axios.put(this.service + "/users/" + this.account.user_id, {
				"first_name": this.account.first_name,
				"last_name":  this.account.last_name,
				"dob":        this.account.dob,
			}).then(response => {
				this.account.msg = "Updated successfully.";
			}).catch(e => {
				this.console.log(e);
			});
		},

		/*
		Delete the user's account from the service
		and reset the state of the application.
		*/
		deleteUser() {
			var areTheySure = confirm("Are you sure you want to delete your account?");
			if(areTheySure){
				axios.delete(this.service + "/users/" + this.account.user_id)
				.then(response => {
					location.reload();
				}).catch(e => {
					console.log(e);
				});
			}
		},

		/*
		Fetch and display the data for the profile view,
		including the user's name, birthday, and present list.
		*/
		showProfile(userID) {
			this.getUser(userID).then(response => {
				this.profile.user_id = userID;
				this.profile.name    = response.data.first_name + " " + response.data.last_name;

				if(response.data.dob != null){
					var d = new Date(response.data.dob);
					d.setDate(d.getDate() + 1);
					this.profile.birthday = "🎂 " + (d.getMonth()+1) + "/" + (d.getDate()) + "/" + d.getFullYear();
				} else {
					this.profile.birthday = "";
				}

				this.getPresents();
			}).catch(e => {
				console.log(e);
			});
		},

		/*
		Get the data for the user with the given ID.
		*/
		getUser(userID) {
			return axios.get(this.service + "/users/" + userID);
		},

		/*
		Get a list of all users and allow the user
		to select one to view their profile.
		*/
		getUsers() {
			return axios.get(this.service + "/users?first_name=" + this.userSearch.query)
			.then(response => {
				this.userSearch.results = response.data;
			}).catch(e => {
				console.log(e);
			});
		},
		userChanged(id) {
			this.showProfile(id);
		},

		/*
		Get all of the presents belonging
		to the user with the selected profile.
		*/
		getPresents() {
			axios.get(this.service +"/users/" + this.profile.user_id + "/presents?name=" + this.presentSearch.query)
			.then(response => {

				for(var i = 0; i < response.data.length; i++){
					response.data[i].updating = false;
				}

				axios.get(this.service +"/users/" + this.profile.user_id + "/presents?description=" + this.presentSearch.query)
				.then(response1 => {

					for(var i = 0; i < response1.data.length; i++){
						response1.data[i].updating = false;

						//Iterate over first list and see if this item is present
						var isUnique = true;
						for(var j = 0; j < response.data.length; j++){
							if(response.data[j].present_id == response1.data[i].present_id){
								isUnique = false;
								break;
							}
						}

						if(isUnique){
							response.data.push(response1.data[i]);
						}

					}

					this.presentSearch.results = response.data;
				}).catch(e => {
					console.log(e);
				});

				for(var i = 0; i < response.data.length; i++){
					response.data[i].updating = false;
				}
				this.presentSearch.results = response.data;
			}).catch(e => {
				console.log(e);
			});
		},

		/*
		Display input fields for a new present,
		and create it once they are filled.
		*/
		createPresent() {
			if (this.present.creating) {
				if (this.present.name != "" && this.present.description != "" && this.present.cost != "") {
					axios.post(this.service + "/users/" + this.account.user_id + "/presents", {
						"name":        this.present.name,
						"description": this.present.description,
						"cost":        this.present.cost,
						"url":         this.present.url
					}).then(response => {
						this.present.name = "";
						this.present.description = "";
						this.present.cost = "";
						this.present.url = "";

						this.getPresents();
					}).catch(e => {
						console.log(e);
					});

					this.present.error = "";
					this.present.creating = false;
				} else {
					this.present.error = "Name, description, and cost are required."
				}
			} else {
				this.present.creating = true;
			}
		},

		/*
		Display input fields for updating a present,
		and apply the changes after they've been made.
		*/
		updatePresent(present) {
			if (present.updating){
				axios.put(this.service + "/users/" + present.user_id + "/presents/" + present.present_id, {
					"name":        present.name,
					"description": present.description,
					"cost":        present.cost,
					"url":         present.url
				}).then(response => {
					this.getPresents();
				}).catch(e => {
					console.log(e);
				});

				present.updating = false;
			} else {
				present.updating = true;
			}
		},

		/*
		Delete the present with the given
		ID number from the serivce.
		*/
		deletePresent(presentID) {
			axios.delete(this.service + "/users/" + this.account.user_id + "/presents/" + presentID)
			.then(response => {
				this.getPresents();
			}).catch(e => {
				console.log(e);
			});
		}
	},

	mounted() {
		this.randomPattern();
		document.getElementById("app").style.visibility = 'visible';
	}
});
