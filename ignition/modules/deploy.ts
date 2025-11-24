import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import fs from "fs";

const TickethicWithEventManagerModule = buildModule("TickethicWithEventManagerModule", (m) => {
  // Deploy Artist contract
  const artist = m.contract("Artist");

  // Deploy Ticket contract with deployer as initial owner
  const ticket = m.contract("Ticket", [m.getAccount(0)]);

  // Deploy Organizator contract with deployer as owner and initial organizers
  const initialOrganizers = [m.getAccount(0)]; // Use the same account as deployer and organizer
  const organizator = m.contract("Organizator", [m.getAccount(0), initialOrganizers]);

  // Deploy Event contract with sample data
  const artistIds = [1, 2, 3]; // These will be minted after deployment
  const artistShares = [40, 30, 20]; // 90% to artists, 10% to organizer
  const eventDate = Math.floor(Date.now() / 1000) + 86400; // 1 day from now
  const metadataURI = "ipfs://event-metadata";
  const ticketPrice = 1000000000000000000n; // 1 ETH in wei
  const totalTickets = 100;

  const event = m.contract("Event", [
    artist,
    artistIds,
    artistShares,
    m.getAccount(0), // organizer (same as deployer)
    eventDate,
    metadataURI,
    ticketPrice,
    totalTickets,
    ticket,
    organizator,
  ]);

  // Deploy EventManager
  const eventManager = m.contract("EventManager", [
    artist,
    ticket,
    organizator
  ]);

  return { artist, ticket, organizator, event, eventManager };
});

// Fonction extérieure pour écrire les adresses après déploiement
async function writeAddresses(deployedContracts: any) {
  const distDir = "dist";
  if (!fs.existsSync(distDir)) {
    fs.mkdirSync(distDir);
  }

  const addresses = {
    artist: deployedContracts.artist.address,
    ticket: deployedContracts.ticket.address,
    organizator: deployedContracts.organizator.address,
    eventManager: deployedContracts.eventManager.address,
  };

  fs.writeFileSync(`${distDir}/contract-addresses.json`, JSON.stringify(addresses, null, 2));
}

// Override de la fonction default export pour y insérer l’écriture d’adresses
export default async function (m: any) {
  const deployed = await TickethicWithEventManagerModule(m);
  await writeAddresses(deployed);
  return deployed;
}
