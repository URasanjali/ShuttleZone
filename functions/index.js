const functions = require("firebase-functions");
const admin = require("firebase-admin");

const stripe = require("stripe")(
  "sk_test_51Q7ymXRrLNtV0o2MsyL04fjPgV6Lb0aDcDrwtnbBnS35vzbsRS2Fqx4E1YyX5nyWkzKy625R18YQCGMnr6y4qqPR00ntuTD1Yl"
);

admin.initializeApp();

exports.createPaymentIntent = functions.https.onRequest(async (req, res) => {
  try {
    const { amount, currency } = req.body;

    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
    });

    res.status(200).send({
      clientSecret: paymentIntent.client_secret,
    });
  } catch (error) {
    res.status(400).send({
      error: error.message,
    });
  }
});