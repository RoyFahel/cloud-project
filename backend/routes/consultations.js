const express = require('express');
const router = express.Router();
const ConsultationController = require('../controllers/consultationController');

// GET /api/consultations - Get all consultations
router.get('/', ConsultationController.getAllConsultations);

// GET /api/consultations/:id - Get consultation by ID
router.get('/:id', ConsultationController.getConsultationById);

// POST /api/consultations - Create new consultation
router.post('/', ConsultationController.createConsultation);

// PUT /api/consultations/:id - Update consultation
router.put('/:id', ConsultationController.updateConsultation);

// DELETE /api/consultations/:id - Delete consultation
router.delete('/:id', ConsultationController.deleteConsultation);

module.exports = router;
