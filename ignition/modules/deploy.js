const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("SupplyChainDeployment", (m) => {
  // Deploy contracts
  const productRegistry = m.contract("ProductRegistry");
  const provenanceTracker = m.contract("ProvenanceTracker");
  const qualityAssurance = m.contract("QualityAssurance");
  const ownershipTracker = m.contract("OwnershipTracker");

  // Return deployed contracts for reference
  return {
    productRegistry,
    provenanceTracker,
    qualityAssurance,
    ownershipTracker
  };
});
