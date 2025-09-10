const express = require('express');
const Joi = require('joi');
const { getContract, formatContractError, waitForTransaction } = require('../utils/contracts');

const router = express.Router();

// Validation schemas
const productSchema = Joi.object({
  productId: Joi.string().required().min(1).max(100),
  productName: Joi.string().required().min(1).max(200),
  category: Joi.string().required().min(1).max(100),
  origin: Joi.string().required().min(1).max(200),
  certifications: Joi.array().items(Joi.string().max(100)).default([]),
  ipfsHash: Joi.string().allow('').default('')
});

// Test route (working)
router.get('/test', (req, res) => {
  res.json({
    success: true,
    message: 'Blockchain API is working!',
    timestamp: new Date().toISOString()
  });
});

// Register a new product
router.post('/products/register', async (req, res) => {
  try {
    console.log('Registration request body:', req.body); // Debug log
    
    const { error, value } = productSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        details: error.details[0].message
      });
    }

    // For now, return success without blockchain interaction
    // We'll add contract interaction after fixing the basic API
    res.status(201).json({
      success: true,
      message: 'Product registered successfully (mock)',
      data: {
        productId: value.productId,
        productName: value.productName,
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    console.error('Register product error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to register product',
      error: error.message
    });
  }
});

// Get product details
router.get('/products/:productId', async (req, res) => {
  try {
    const { productId } = req.params;
    
    if (!productId) {
      return res.status(400).json({
        success: false,
        message: 'Product ID is required'
      });
    }

    // Mock response for now
    res.json({
      success: true,
      data: {
        productId,
        productName: 'Mock Product',
        manufacturer: 'Mock Manufacturer',
        category: 'Electronics',
        manufacturingDate: new Date().toISOString(),
        origin: 'Mock Factory',
        certifications: ['ISO 9001'],
        isAuthentic: true,
        exists: true
      }
    });

  } catch (error) {
    console.error('Get product error:', error);
    res.status(404).json({
      success: false,
      message: 'Product not found',
      error: error.message
    });
  }
});

// Verify product authenticity
router.get('/products/:productId/verify', async (req, res) => {
  try {
    const { productId } = req.params;
    
    res.json({
      success: true,
      data: {
        productId,
        isAuthentic: true,
        verifiedAt: new Date().toISOString()
      }
    });

  } catch (error) {
    console.error('Verify product error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to verify product',
      error: error.message
    });
  }
});

module.exports = router;
