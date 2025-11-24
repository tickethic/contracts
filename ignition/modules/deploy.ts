import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const TickethicWithEventManagerModule = buildModule("TickethicWithEventManagerModule", (m) => {
  const deployer = m.getAccount(0);

  const artist = m.contract("Artist");

  const ticket = m.contract("Ticket", [deployer]);

  const organizer = m.getParameter("organizer", deployer);
  const initialOrganizers = m.getParameter("initialOrganizers", [organizer]);

  const organizator = m.contract("Organizator", [organizer, initialOrganizers]);

  const eventManager = m.contract("EventManager", [
    artist,
    ticket,
    organizator,
  ]);

  return { artist, ticket, organizator, eventManager };
});

export default TickethicWithEventManagerModule;
