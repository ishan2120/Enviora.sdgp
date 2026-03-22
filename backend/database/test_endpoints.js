const http = require('http');

const baseURL = 'http://localhost:5000/api';

async function fetchJSON(url, options = {}) {
    return new Promise((resolve, reject) => {
        const req = http.request(url, options, (res) => {
            let data = '';
            res.on('data', chunk => { data += chunk; });
            res.on('end', () => {
                try {
                    resolve({ status: res.statusCode, data: JSON.parse(data) });
                } catch (e) {
                    resolve({ status: res.statusCode, data });
                }
            });
        });

        req.on('error', error => reject(error));

        if (options.body) {
            req.write(options.body);
        }
        req.end();
    });
}

(async () => {
    try {
        console.log('--- ENVORIA API TESTS ---\n');

        // 1. Create a dynamic test user
        const email = `testuser_${Date.now()}@example.com`;
        console.log(`[1] Registering User (${email})...`);

        const registerBody = JSON.stringify({
            name: 'Test Setup User',
            email: email,
            password: 'password123'
        });

        const regRes = await fetchJSON(`${baseURL}/auth/register`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(registerBody)
            },
            body: registerBody
        });
        console.log('Register Response:', regRes.data);


        // 2. Login User
        console.log('\n[2] Logging In...');
        const loginBody = JSON.stringify({
            email: email,
            password: 'password123'
        });

        const loginRes = await fetchJSON(`${baseURL}/auth/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(loginBody)
            },
            body: loginBody
        });
        console.log('Login Response:', loginRes.data);

        const token = loginRes.data.token;
        if (!token) throw new Error('No token received!');

        // 3. Fetch Profile
        console.log('\n[3] Fetching Profile...');
        const profileRes = await fetchJSON(`${baseURL}/profile`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        console.log('Profile Response:', profileRes.data);

        // 4. Add Activity
        console.log('\n[4] Adding an Activity...');
        const activityBody = JSON.stringify({
            action_type: 'Recycled Plastic Bottles',
            points_earned: 50
        });

        const addActivityRes = await fetchJSON(`${baseURL}/activities`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`,
                'Content-Length': Buffer.byteLength(activityBody)
            },
            body: activityBody
        });
        console.log('Add Activity Response:', addActivityRes.data);


        // 5. Check Notifications
        console.log('\n[5] Adding & Fetching Notification...');
        const notifBody = JSON.stringify({
            message: 'Welcome to Enviora! You just earned 50 points.'
        });

        await fetchJSON(`${baseURL}/notifications`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`,
                'Content-Length': Buffer.byteLength(notifBody)
            },
            body: notifBody
        });

        const getNotifRes = await fetchJSON(`${baseURL}/notifications`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });

        console.log('Notifications:', getNotifRes.data);

        console.log('\n✅ All tests completed successfully!');

    } catch (err) {
        console.error('Test Failed:', err);
    }
})();
