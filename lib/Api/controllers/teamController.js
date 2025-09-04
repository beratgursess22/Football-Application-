const { json } = require('body-parser');
const db = require('../db'); 



exports.listTeams = async (req, res) => {
  const [rows] = await db.query('SELECT id, name FROM teams ORDER BY name');
  res.json(rows);
};


exports.teamAdd = async (req, res) => {
  try {
    let { name } = req.body;
    if (!name || !name.trim()) {
      return res.status(400).json({ message: "Boş alan kalmamalı" });
    }
    name = name.trim();
    
    const [exists] = await db.query('SELECT id FROM teams WHERE name = ?', [name]);
    if (exists.length > 0) {
      return res.status(409).json({ message: 'Bu isimde bir takım zaten var' });
    }

    const [result] = await db.query('INSERT INTO teams (name) VALUES (?)', [name]);
    const [rows] = await db.query('SELECT id, name FROM teams WHERE id = ?', [result.insertId]);

    return res.status(201).json({
      message: 'Takım başarıyla eklendi',
      team: rows[0],
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Sunucu hatası' });
  }
};

exports.teamDelete = async (req, res) => {
  try {
    let { name } = req.body;
    if (!name || !name.trim()) {
      return res.status(400).json({ message: "Boş bir veri silemezsiniz" });
    }
    name = name.trim();
    const [rows] = await db.query(
      'SELECT id, name FROM teams WHERE name = ?',
      [name]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Bu isimde bir takım yok.' });
    }

    const team = rows[0];
    const [result] = await db.query('DELETE FROM teams WHERE id = ?', [team.id]);
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Silinecek kayıt bulunamadı' });
    }

    return res.status(200).json({
      message: "Takım başarıyla silindi",
      team,
    });
  } catch (error) {
    console.error("teamDelete error:", error);
    return res.status(500).json({ message: "Sunucu hatası" });
  }
};

