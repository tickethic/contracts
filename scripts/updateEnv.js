import { readFileSync } from "fs";

const githubToken = process.env.GITHUB_PAT_TICKETHIC;
const repoOwner = "tickethic";
const repoName = "tickethic";
const envName = "dev";

const addresses = JSON.parse(readFileSync("dist/contract-addresses.json", "utf-8"));

const variablesToUpdate = {
  NEXT_PUBLIC_EVENT_MANAGER_CONTRACT: addresses.eventManager,
  NEXT_PUBLIC_EVENT_CONTRACT: addresses.event,
  NEXT_PUBLIC_TICKET_CONTRACT: addresses.ticket,
  NEXT_PUBLIC_ORGANIZATOR_CONTRACT: addresses.organizator,
  NEXT_PUBLIC_ARTIST_CONTRACT: addresses.artist,
};

async function updateVariables() {
  for (const [key, value] of Object.entries(variablesToUpdate)) {
    const url = `https://api.github.com/repos/${repoOwner}/${repoName}/environments/${envName}/variables/${key}`;
    const response = await fetch(url, {
      method: "PATCH",
      headers: {
        Authorization: `Bearer ${githubToken}`,
        "Content-Type": "application/json",
        Accept: "application/vnd.github+json",
      },
      body: JSON.stringify({ value }),
    });

    if (!response.ok) {
      console.error(`Error updating ${key}:`, await response.text());
    } else {
      console.log(`Updated ${key} to ${value}`);
    }
  }
}

updateVariables().catch(console.error);
