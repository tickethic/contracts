import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const TickethicWithEventManagerModule = buildModule("TickethicWithEventManagerModule", (m) => {
  const deployer = m.getAccount(0);

  // Déploye le contrat Artist
  const artist = m.contract("Artist");

  // Déploie le contrat Ticket avec le deployer comme propriétaire initial
  const ticket = m.contract("Ticket", [deployer]);

  // Récupère les paramètres d’organisateur et d'organisateurs initiaux
  const organizer = m.getParameter("organizer", deployer);
  const initialOrganizers = m.getParameter("initialOrganizers", [organizer]);

  // Déploie le contrat Organizator avec paramètres
  const organizator = m.contract("Organizator", [organizer, initialOrganizers]);

  // Déploie le contrat EventManager, qui gérera la création dynamique des events
  const eventManager = m.contract("EventManager", [artist, ticket, organizator]);

  // Seuls ces contrats sont déployés ici, le contrat Event sera créé dynamiquement par EventManager

  return { artist, ticket, organizator, eventManager };
});

export default TickethicWithEventManagerModule;
