import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const TickethicWithEventManagerModule = buildModule("TickethicWithEventManagerModule", (m) => {
  const deployer = m.getAccount(0);

  // Deploy Artist contract
  const artist = m.contract("Artist");

  // Deploy Ticket contract with deployer as initial owner
  const ticket = m.contract("Ticket", [deployer]);

  // Organizer and configuration parameters
  const organizer = m.getParameter("organizer", deployer);
  const initialOrganizers = m.getParameter("initialOrganizers", [organizer]);
  const artistIds = m.getParameter<number[]>("artistIds");
  const artistShares = m.getParameter<number[]>("artistShares");
  const eventDate = m.getParameter<number>("eventDate");
  const metadataURI = m.getParameter<string>("metadataURI");
  const ticketPrice = m.getParameter<bigint>("ticketPrice");
  const totalTickets = m.getParameter<number>("totalTickets");
  const cashOnly = m.getParameter<boolean>("cashOnly", false);
  const requiresConsent = m.getParameter<boolean>("requiresConsent", false);

  // Deploy Organizator contract with configurable initial organizers
  const organizator = m.contract("Organizator", [organizer, initialOrganizers]);

  const event = m.contract("Event", [
    artist,
    artistIds,
    artistShares,
    organizer,
    eventDate,
    metadataURI,
    ticketPrice,
    totalTickets,
    ticket,
    organizator,
    cashOnly,
    requiresConsent,
  ]);

  // Deploy EventManager
  const eventManager = m.contract("EventManager", [
    artist,
    ticket,
    organizator
  ]);

  return { artist, ticket, organizator, event, eventManager };
});

export default TickethicWithEventManagerModule;
