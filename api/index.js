const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const User = require("./models/user");

const app = express();

app.use(cors());
app.use(express.json());

mongoose.connect(
	"mongodb+srv://befastcol:Befastcol123@befastcluster.pvmocwr.mongodb.net/?retryWrites=true&w=majority"
);

app.post("/register", async (req, res) => {
	const { user, phoneNumber } = req.body;
	const userDoc = await User.create({ user, phoneNumber });
	res.json(userDoc);
});

app.listen(4000);
