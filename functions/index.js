const functions = require('firebase-functions');
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors({ origin: true }));

// Your existing API routes here
app.post('/auth/login', (req, res) => {
  // Move your login logic here
});

app.get('/events', (req, res) => {
  // Move your events logic here
});

exports.api = functions.https.onRequest(app);
