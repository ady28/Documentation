const mongoose = require('mongoose');

const connectDB = async () => {
 const conn = await mongoose.connect(process.env.MONGO_URI, {
    useNewUrlParser: true,
    useCreateIndex: true,
    useFindAndModify: false,
    useUnifiedTopology: true
 });

 console.log(`MongoDB connected to ${conn.connection.host}`.cyan);
};

module.exports = connectDB