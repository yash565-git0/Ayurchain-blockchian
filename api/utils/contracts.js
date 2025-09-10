const { ethers } = require('ethers');
const fs = require('fs');
const path = require('path');

// Contract addresses (from .env file)
const CONTRACT_ADDRESSES = {
  PRODUCT_REGISTRY: process.env.PRODUCT_REGISTRY_ADDRESS,
  PROVENANCE_TRACKER: process.env.PROVENANCE_TRACKER_ADDRESS,
  QUALITY_ASSURANCE: process.env.QUALITY_ASSURANCE_ADDRESS,
  OWNERSHIP_TRACKER: process.env.OWNERSHIP_TRACKER_ADDRESS
};

// Helper functions
const formatContractError = (error) => {
  if (error.reason) {
    return error.reason;
  }
  if (error.data && error.data.message) {
    return error.data.message;
  }
  return error.message || 'Unknown contract error';
};

const waitForTransaction = async (tx, confirmations = 1) => {
  console.log(`⏳ Waiting for transaction: ${tx.hash}`);
  const receipt = await tx.wait(confirmations);
  console.log(`✅ Transaction confirmed: ${tx.hash}`);
  return receipt;
};

// Provider setup
const getProvider = () => {
  const rpcUrl = process.env.RPC_URL || 'http://localhost:8545';
  return new ethers.JsonRpcProvider(rpcUrl);
};

// Wallet setup (for contract interactions that require signing)
const getSigner = () => {
  const provider = getProvider();
  const privateKey = process.env.PRIVATE_KEY;
  
  if (!privateKey) {
    throw new Error('Private key not provided in environment variables');
  }
  
  return new ethers.Wallet(privateKey, provider);
};

// Mock contract function for now
const getContract = (contractName, needsSigner = false) => {
  // Return mock object until contracts are fully configured
  return {
    registerProduct: async () => ({ hash: 'mock_tx_hash', wait: async () => ({ blockNumber: 12345 }) }),
    getProduct: async () => ({ productId: 'mock', productName: 'Mock Product' }),
    verifyProduct: async () => true
  };
};

module.exports = {
  CONTRACT_ADDRESSES,
  getProvider,
  getSigner,
  getContract,
  formatContractError,
  waitForTransaction
};
