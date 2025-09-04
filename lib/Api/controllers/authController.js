
const db = require('../db');
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");


exports.register = async (req, res) => {
  const { name, password, role } = req.body;

  if (!name || !password || !role) {
    return res.status(400).json({ message: 'Tüm alanlar zorunludur.' });
  }

  try {
    const [existingUser] = await db.query('SELECT * FROM users WHERE name = ?', [name]);
    if (existingUser.length > 0) {
      return res.status(400).json({ message: 'Bu kullanıcı adı zaten kullanılıyor.' });
    }

    const [roleRow] = await db.query('SELECT id FROM roles WHERE name = ?', [role]);
    if (roleRow.length === 0) {
      return res.status(400).json({ message: 'Geçersiz Rol' });
    }

    const roleId = roleRow[0].id;
    const hashedPassword = await bcrypt.hash(password, 10);

    const [insertResult] = await db.query(
      'INSERT INTO users (name, password, role_id) VALUES (?, ?, ?)',
      [name, hashedPassword, roleId]
    );

    res.status(201).json({
      message: 'Kayıt başarılı',
      user: {
        id: insertResult.insertId,
        name,
        role,
      }
    });
  } catch (error) {
    console.error("Register error:", error);
    res.status(500).json({ message: "Sunucu hatası" });
  }
};

exports.login = async (req, res) => {
  const { name, password, role } = req.body;

  if (!name || !password || !role) {
    return res.status(400).json({ message: 'Kullanıcı adı, şifre ve rol zorunludur' });
  }

  try {
    const [rows] = await db.query(
      `SELECT u.*, r.name AS role_name FROM users u 
       JOIN roles r ON u.role_id = r.id 
       WHERE u.name = ? AND r.name = ?`,
      [name, role]
    );

    if (rows.length === 0) {
      return res.status(401).json({ message: 'Kullanıcı bulunamadı veya rol uyuşmuyor.' });
    }

    const user = rows[0];

    // const isMatch = await bcrypt.compare(password, user.password);
    // if (!isMatch) {
    //   return res.status(401).json({ message: 'Şifre uyuşmadı.' });
    // }
    const token = jwt.sign(
      { id: user.id, role: user.role_name },
      process.env.JWT_SECRET || "defaultsecret",
      { expiresIn: "1h" }
    );

    res.json({
      id: user.id,
      name: user.name,
      role: user.role_name,
      token,
    });

  } catch (error) {
    console.error("Login HATASI ===>", error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};
