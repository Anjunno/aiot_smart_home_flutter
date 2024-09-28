const express = require('express')
const path = require('path');
require("dotenv").config();
const PORT=80

const app = express()
app.use(express.static(path.join(__dirname, 'styles')));
app.use(cors({origin: '*',}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/', function (req, res) {
    res.sendFile(path.join(__dirname, 'main.html'));
})

app.listen(PORT, function(){
    console.log("Server on port "+PORT)
})
