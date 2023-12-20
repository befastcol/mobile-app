const { Schema, model } = require("mongoose");

const UserSchema = new Schema({
	phoneNumber: { type: String, required: true, unique: true },
	name: { type: String, required: true },
	isDriver: { type: Boolean, required: true },
	hasActiveService: { type: Boolean },
});

const UserModel = model("User", UserSchema);

module.exports = UserModel;
