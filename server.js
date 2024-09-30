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

app.get('/getTest', function (req, res) {
    const clientIp = req.ip || req.connection.remoteAddress;
    console.log('유저의 Get 요청 / 요청자 IP:', clientIp);
    res.status(200).json({message:'준영 : 서버에서의 Get 요청 응답'})
})

app.post('/postTest', function (req, res) {
    const clientIp = req.ip || req.connection.remoteAddress;

    // 사용자가 보내는 메시지
    const userMessage = req.body.message; // 예를 들어 { "message": "안녕하세요" } 형태로 전송한다고 가정

    // 메시지 콘솔에 출력
    console.log('유저의 Post 요청 / 요청자 IP : '+ clientIp, ' / 사용자 메시지:', userMessage);

    res.status(200).json({message:'준영 : 서버에서의 Post 요청 응답', userMessage: userMessage})
})

https.createServer(options, app).listen(443, () => {
    console.log('HTTPS Server live on 443');
});