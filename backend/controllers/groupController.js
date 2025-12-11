const GroupService = require('../services/groupService');

class GroupController {
  static async getAllGroups(req, res) {
    try {
      const groups = await GroupService.getAllGroups();
      res.json(groups);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get groups', message: error.message });
    }
  }

  static async getGroupById(req, res) {
    try {
      const group = await GroupService.getGroupById(req.params.id);
      if (!group) {
        return res.status(404).json({ error: 'Group not found' });
      }
      res.json(group);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get group', message: error.message });
    }
  }

  static async createGroup(req, res) {
    try {
      console.log('📝 Creating group with data:', req.body);
      const group = await GroupService.createGroup(req.body);
      console.log('✅ Group created successfully:', group);
      res.status(201).json({ group });
    } catch (error) {
      console.error('❌ Error creating group:', error.message);
      res.status(400).json({ error: 'Failed to create group', message: error.message });
    }
  }

  static async updateGroup(req, res) {
    try {
      const group = await GroupService.updateGroup(req.params.id, req.body);
      if (!group) {
        return res.status(404).json({ error: 'Group not found' });
      }
      res.json(group);
    } catch (error) {
      res.status(400).json({ error: 'Failed to update group', message: error.message });
    }
  }

  static async deleteGroup(req, res) {
    try {
      const deleted = await GroupService.deleteGroup(req.params.id);
      if (!deleted) {
        return res.status(404).json({ error: 'Group not found' });
      }
      res.json({ message: 'Group deleted successfully', id: req.params.id });
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete group', message: error.message });
    }
  }
}

module.exports = GroupController;