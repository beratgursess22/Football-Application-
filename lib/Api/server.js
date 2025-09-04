const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const authRoute= require('./routes/authRoute');
const playerRoute = require('./routes/playerRoute');
const teamRoute = require('./routes/teamRoute');
const calenderRoute = require('./routes/calenderRoute');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api', authRoute);
app.use('/api/players', playerRoute);
app.use('/api/teams', teamRoute);
app.use('/api/calender', calenderRoute);


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server ${PORT} portunda çalışıyor`);
});

