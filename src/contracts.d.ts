type Contracts = Record<string, string>

export type DeploymentData = {
    timestamp: string
    network: {
        chainId: number
        name: string
    }
    deployer: string
    contracts: Contracts
}
