const express = require('express');
const stripe = require('stripe')('sk_test_51Px58MGj3R37BVZgkaSRWLV1aq2FU82Omhe9uy8bZdV6QwZ9p5aZnyzPOpQETSVwNzM04PGfPjXjxh93TCjzUue400pGUu4DMc');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(bodyParser.json());

// app.use(cors());

app.post('/create-payment-intent', async (req, res) => {
  const { amount, currency } = req.body;

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      capture_method: 'automatic',
    });

    res.send({
      clientSecret: paymentIntent.client_secret,
    });
  } catch (e) {
    res.status(400).send({
      error: e.message,
    });
  }
});

app.listen(3001, () => console.log("Server running on port 3001"));
