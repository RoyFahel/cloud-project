const mongoose = require('mongoose');
const Product = require('./models/Product');
const Group = require('./models/Group');

// MongoDB connection string
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/fitx';

const productsData = [
  { productName: 'Whey Protein', description: 'High-quality protein for muscle growth' },
  { productName: 'Creatine Monohydrate', description: 'Boosts strength and power' },
  { productName: 'BCAA', description: 'Supports muscle recovery and reduces fatigue' },
  { productName: 'Pre-Workout', description: 'Enhances energy and focus during workouts' },
  { productName: 'Glutamine', description: 'Aids muscle recovery and immune support' },
  { productName: 'Beta-Alanine', description: 'Improves endurance and delays fatigue' },
  { productName: 'Omega-3 Fish Oil', description: 'Supports joint health and reduces inflammation' },
  { productName: 'Multivitamin', description: 'Provides essential vitamins and minerals' }
];


async function seedProducts() {
  try {
    // Connect to MongoDB
    await mongoose.connect(MONGO_URI);
    console.log('✅ Connected to MongoDB');

    // Clear existing products
    await Product.deleteMany({});
    console.log('🗑️  Cleared existing products');

    // Insert new products
    const insertedProducts = await Product.insertMany(productsData);
    console.log(`✅ Inserted ${insertedProducts.length} products:`);
    insertedProducts.forEach(product => {
      console.log(`   - ${product.productName}`);
    });

    console.log('✅ Product seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding products:', error);
    process.exit(1);
  }
}

seedProducts();
