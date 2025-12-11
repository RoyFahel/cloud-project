const Malady = require('../models/Malady');

class MaladyService {
  static async getAllMaladies() {
    try {
      const maladies = await Malady.find({ isDeleted: false })
        .sort({ createdAt: -1 });
      return { maladies: maladies || [], count: maladies ? maladies.length : 0 };
    } catch (error) {
      console.error('❌ Error in MaladyService.getAllMaladies:', error);
      return { maladies: [], count: 0 };
    }
  }

  static async getMaladyById(id) {
    return await Malady.findOne({ _id: id, isDeleted: false });
  }

  static async createMalady(maladyData) {
    try {
      console.log('🔍 Creating malady with data:', maladyData);
      
      if (!maladyData.maladyName) {
        throw new Error('Malady name is required');
      }
      
      const newMalady = new Malady(maladyData);
      const saved = await newMalady.save();
      return saved;
    } catch (error) {
      console.error('❌ Error in createMalady service:', error.message);
      throw error;
    }
  }

  static async updateMalady(id, maladyData) {
    return await Malady.findByIdAndUpdate(
      id,
      { ...maladyData, updatedAt: new Date() },
      { new: true, runValidators: true }
    );
  }

  static async deleteMalady(id) {
    // Soft delete
    return await Malady.findByIdAndUpdate(
      id,
      { isDeleted: true },
      { new: true }
    );
  }
}

module.exports = MaladyService;