const express = require('express');

const { getBootcamp,
        getBootcamps,
        createBootcamp, 
        updateBootcamp, 
        deleteBootcamp 
    } = require('../controllers/bootcamps');

const Bootcamp = require('../models/Bootcamp');

const courseRouter = require('./courses');
const reviewRouter = require('./reviews');
const router = express.Router();

const { protect, authorize } = require('../middleware/auth');

const advancedResults = require('../middleware/advancedResults');

router.use('/:bootcampId/courses', courseRouter);
router.use('/:bootcampId/reviews', reviewRouter);

router.route('/').get(advancedResults(Bootcamp, 'courses'), getBootcamps).post(protect, authorize('publisher','admin'), createBootcamp);
router.route('/:id').get(getBootcamp).put(protect, updateBootcamp).delete(protect, authorize('admin'), deleteBootcamp);

module.exports  = router;