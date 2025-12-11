const Medicament = require('../models/Medicament');
const Malady = require('../models/Malady'); // Import to ensure model is registered

class MedicamentService {
  static async getAllMedicaments() {
    try {
      const medicaments = await Medicament.find({ isDeleted: false })
        .populate('malady_id', 'maladyName')
        .sort({ createdAt: -1 });
      return { medicaments: medicaments || [], count: medicaments ? medicaments.length : 0 };
    } catch (error) {
      console.error('❌ Error in MedicamentService.getAllMedicaments:', error);
      // Return empty array instead of throwing to prevent 500 errors
      return { medicaments: [], count: 0 };
    }
  }

  static async getMedicamentById(id) {
    return await Medicament.findOne({ _id: id, isDeleted: false })
      .populate('malady_id', 'maladyName');
  }

  static async createMedicament(medicamentData) {
    try {
      console.log('🔍 Creating medicament with data:', medicamentData);
      
      // Validate required fields
      if (!medicamentData.medicamentName) {
        throw new Error('Medicament name is required');
      }
      if (!medicamentData.malady_id) {
        throw new Error('Malady ID is required');
      }
      
      // Check if malady exists
      const malady = await Malady.findById(medicamentData.malady_id);
      if (!malady) {
        throw new Error(`Malady with ID ${medicamentData.malady_id} not found`);
      }
      
      const newMedicament = new Medicament(medicamentData);
      const saved = await newMedicament.save();
      return await Medicament.findById(saved._id).populate('malady_id', 'maladyName');
    } catch (error) {
      console.error('❌ Error in createMedicament service:', error.message);
      throw error;
    }
  }

  static async updateMedicament(id, medicamentData) {
    return await Medicament.findByIdAndUpdate(
      id,
      { ...medicamentData, updatedAt: Date.now() },
      { new: true, runValidators: true }
    ).populate('malady_id', 'maladyName');
  }

  static async deleteMedicament(id) {
    const result = await Medicament.findByIdAndUpdate(
      id,
      { isDeleted: true, updatedAt: Date.now() },
      { new: true }
    );
    return result !== null;
  }
}

module.exports = MedicamentService;