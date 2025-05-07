const express = require('express');
const Stripe = require('stripe');
const bodyParser = require('body-parser');
const cors = require('cors');  // Import the cors package
require('dotenv').config();

const app = express();
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);  // Your secret key from Stripe

// Enable CORS for all routes
app.use(cors());

// Parse incoming JSON requests
app.use(bodyParser.json());

// Endpoint to create a payment intent
// Endpoint to create a payment intent
app.post('/create-payment-intent', async (req, res) => {
    const { totalCost } = req.body;  // ✅ expect 'totalCost'
  
    try {
      const paymentIntent = await stripe.paymentIntents.create({
        amount: totalCost, // already in cents from Flutter
        currency: 'usd',
        payment_method_types: ['card'],
      });
  
      res.json({
        clientSecret: paymentIntent.client_secret,
      });
    } catch (error) {
      res.status(500).send({ error: error.message });
    }
  });
  

// **Add this endpoint for confirming the payment**
app.post('/confirm-payment', async (req, res) => {
  const { paymentMethodId, clientSecret } = req.body;

  try {
    const paymentIntent = await stripe.paymentIntents.confirm(
      clientSecret, {
        payment_method: paymentMethodId,
      }
    );
    
    res.status(200).send({ success: true });
  } catch (error) {
    res.status(500).send({ error: error.message });
  }
});

// Start the server
const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Server is running on port ${port}`));
