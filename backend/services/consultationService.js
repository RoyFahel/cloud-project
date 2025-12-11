const Consultation = require('../models/Consultation');

class ConsultationService {
  static async getAllConsultations() {
    try {
      const consultations = await Consultation.find({ isDeleted: false })
        .populate('patient_id', 'firstName lastName email age gender')
        .populate('malady_id', 'maladyName')
        .populate('medicament_id', 'medicamentName')
        .sort({ createdAt: -1 });
      return { consultations: consultations || [], count: consultations ? consultations.length : 0 };
    } catch (error) {
      console.error('❌ Error in ConsultationService.getAllConsultations:', error);
      return { consultations: [], count: 0 };
    }
  }

  static async getConsultationById(id) {
    return await Consultation.findOne({ _id: id, isDeleted: false })
      .populate('patient_id', 'firstName lastName email age gender')
      .populate('malady_id', 'maladyName')
      .populate('medicament_id', 'medicamentName');
  }

  static async createConsultation(consultationData) {
    try {
      console.log('🔍 Creating consultation with data:', consultationData);
      
      const newConsultation = new Consultation(consultationData);
      const saved = await newConsultation.save();
      
      // Return populated consultation
      return await Consultation.findById(saved._id)
        .populate('patient_id', 'firstName lastName email age gender')
        .populate('malady_id', 'maladyName')
        .populate('medicament_id', 'medicamentName');
    } catch (error) {
      console.error('❌ Error in createConsultation service:', error.message);
      throw error;
    }
  }

  static async updateConsultation(id, consultationData) {
    return await Consultation.findByIdAndUpdate(
      id,
      { ...consultationData, updatedAt: new Date() },
      { new: true, runValidators: true }
    )
      .populate('patient_id', 'firstName lastName email age gender')
      .populate('malady_id', 'maladyName')
      .populate('medicament_id', 'medicamentName');
  }

  static async deleteConsultation(id) {
    return await Consultation.findByIdAndUpdate(
      id,
      { isDeleted: true },
      { new: true }
    );
  }
}

module.exports = ConsultationService;