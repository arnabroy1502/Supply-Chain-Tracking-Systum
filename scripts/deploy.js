const { ethers } = require("hardhat");

async function main() {
  console.log("Starting deployment of Supply Chain Tracking System...");

  // Get the Contract Factory
  const SupplyChainTracker = await ethers.getContractFactory("SupplyChainTracker");
  
  // Deploy the contract
  const supplyChainTracker = await SupplyChainTracker.deploy();

  // Wait for deployment to finish
  await supplyChainTracker.deployed();

  console.log("SupplyChainTracker deployed to:", supplyChainTracker.address);
  console.log("Transaction hash:", supplyChainTracker.deployTransaction.hash);
}

// Run the deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error during deployment:", error);
    process.exit(1);
  });
