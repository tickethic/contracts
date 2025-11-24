import { readFileSync } from "fs";

const githubToken = process.env.PAT_TICKETHIC;
const repoOwner = "tickethic";
const repoName = "tickethic";
const envName = "dev";

if (!githubToken) {
  console.error("Le token PAT_TICKETHIC doit être défini dans les secrets GitHub.");
  process.exit(1);
}

const addresses = JSON.parse(readFileSync("dist/contract-addresses.json", "utf-8"));

const variablesToUpdate = {
  NEXT_PUBLIC_EVENT_MANAGER_CONTRACT: addresses.eventManager,
  NEXT_PUBLIC_EVENT_CONTRACT: addresses.event,
  NEXT_PUBLIC_TICKET_CONTRACT: addresses.ticket,
  NEXT_PUBLIC_ORGANIZATOR_CONTRACT: addresses.organizator,
  NEXT_PUBLIC_ARTIST_CONTRACT: addresses.artist,
};

async function setEnvVariable(key, value) {
  const url = `https://api.github.com/repos/${repoOwner}/${repoName}/environments/${envName}/variables/${key}`;
  const headers = {
    Authorization: `Bearer ${githubToken}`,
    "Content-Type": "application/json",
    Accept: "application/vnd.github+json",
  };
  const body = JSON.stringify({ value });

  // Tente de mettre à jour (PATCH)
  let response = await fetch(url, {
    method: "PATCH",
    headers,
    body,
  });

  if (response.status === 404) {
    // Variable inexistante, crée la (POST)
    const createUrl = `https://api.github.com/repos/${repoOwner}/${repoName}/environments/${envName}/variables`;
    response = await fetch(createUrl, {
      method: "POST",
      headers,
      body,
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(`Erreur création variable ${key}: ${text}`);
    } else {
      console.log(`Variable créée : ${key} = ${value}`);
    }
  } else if (!response.ok) {
    const text = await response.text();
    throw new Error(`Erreur mise à jour variable ${key}: ${text}`);
  } else {
    console.log(`Variable mise à jour : ${key} = ${value}`);
  }
}

async function updateVariables() {
  for (const [key, value] of Object.entries(variablesToUpdate)) {
    try {
      await setEnvVariable(key, value);
    } catch (err) {
      console.error(err);
    }
  }
}

updateVariables().catch((err) => {
  console.error("Erreur lors de mise à jour des variables :", err);
  process.exit(1);
});
