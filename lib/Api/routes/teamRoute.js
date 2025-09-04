const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/authMiddleware');
const teamController = require('../controllers/teamController');

router.post('/teamAdd', verifyToken, teamController.teamAdd);
router.delete('/teamDelete', verifyToken, teamController.teamDelete);
router.get('/', verifyToken, teamController.listTeams);


module.exports = router;
