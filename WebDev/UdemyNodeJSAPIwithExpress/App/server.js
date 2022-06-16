//Run npm install express dotenv
//Run npm install --save-dev nodemon
//Bring in the morgan logging module: npm install morgan
//npm install mongoose@5.13.4
//for formatting the console text: npm install colors
//npm install jsonwebtoken bcryptjs
//npm install cookie-parser
//npm install express-mongo-sanitize
//npm install helmet
//npm install xss-clean
//npm install express-rate-limit
//npm install hpp
//npm install cors
//for slug middleware run npm install slugify
//Modify the scripts part in package.json
//To test in dev run npm run dev
//For prod run npm start

//Example call with query Invoke-RestMethod -Uri 'http://localhost:5000/api/v1/bootcamps?careers[in]=Business&select=name,description&sort=name&limit=2&page=2'

const express = require('express');
const dotenv = require('dotenv');
const logger = require('./middleware/logger');
const morgan = require('morgan');
const connectDB = require('./db');
const colors = require('colors');
const cookieParser = require('cookie-parser');
const mongoSanitize = require('express-mongo-sanitize');
const helmet = require('helmet');
const xss = require('xss-clean');
const rateLimit = require('express-rate-limit');
const hpp = require('hpp');
const cors = require('cors');
const errorHandler = require('./middleware/error')

//Routes
const bootcamps = require('./routes/bootcamps');
const courses = require('./routes/courses');
const auth = require('./routes/auth');
const users = require('./routes/users');
const reviews = require('./routes/reviews');

//Load env file
dotenv.config({path: './config/config.env'});
const PORT = process.env.PORT || 5000;

//Connect to DB
connectDB();

const app = express();

//Use body parser middleware for http json data
app.use(express.json());

app.use(cookieParser());

//Load an example middleware
//app.use(logger);
if (process.env.NODE_ENV === 'development') {
    app.use(morgan('dev'));
}

app.use(mongoSanitize());
app.use(helmet());
app.use(xss());
const limiter = rateLimit({
    windowMs: 10 * 60 * 1000, // 10 mins
    max: 100
  });
  app.use(limiter);
  
  // Prevent http param pollution
  app.use(hpp());
  
  // Enable CORS - to receive requests from different domains
  app.use(cors());

//Mount router to a base url
app.use('/api/v1/bootcamps', bootcamps);
app.use('/api/v1/courses', courses);
app.use('/api/v1/auth', auth);
app.use('/api/v1/users', users);
app.use('/api/v1/reviews', reviews);

app.use(errorHandler);

const server = app.listen(PORT, console.log(`Server running in ${process.env.NODE_ENV} on port ${PORT}`.yellow.bold));

//Handle unhandled rejections
process.on('unhandledRejection',(err, promise) => {
    console.log(`Error: ${err.message}`);
    server.close(() => process.exit(1));
});
