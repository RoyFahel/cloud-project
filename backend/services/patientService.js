const Patient = require('../models/Patient');

class PatientService {
  static async getAllPatients() {
    try {
      const patients = await Patient.find({ isDeleted: false })
        .sort({ createdAt: -1 });
      return { patients: patients || [], count: patients ? patients.length : 0 };
    } catch (error) {
      console.error('❌ Error in PatientService.getAllPatients:', error);
      return { patients: [], count: 0 };
    }
  }

  static async getPatientById(id) {
    return await Patient.findOne({ _id: id, isDeleted: false });
  }

  static async createPatient(patientData) {
    try {
      console.log('🔍 Creating patient with data:', patientData);
      
      const newPatient = new Patient(patientData);
      const saved = await newPatient.save();
      return saved;
    } catch (error) {
      console.error('❌ Error in createPatient service:', error.message);
      throw error;
    }
  }

  static async updatePatient(id, patientData) {
    return await Patient.findByIdAndUpdate(
      id,
      { ...patientData, updatedAt: new Date() },
      { new: true, runValidators: true }
    );
  }

  static async deletePatient(id) {
    // Soft delete
    return await Patient.findByIdAndUpdate(
      id,
      { isDeleted: true },
      { new: true }
    );
  }
}

module.exports = PatientService;