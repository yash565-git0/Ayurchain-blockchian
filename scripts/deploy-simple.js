const { ethers } = require("hardhat");
const fs = require('fs');

async function main() {
  console.log("🚀 Deploying Supply Chain Contracts...");
  
  // Deploy contracts
  console.log("📋 Deploying ProductRegistry...");
  const ProductRegistry = await ethers.getContractFactory("ProductRegistry");
  const productRegistry = await ProductRegistry.deploy();
  await productRegistry.waitForDeployment();
  console.log("✅ ProductRegistry deployed to:", await productRegistry.getAddress());

  console.log("📍 Deploying ProvenanceTracker...");
  const ProvenanceTracker = await ethers.getContractFactory("ProvenanceTracker");
  const provenanceTracker = await ProvenanceTracker.deploy();
  await provenanceTracker.waitForDeployment();
  console.log("✅ ProvenanceTracker deployed to:", await provenanceTracker.getAddress());

  console.log("🔍 Deploying QualityAssurance...");
  const QualityAssurance = await ethers.getContractFactory("QualityAssurance");
  const qualityAssurance = await QualityAssurance.deploy();
  await qualityAssurance.waitForDeployment();
  console.log("✅ QualityAssurance deployed to:", await qualityAssurance.getAddress());

  console.log("👤 Deploying OwnershipTracker...");
  const OwnershipTracker = await ethers.getContractFactory("OwnershipTracker");
  const ownershipTracker = await OwnershipTracker.deploy();
  await ownershipTracker.waitForDeployment();
  console.log("✅ OwnershipTracker deployed to:", await ownershipTracker.getAddress());

  // Get addresses
  const addresses = {
    PRODUCT_REGISTRY_ADDRESS: await productRegistry.getAddress(),
    PROVENANCE_TRACKER_ADDRESS: await provenanceTracker.getAddress(),
    QUALITY_ASSURANCE_ADDRESS: await qualityAssurance.getAddress(),
    OWNERSHIP_TRACKER_ADDRESS: await ownershipTracker.getAddress()
  };

  console.log("\n📋 Contract Addresses:");
  Object.entries(addresses).forEach(([key, value]) => {
    console.log(`${key}: ${value}`);
  });

  // Update .env file
  updateEnvFile(addresses);

  console.log("\n🎉 All contracts deployed successfully!");
  return addresses;
}

function updateEnvFile(addresses) {
  try {
    let envContent = '';
    if (fs.existsSync('.env')) {
      envContent = fs.readFileSync('.env', 'utf8');
    } else {
      // Create default .env content
      envContent = `# Server Configuration
NODE_ENV=development
PORT=5000
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001

# Blockchain Configuration
RPC_URL=http://localhost:8545
CHAIN_ID=31337
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Contract Addresses
`;
    }

    // Update or add contract addresses
    Object.entries(addresses).forEach(([key, value]) => {
      const regex = new RegExp(`^${key}=.*$`, 'm');
      if (envContent.match(regex)) {
        envContent = envContent.replace(regex, `${key}=${value}`);
      } else {
        envContent += `${key}=${value}\n`;
      }
    });

    fs.writeFileSync('.env', envContent);
    console.log("✅ .env file updated with contract addresses");
  } catch (error) {
    console.error("❌ Error updating .env file:", error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
