import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();
const storage = admin.storage();
const Moralis = require("moralis/node");

const location = "asia-northeast1";
const serverUrl = functions.config().moralis.server_url;
const appId = functions.config().moralis.app_id;
const masterKey = functions.config().moralis.master_key;

exports.uploadNftMetadata = functions
  .region(location)
  .https.onCall(async (data) => {
    const path = data.path;
    const name = data.name;
    const description = data.description;
    const externalUrl = data.externalUrl;

    const result = await storage.bucket().file(path).download();

    Moralis.initialize(appId, "", masterKey);
    Moralis.serverURL = serverUrl;

    const imageFile = new Moralis.File(name, {
      base64: result[0].toString("base64"),
    });
    await imageFile.saveIPFS({ useMasterKey: true });
    const imageUrl = imageFile.ipfs();

    const metadataFile = new Moralis.File("metadata.json", {
      base64: btoa(
        JSON.stringify({
          name,
          description,
          external_url: externalUrl,
          image: imageUrl,
        })
      ),
    });
    await metadataFile.saveIPFS({ useMasterKey: true });
    const metadataUrl = metadataFile.ipfs();

    return {
      url: metadataUrl,
    };
  });
