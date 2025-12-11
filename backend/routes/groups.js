const express = require('express');
const router = express.Router();
const GroupController = require('../controllers/groupController');

// GET /api/groups - Get all groups
router.get('/', GroupController.getAllGroups);

// GET /api/groups/:id - Get group by ID
router.get('/:id', GroupController.getGroupById);

// POST /api/groups - Create new group
router.post('/', GroupController.createGroup);

// PUT /api/groups/:id - Update group
router.put('/:id', GroupController.updateGroup);

// DELETE /api/groups/:id - Delete group
router.delete('/:id', GroupController.deleteGroup);

module.exports = router;
