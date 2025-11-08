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
        process.exit(1);
    });
