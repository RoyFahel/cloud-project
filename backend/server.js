const express = require('express');
const cors = require('cors');
const connectToMongoDB = require('./config/database');
const mongoose = require('mongoose');


const customerRoutes = require('./routes/customers');
const groupRoutes = require('./routes/groups');
const productRoutes = require('./routes/products');
const orderRoutes = require('./routes/orders');

const app = express();
const PORT = process.env.PORT ||  8080;

// CORS configuration
const corsOptions = {
  origin: [
    'http://roy-frontend-website.s3-website.eu-north-1.amazonaws.com',
    'http://localhost:3000',
    'http://localhost:8080',
    'http://127.0.0.1:3000'
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept']
};

app.use(cors(corsOptions));
app.options('*', cors(corsOptions));

// Additional CORS headers as fallback
app.use((req, res, next) => {
  const origin = req.headers.origin;
  const allowedOrigins = [
    'http://roy-frontend-website.s3-website.eu-north-1.amazonaws.com',
    'http://localhost:3000',
    'http://localhost:8080',
    'http://127.0.0.1:3000'
  ];
  
  if (allowedOrigins.includes(origin)) {
    res.header('Access-Control-Allow-Origin', origin);
  }
  
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept');
  res.header('Access-Control-Allow-Credentials', 'true');
  
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

app.use(express.json());

app.use('/api/customers', customerRoutes);
app.use('/api/groups', groupRoutes);
app.use('/api/products', productRoutes);
app.use('/api/orders', orderRoutes);



connectToMongoDB().then(() => {
  app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
  });
});
app.get('/', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'fitx API Server is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    endpoints: [
      '/health',
      '/db-info',
      '/api/customers',
      '/api/groups',
      '/api/products',
      '/api/orders'
    ]
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'fitx Server is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});
app.get('/db-info', (req, res) => {
  const uri = process.env.MONGO_URI || 'mongodb://localhost:27017/fitx';
  res.json({
    environment: process.env.NODE_ENV || 'development'
  });
});

process.on('SIGINT', async () => {
  await mongoose.connection.close();
  process.exit(0);
});
