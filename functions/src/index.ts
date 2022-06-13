import * as functions from "firebase-functions";

const location = "asia-northeast1";

/* eslint-disable no-unused-vars */
exports.uploadIPFS = functions
  .region(location)
  .https.onCall((data, context) => {
    console.log("TODO");

    return {
      gateway: "https://ipfs.io/ipfs/hoge",
    };
  });
/* eslint-enable no-unused-vars */
