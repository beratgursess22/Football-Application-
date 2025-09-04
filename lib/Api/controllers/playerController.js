const db = require('../db'); 

const toInt = (v) => {
  const n = Number(v);
  return Number.isInteger(n) ? n : NaN;
};


exports.getByTeam = async (req, res) => {
  try {
    const teamId = Number(req.query.team_id);
    if (!Number.isInteger(teamId) || teamId <= 0) {
      return res.status(400).json({ message: 'Geçerli team_id gerekli' });
    }

    console.log('[getByTeam] team_id =', teamId);

    const [rows] = await db.query(
      `SELECT
      id, user_id, team_id,
      name, surname, birth_day,
      position, dominant_foot,
      height, weight, phone,
      COALESCE(jersey_number, 0) AS jersey_number,
      medical_notes, avatar_url,
      COALESCE(status,'active') AS status,
      created_at, updated_at
      FROM players
      WHERE team_id = ?;`,
      [teamId]
    );

    if (rows && rows.length > 0) {
      console.log('[getByTeam] sample row =', rows[0]);
    } else {
      console.log('[getByTeam] empty result');
    }

    return res.json(rows); // boşsa []
  } catch (error) {
    // Hata detayını TAM bas
    console.error('getByTeam error:', {
      message: error.message,
      code: error.code,
      errno: error.errno,
      sql: error.sql,
      sqlMessage: error.sqlMessage,
      stack: error.stack,
    });
    return res.status(500).json({ message: 'Oyuncular getirilemedi', detail: error.message });
  }
};



/* ---------- Oyuncuyu Takıma Ata ---------- */
exports.assignToTeam = async (req, res) => {
  try {
    const playerId = toInt(req.params.id);
    const teamId = toInt(req.body.teamId ?? req.body.team_id);

    if (Number.isNaN(playerId)) {
      return res.status(400).json({ message: 'Geçerli bir oyuncu id gerekli' });
    }
    if (Number.isNaN(teamId)) {
      return res.status(400).json({ message: 'teamId gerekli (integer)' });
    }

    const [t] = await db.query('SELECT id, name FROM teams WHERE id = ?', [teamId]);
    if (t.length === 0) {
      return res.status(404).json({ message: 'Böyle bir takım idsi yok' });
    }

    const [r] = await db.query('UPDATE players SET team_id = ? WHERE id = ?', [teamId, playerId]);
    if (r.affectedRows === 0) {
      return res.status(404).json({ message: 'Oyuncu bulunamadı' });
    }

    const [playerRows] = await db.query(
      `SELECT p.*, t.name AS team_name
       FROM players p LEFT JOIN teams t ON t.id = p.team_id
       WHERE p.id = ?`,
      [playerId]
    );

    return res.json({ success: true, player: playerRows[0] });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Atama başarısız' });
  }
};

/* ---------- Takımdan Çıkarma ---------- */
exports.removeFromTeam = async (req, res) => {
  try {
    const playerId = toInt(req.params.id);
    if (Number.isNaN(playerId)) {
      return res.status(400).json({ message: 'Geçerli bir oyuncu id gerekli' });
    }

    const [r] = await db.query('UPDATE players SET team_id = NULL WHERE id = ?', [playerId]);
    if (r.affectedRows === 0) {
      return res.status(404).json({ message: 'Oyuncu bulunamadı' });
    }

    return res.json({ success: true, player_id: playerId });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Silme başarısız' });
  }
};

/* ---------- Oyuncu Ekle ---------- */
exports.playerAdd = async (req, res) => {
  try {
    const userId = req.user?.id ?? null;
    const {
      team_id,
      name,
      surname,
      birth_day,
      position,
      dominant_foot,
      height,
      weight,
      phone,
      jersey_number,
      medical_notes,
      avatar_url,
      status
    } = req.body;

    if (!name || !surname  || !position || !dominant_foot ||
      height == null || weight == null || !phone || jersey_number == null) {
      return res.status(400).json({ error: 'Eksik alanlar var' });
    }

    const heightInt = parseInt(height, 10);
    const weightInt = parseInt(weight, 10);
    const jerseyInt = parseInt(jersey_number, 10);
    if ([heightInt, weightInt, jerseyInt].some(Number.isNaN)) {
      return res.status(400).json({ error: 'height/weight/jersey_number sayısal olmalı' });
    }

    if (typeof phone !== 'string' || phone.length === 0 || phone.length > 20) {
      return res.status(400).json({ error: 'phone zorunlu ve en fazla 20 karakter' });
    }

    const [result] = await db.query(
      `INSERT INTO players
       (user_id, team_id, name, surname, birth_day, position, dominant_foot,
        height, weight, phone, jersey_number, medical_notes, avatar_url, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        userId,
        team_id ?? null,
        name.trim(),
        surname.trim(),
        birth_day,
        String(position).trim(),
        dominant_foot,
        heightInt,
        weightInt,
        phone.trim(),
        jerseyInt,
        medical_notes ?? null,
        avatar_url ?? null,
        status ?? 'active'
      ]
    );

    return res.status(201).json({
      message: 'Oyuncu başarıyla eklendi',
      playerId: result.insertId
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: 'Sunucu hatası' });
  }
};

/* ---------- Oyuncu Sil (forma numarasına göre) ---------- */
exports.playerDelete = async (req, res) => {
  try {
    const jersey = parseInt(req.params.jersey_number, 10);
    if (Number.isNaN(jersey)) {
      return res.status(400).json({ message: 'Geçerli bir forma numarası gerekli' });
    }

    const [isValid] = await db.query('SELECT id FROM players WHERE jersey_number = ?', [jersey]);
    if (isValid.length === 0) {
      return res.status(404).json({ message: 'Kayıt bulunamadı' });
    }

    await db.query('DELETE FROM players WHERE jersey_number = ?', [jersey]);
    return res.json({ message: 'Oyuncu başarıyla silindi' });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/* ---------- Oyuncu Get (forma numarasına göre) ---------- */
exports.playerGet = async (req, res) => {
  try {
    const jersey = parseInt(req.params.jersey_number, 10);
    if (Number.isNaN(jersey)) {
      return res.status(400).json({ message: 'Geçerli bir forma numarası gerekli' });
    }

    const [rows] = await db.query(
      'SELECT * FROM players WHERE jersey_number = ?',
      [jersey]
    );
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Bu forma numarasına sahip oyuncu bulunamadı' });
    }
    return res.json(rows[0]);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: 'Sunucu hatası' });
  }
};

/* ---------- Oyuncu Güncelle (forma numarasına göre) ---------- */
exports.playerUpdate = async (req, res) => {
  try {
    const jersey = parseInt(req.params.jersey_number, 10);
    if (Number.isNaN(jersey)) {
      return res.status(400).json({ message: 'Geçerli bir forma numarası gerekli' });
    }

    const {
      team_id,
      name,
      surname,
      position,
      dominant_foot,
      height,
      weight,
      phone,
      medical_notes,
      avatar_url,
      status
    } = req.body;

    const [rows] = await db.query('SELECT id FROM players WHERE jersey_number = ?', [jersey]);
    if (rows.length === 0) {
      return res.status(404).json({ message: 'Bu forma numarasındaki oyuncu bulunamadı' });
    }

    await db.query(
      `UPDATE players SET
        team_id = ?,
        name = ?,
        surname = ?,
        position = ?,
        dominant_foot = ?,
        height = ?,
        weight = ?,
        phone = ?,
        medical_notes = ?,
        avatar_url = ?,
        status = ?
       WHERE jersey_number = ?`,
      [
        team_id ?? null,
        name,
        surname,
        position,
        dominant_foot,
        height,
        weight,
        phone,
        medical_notes ?? null,
        avatar_url ?? null,
        status ?? 'active',
        jersey
      ]
    );

    return res.json({ message: `Forma numarası ${jersey} olan oyuncu güncellendi` });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: 'Sunucu hatası' });
  }
};
