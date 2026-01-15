extends RefCounted
class_name  LDM

var db


func _init() -> void:
	db = SQLite.new()
	db.path = "user://data.db"
	db.open_db()
	var table = {
		"id" : {"data_type": "int","primary_key": true, "not_null" : true, "auto_increment" : true},
		"name": {"data_type" : "text"},
		"password": {"data_type" : "text"},
		"salt":{"data_type": "text", "not_null" : true}
	}
	
	db.create_table("users", table)
	pass


func InsertUserData(name,password,salt):
	var data = {
		"name" : name,
		"password" : password,
		"salt" : salt
	}
	db.insert_row("users", data)


func GetUserFromDB(username):
	var query = "SELECT salt,password,id from users where name = ?"
	var paramBindings = [username]
	db.query_with_bindings(query,paramBindings)
	
	
	for i in db.query_result:
		return {
			"id" : i["id"],
			"hashedPassword" : i["password"],
			"salt" : i["salt"],
			"name" : username
		}
