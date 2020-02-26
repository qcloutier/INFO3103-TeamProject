# INFO3103_TeamProject

## Database:

Tables:
- user (id, first_name,last_name, email, password, dob)
- present (id, name, description, cost, url, user)

Stored Procedures:
- createUser, getUsers, updateUser, deleteUser
- createPresent, getPresents, updatePresent, deletePresent

## Endpoints:

Login:
- POST /login
- DELETE /login

Users:
- GET /users
- POST /users
- GET /users/:id
- PUT /users/:id
- DELETE /users/:id

Presents:
- GET /users/:id/presents
- POST /users/:id/presents
- GET /users/:id/presents/:id
- PUT /users/:id/presents/:id
- DELETE /users/:id/presents/:id
