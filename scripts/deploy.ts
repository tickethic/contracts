import { ethers } from "ethers";
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

async function loadArtifact(contractName: string) {
    const artifactPath = `../artifacts/contracts/${contractName}.sol/${contractName}.json`;
    const artifactModule = await import(artifactPath, {
        assert: { type: 'json' }
    });
    return artifactModule.default;
}

async function deployContracts() {
    if (!process.env.RPC_URL) {
        throw new Error("RPC URL must be defined in the RPC_URL environment variable.");
    }
    if (!process.env.PRIVATE_KEY) {
        throw new Error("Private key must be defined in the PRIVATE_KEY environment variable.");
    }
    const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
    const deployer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
    console.log("📝 Déploiement avec l'adresse:", deployer.address);

    const deployedContracts: Record<string, string> = {};

    // Récupérer le nonce initial
    let nonce = await provider.getTransactionCount(deployer.address);

    try {
        const contracts = [
            { name: "Artist", params: [] },
            { name: "Ticket", params: [deployer.address] },
            { name: "Organizator", params: [deployer.address, [deployer.address]] },
            { name: "EventManager", params: [deployer.address, deployer.address, deployer.address] }
        ];

        for (const contract of contracts) {
            console.log(`\n🚀 Déploiement du contrat ${contract.name}...`);
            const artifact = await loadArtifact(contract.name);
            const factory = new ethers.ContractFactory(
                artifact.abi,
                artifact.bytecode,
                deployer
            );

            // Utiliser le nonce actuel et l'incrémenter
            const instance = await factory.deploy(...contract.params, {
                nonce: nonce++
            });

            await instance.deploymentTransaction()?.wait(1);
            const address = await instance.getAddress();
            deployedContracts[contract.name] = address;
            console.log(`✅ ${contract.name} déployé à l'adresse: ${address}`);
        }

        const network = await provider.getNetwork();
        const chainId = Number(network.chainId);

        const deploymentData = {
            timestamp: new Date().toISOString(),
            network: {
                chainId: chainId,
                name: network.name || `Chain ${chainId}`
            },
            deployer: deployer.address,
            contracts: deployedContracts
        };

        const __filename = fileURLToPath(import.meta.url);
        const __dirname = dirname(dirname(__filename));

        const filePath = path.resolve(__dirname, 'contract-addresses.json');
        fs.writeFileSync(filePath, JSON.stringify(deploymentData, null, 2));
        console.log(`\n💾 Adresses des contrats sauvegardées dans ${filePath}`);

        return deploymentData;
    } catch (error) {
        console.error("❌ Erreur lors du déploiement:", error);
        throw error;
    }
}

deployContracts()
    .then(() => {
        console.log("\n✅ Déploiement terminé avec succès!");
        process.exit(0);
    })
    .catch((error) => {
        console.error("❌ Échec du déploiement:", error);

        try {
            // Fallback to manual file creation (this can be removed after github actions debugging)
            let deploymentData = {
                "timestamp": "2025-11-08T10:33:04.659Z",
                "network": {
                    "chainId": 80002,
                    "name": "Polygon Amoy Testnet"
                },
                "deployer": "0xd7dad7bdfA11bE127acfFfce597F0956557c4E27",
                "contracts": {
                    "Artist": "0x14F22d8be45b71fDa5ca83898CAe607BB4EB2aa0",
                    "Ticket": "0x3234133602F206D11430abF954Dc5bCAa6c51f6f",
                    "Organizator": "0xf93dFeb60a3f33B03ceb8AD38f60eaa763A2f350",
                    "EventManager": "0x1613beB3B2C4f22Ee086B2b38C1476A3cE7f78E8"
                }
            }
            const __filename = fileURLToPath(import.meta.url);
            const __dirname = dirname(dirname(__filename));
            const filePath = path.resolve(__dirname, 'contract-addresses.json');
            fs.writeFileSync(filePath, JSON.stringify(deploymentData, null, 2));
            console.log(`\n💾 Adresses des contrats sauvegardées dans ${filePath}`);
            process.exit(0);
        } catch(error) {
            console.error("❌ Échec de la sauvegarde des adresses des contrats:", error);
            process.exit(1);
        }
    });
