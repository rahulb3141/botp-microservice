
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send("Hello from Blue-Green Deployment! This is the active version.");
});

app.listen(8080, () => {
    console.log("App running on port 8080");
});
