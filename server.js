const express = require('express')
const path = require('path');
const dotenv = require('dotenv');
const https=require('https');
const fs=require('fs');
const cors = require('cors');

dotenv.config();

const app = express()
app.use(express.static(path.join(__dirname, 'styles')));
app.use(cors({origin: '*',}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const options = {
    key: fs.readFileSync(process.env.SSL_KEY),
    cert: fs.readFileSync(process.env.SSL_CERT)
};

app.get('/', function (req, res) {
    res.sendFile(path.join(__dirname, 'main.html'));
})

https.createServer(options, app).listen(443, () => {
    console.log('HTTPS Server live on 443');
});