const express = require('express');
const router = express.Router();
const playerController = require('../controllers/playerController');
const verifyToken = require('../middleware/authMiddleware');


router.get('/', verifyToken, playerController.getByTeam);

router.get('/:jersey_number', verifyToken, playerController.playerGet);
router.put('/:jersey_number', verifyToken, playerController.playerUpdate);
router.delete('/:jersey_number', verifyToken, playerController.playerDelete);


router.post('/playerAdd', verifyToken, playerController.playerAdd);

router.put('/team/:id', verifyToken, playerController.assignToTeam);
router.delete('/team/:id', verifyToken, playerController.removeFromTeam);

module.exports = router;