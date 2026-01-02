import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import hre from "hardhat";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function main() {
    const networkName = (hre.network as any).name;
    const connection = await hre.network.connect();

    let chainId: number;
    try {
        // Try to get chainId from the provider
        const chainIdHex = await connection.provider.request({ method: "eth_chainId" }) as string;
        chainId = parseInt(chainIdHex, 16);
    } catch (error) {
        console.warn("Could not get chainId from provider, falling back to config. Error:", error);
        // Fallback if provider fails or if it's not available immediately
        const networkConfig = hre.config.networks[networkName];
        if (networkConfig && networkConfig.chainId) {
            chainId = networkConfig.chainId;
        } else {
            // Default to 31337 for hardhat/localhost if not specified
            chainId = 31337;
        }
    }

    console.log(`Generating contract addresses for network: ${networkName} (Chain ID: ${chainId})`);

    const ignitionDir = path.join(__dirname, "../ignition/deployments");
    const chainDir = `chain-${chainId}`;
    const deployedAddressesPath = path.join(ignitionDir, chainDir, "deployed_addresses.json");

    if (!fs.existsSync(deployedAddressesPath)) {
        console.error(`Error: Could not find deployed_addresses.json at ${deployedAddressesPath}`);
        console.error("Make sure you have deployed the contracts using Hardhat Ignition first.");
        process.exit(1);
    }

    const deployedAddresses = JSON.parse(fs.readFileSync(deployedAddressesPath, "utf8"));

    // Ensure dist directory exists
    const distDir = path.join(__dirname, "../dist");
    if (!fs.existsSync(distDir)) {
        fs.mkdirSync(distDir);
    }

    const outputPath = path.join(distDir, "contract-addresses.json");

    // Ignition outputs "Module#Contract". We want just "Contract".
    const formattedAddresses: Record<string, string> = {};
    for (const [key, value] of Object.entries(deployedAddresses)) {
        const contractName = key.split("#")[1] || key;
        formattedAddresses[contractName] = value as string;
    }

    fs.writeFileSync(outputPath, JSON.stringify(formattedAddresses, null, 2));
    console.log(`Successfully generated ${outputPath}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
