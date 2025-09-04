const db = require('../db');

const exec = async (sql, params=[]) => {
  const result = await db.query(sql, params);
  return Array.isArray(result) && Array.isArray(result[0]) ? result[0] : result;
};

exports.getList = async (req, res) => {
  try {
    const coachId = Number(req.params.coachId);
    if (!coachId) return res.status(400).json({ error: 'coachId required' });

    const { start, end } = req.query;

    let sql = `
      SELECT
        id,
        coach_id   AS coachId,
        title,
        description,
        start_time AS startDate,
        end_time   AS endDate,
        location,
        created_at AS createdAt,
        updated_at AS updatedAt
      FROM calender_events
      WHERE coach_id = ?
    `;
    const params = [coachId];

    if (start && end) {
      sql += `
        AND start_time < ?
        AND COALESCE(end_time, start_time) > ?
      `;
      params.push(new Date(end), new Date(start));
    }

    sql += ' ORDER BY start_time ASC';

    const rows = await exec(sql, params);
    return res.json(rows);
  } catch (err) {
    console.error('getList error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

exports.addCalender = async (req, res) => {
  try {
    const { title, description, startDate, endDate, location, coachId } = req.body;
    if (!title || !startDate || !coachId) {
      return res.status(400).json({ error: 'title, startDate, coachId are required' });
    }

    const sql = `
      INSERT INTO calender_events
        (coach_id, title, description, start_time, end_time, location)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    const params = [
      Number(coachId),
      title,
      description ?? null,
      new Date(startDate),
      endDate ? new Date(endDate) : null,
      location ?? null,
    ];

    const result = await exec(sql, params);
    const id = result.insertId ?? result?.[0]?.insertId;
    return res.status(200).json({ id });
  } catch (err) {
    console.error('addCalender error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

exports.updateCalender = async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!id) return res.status(400).json({ error: 'id required' });

    const { title, description, startDate, endDate, location, coachId } = req.body;

    const sql = `
      UPDATE calender_events
      SET title = ?, description = ?, start_time = ?, end_time = ?, location = ?, coach_id = ?
      WHERE id = ?
    `;
    const params = [
      title,
      description ?? null,
      new Date(startDate),
      endDate ? new Date(endDate) : null,
      location ?? null,
      Number(coachId),
      id,
    ];

    const result = await exec(sql, params);
    const affected = result.affectedRows ?? result?.[0]?.affectedRows ?? 0;

    if (affected > 0) {
      return res.json({ id });
    } else {
      return res.status(404).json({ error: 'Calender not found' });
    }
  } catch (err) {
    console.error('updateCalender error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

exports.deleteCalender = async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!id) return res.status(400).json({ error: 'id required' });

    const sql = 'DELETE FROM calender_events WHERE id = ?';
    const result = await exec(sql, [id]);
    const affected = result.affectedRows ?? result?.[0]?.affectedRows ?? 0;

    if (affected > 0) {
      return res.json({ message: 'Calender deleted successfully' });
    } else {
      return res.status(404).json({ error: 'Calender not found' });
    }
  } catch (err) {
    console.error('deleteCalender error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
};
