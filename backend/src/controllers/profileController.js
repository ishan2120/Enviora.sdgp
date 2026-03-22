const db = require('../config/database');

// @desc    Get user profile
const getUserProfile = async (req, res) => {
    try {
        const userId = 1;

        // Fetch user without password
        const [users] = await db.query(
            'SELECT id, name, email, points, language_preference FROM users WHERE id = ?',
            [userId]
        );

        if (users.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        res.json(users[0]);
    } catch (error) {
        console.error('Get profile error:', error);
        res.status(500).json({ message: 'Server error fetching profile' });
    }
};

// @desc    Update user profile
const updateUserProfile = async (req, res) => {
    try {
        const userId = req.user.userId;
        const { name, email, language_preference } = req.body;

        // Fetch user
        const [users] = await db.query('SELECT * FROM users WHERE id = ?', [userId]);

        if (users.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Check if new email belongs to someone else
        if (email && email !== users[0].email) {
            const [existingEmail] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
            if (existingEmail.length > 0) {
                return res.status(400).json({ message: 'Email is already in use' });
            }
        }

        // Update user
        await db.query(
            'UPDATE users SET name = ?, email = ?, language_preference = ? WHERE id = ?',
            [
                name || users[0].name,
                email || users[0].email,
                language_preference || users[0].language_preference,
                userId
            ]
        );

        res.json({ message: 'Profile updated successfully' });
    } catch (error) {
        console.error('Update profile error:', error);
        res.status(500).json({ message: 'Server error updating profile' });
    }
};

module.exports = {
    getUserProfile,
    updateUserProfile
};
