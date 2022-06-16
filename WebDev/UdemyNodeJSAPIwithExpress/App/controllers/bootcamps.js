const ErrorResponse = require('../utils/errorResponse');
const asyncHandler = require('../middleware/async');
const Bootcamp = require('../models/Bootcamp');

exports.getBootcamps = asyncHandler(async (req, res, next) => {
    res.status(200).json(res.advancedResults);
});
exports.getBootcamp = asyncHandler(async (req, res, next) => {
    const bootcamp = await Bootcamp.findById(req.params.id);

    if (!bootcamp) {
        return next(new ErrorResponse('Resource not found', 404));
    }

    res.status(200).json({
        success: true,
        data: bootcamp
    });
});
exports.createBootcamp = asyncHandler(async (req, res, next) => {
    req.body.user = req.user.id;
    
    const publishedBootcamp = await Bootcamp.findOne({ user: req.user.id });
    if (publishedBootcamp && req.user.role !== 'admin') {
        return next(
          new ErrorResponse(
            `The user with ID ${req.user.id} has already published a bootcamp`,
            400
          )
        );
    };

    const bootcamp = await Bootcamp.create(req.body);

    res.status(201).json({
        success: true,
        data: bootcamp
    });
});
exports.updateBootcamp = asyncHandler(async (req, res, next) => {
    let bootcamp = await Bootcamp.findById(req.params.id);

  if (!bootcamp) {
    return next(
      new ErrorResponse(`Bootcamp not found with id of ${req.params.id}`, 404)
    );
  }

  // Make sure user is bootcamp owner
  if (bootcamp.user.toString() !== req.user.id && req.user.role !== 'admin') {
    return next(
      new ErrorResponse(
        `User ${req.user.id} is not authorized to update this bootcamp`,
        401
      )
    );
  }

  bootcamp = await Bootcamp.findByIdAndUpdate(req.params.id, req.body, {
    new: true,
    runValidators: true
  });

  res.status(200).json({ success: true, data: bootcamp });
});
exports.deleteBootcamp = asyncHandler(async (req, res, next) => {
    const bootcamp = await Bootcamp.findById(req.params.id);

    if (!bootcamp) {
        return next(new ErrorResponse('Resource not found', 404));
    }

    if (bootcamp.user.toString() !== req.user.id && req.user.role !== 'admin') {
        return next(
          new ErrorResponse(
            `User ${req.user.id} is not authorized to delete this bootcamp`,
            401
          )
        );
      };

    bootcamp.remove();

    res.status(200).json({
        success: true,
        data: {}
    });
});