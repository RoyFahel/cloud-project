const mongoose = require('mongoose');
const Medicament = require('./models/Medicament');
const Malady = require('./models/Malady');

// MongoDB connection string
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/pharmax';

const medicamentsData = [
  { medicamentName: 'Paracetamol', description: 'Pain reliever and fever reducer' },
  { medicamentName: 'Ibuprofen', description: 'Anti-inflammatory pain reliever' },
  { medicamentName: 'Amoxicillin', description: 'Antibiotic for bacterial infections' },
  { medicamentName: 'Aspirin', description: 'Pain reliever, anti-inflammatory' },
  { medicamentName: 'Omeprazole', description: 'Reduces stomach acid' },
  { medicamentName: 'Metformin', description: 'Diabetes medication' },
  { medicamentName: 'Lisinopril', description: 'Blood pressure medication' },
  { medicamentName: 'Atorvastatin', description: 'Cholesterol-lowering medication' }
];

async function seedMedicaments() {
  try {
    // Connect to MongoDB
    await mongoose.connect(MONGO_URI);
    console.log('✅ Connected to MongoDB');

    // Clear existing medicaments
    await Medicament.deleteMany({});
    console.log('🗑️  Cleared existing medicaments');

    // Insert new medicaments
    const insertedMedicaments = await Medicament.insertMany(medicamentsData);
    console.log(`✅ Inserted ${insertedMedicaments.length} medicaments:`);
    insertedMedicaments.forEach(medicament => {
      console.log(`   - ${medicament.medicamentName}`);
    });

    console.log('✅ Medicament seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding medicaments:', error);
    process.exit(1);
  }
}

seedMedicaments();
