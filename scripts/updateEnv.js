const fetch = require("node-fetch");
const fs = require("fs");

const githubToken = process.env.GITHUB_PAT_TICKETHIC;
const repoOwner = "tickethic";
const repoName = "tickethic";
const envName = "dev"; // ou "production"

// Charge les adresses du fichier JSON
const addresses = JSON.parse(fs.readFileSync("dist/contract-addresses.json"));

const variablesToUpdate = {
  NEXT_PUBLIC_EVENT_MANAGER_CONTRACT: addresses.eventManager,
  NEXT_PUBLIC_EVENT_CONTRACT: addresses.event, // si pertinent
  NEXT_PUBLIC_TICKET_CONTRACT: addresses.ticket,
  NEXT_PUBLIC_ORGANIZATOR_CONTRACT: addresses.organizator,
  NEXT_PUBLIC_ARTIST_CONTRACT: addresses.artist,
};

async function updateVariables() {
  for (const [key, value] of Object.entries(variablesToUpdate)) {
    const url = `https://api.github.com/repos/${repoOwner}/${repoName}/environments/${envName}/variables/${key}`;
    await fetch(url, {
      method: "PATCH",
      headers: {
        Authorization: `Bearer ${githubToken}`,
        "Content-Type": "application/json",
        Accept: "application/vnd.github+json",
      },
      body: JSON.stringify({ value }),
    });
    console.log(`Updated ${key} to ${value}`);
  }
}

updateVariables();
