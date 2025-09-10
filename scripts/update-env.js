const fs = require('fs');
const path = require('path');

async function updateEnvFile() {
  try {
    // Read deployment results from Hardhat Ignition
    const deploymentDir = './ignition/deployments/chain-31337';
    const deploymentFile = path.join(deploymentDir, 'deployed_addresses.json');
    
    if (fs.existsSync(deploymentFile)) {
      const addresses = JSON.parse(fs.readFileSync(deploymentFile, 'utf8'));
      
      // Read current .env file
      let envContent = '';
      if (fs.existsSync('.env')) {
        envContent = fs.readFileSync('.env', 'utf8');
      }
      
      // Update or add contract addresses
      const updates = {
        'PRODUCT_REGISTRY_ADDRESS': addresses['SupplyChainDeployment#ProductRegistry'] || '',
        'PROVENANCE_TRACKER_ADDRESS': addresses['SupplyChainDeployment#ProvenanceTracker'] || '',
        'QUALITY_ASSURANCE_ADDRESS': addresses['SupplyChainDeployment#QualityAssurance'] || '',
        'OWNERSHIP_TRACKER_ADDRESS': addresses['SupplyChainDeployment#OwnershipTracker'] || ''
      };
      
      Object.entries(updates).forEach(([key, value]) => {
        const regex = new RegExp(`^${key}=.*$`, 'm');
        if (envContent.match(regex)) {
          envContent = envContent.replace(regex, `${key}=${value}`);
        } else {
          envContent += `\n${key}=${value}`;
        }
      });
      
      fs.writeFileSync('.env', envContent);
      console.log('✅ .env file updated with contract addresses');
      console.log('Contract addresses:');
      Object.entries(updates).forEach(([key, value]) => {
        console.log(`  ${key}: ${value}`);
      });
    }
  } catch (error) {
    console.error('Error updating .env file:', error);
  }
}

updateEnvFile();
