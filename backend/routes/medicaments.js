const express = require('express');
const router = express.Router();
const MedicamentController = require('../controllers/medicamentController');

// GET /api/medicaments - Get all medicaments
router.get('/', MedicamentController.getAllMedicaments);

// GET /api/medicaments/:id - Get medicament by ID
router.get('/:id', MedicamentController.getMedicamentById);

// POST /api/medicaments - Create new medicament
router.post('/', MedicamentController.createMedicament);

// PUT /api/medicaments/:id - Update medicament
router.put('/:id', MedicamentController.updateMedicament);

// DELETE /api/medicaments/:id - Delete medicament
router.delete('/:id', MedicamentController.deleteMedicament);

module.exports = router;
