const router = require('express').Router();
const calenderController = require('../controllers/calenderController');

router.post('/calenderAdd', calenderController.addCalender); 
router.post('/calendarAdd', calenderController.addCalender);  

router.get('/calender/:coachId', calenderController.getList);
router.put('/calenderUpdate/:id', calenderController.updateCalender);
router.delete('/calenderDelete/:id', calenderController.deleteCalender);

module.exports = router;