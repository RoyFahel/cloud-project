const express = require('express');
const router = express.Router();
const MaladyController = require('../controllers/maladyController');

// GET /api/maladies - Get all maladies
router.get('/', MaladyController.getAllMaladies);

// GET /api/maladies/:id - Get malady by ID
router.get('/:id', MaladyController.getMaladyById);

// POST /api/maladies - Create new malady
router.post('/', MaladyController.createMalady);

// PUT /api/maladies/:id - Update malady
router.put('/:id', MaladyController.updateMalady);

// DELETE /api/maladies/:id - Delete malady
router.delete('/:id', MaladyController.deleteMalady);

module.exports = router;
