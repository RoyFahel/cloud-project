const Group = require('../models/Group');

class GroupService {
  static async getAllGroups() {
    try {
      const groups = await Group.find({ isDeleted: false })
        .sort({ createdAt: -1 });
      return { groups: groups || [], count: groups ? groups.length : 0 };
    } catch (error) {
      console.error('❌ Error in GroupService.getAllGroups:', error);
      return { groups: [], count: 0 };
    }
  }

  static async getGroupById(id) {
    return await Group.findOne({ _id: id, isDeleted: false });
  }

  static async createGroup(groupData) {
    try {
      console.log('🔍 Creating group with data:', groupData);
      
      if (!groupData.groupName) {
        throw new Error('Group name is required');
      }
      
      const newGroup = new Group(groupData);
      const saved = await newGroup.save();
      return saved;
    } catch (error) {
      console.error('❌ Error in createGroup service:', error.message);
      throw error;
    }
  }

  static async updateGroup(id, groupData) {
    return await Group.findByIdAndUpdate(
      id,
      { ...groupData, updatedAt: new Date() },
      { new: true, runValidators: true }
    );
  }

  static async deleteGroup(id) {
    // Soft delete
    return await Group.findByIdAndUpdate(
      id,
      { isDeleted: true },
      { new: true }
    );
  }
}

module.exports = GroupService;