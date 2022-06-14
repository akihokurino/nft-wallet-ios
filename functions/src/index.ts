import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();
const storage = admin.storage();
const Moralis = require("moralis/node");

const location = "asia-northeast1";
const serverUrl = functions.config().moralis.server_url;
const appId = functions.config().moralis.app_id;
const masterKey = functions.config().moralis.master_key;

/* eslint-disable no-unused-vars */
exports.uploadIPFS = functions
  .region(location)
  .https.onCall(async (data, context) => {
    Moralis.initialize(appId, "", masterKey);
    Moralis.serverURL = serverUrl;

    const object = {
      key: "value",
    };
    const file = new Moralis.File("file.json", {
      base64: btoa(JSON.stringify(object)),
    });
    await file.saveIPFS({ useMasterKey: true });

    return {
      gateway: file.ipfs(),
    };
  });
/* eslint-enable no-unused-vars */
