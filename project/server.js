const express = require('express');
const mysql = require('mysql2/promise');
const bodyParser = require('body-parser');
const AWS = require('aws-sdk');

const app = express();
app.use(bodyParser.json());
app.use(express.static('public'));

AWS.config.update({ region: 'ap-south-1' });
const secretsManager = new AWS.SecretsManager();
const RDS_ENDPOINT = "terraform-20250714082742451200000003.ctyecwcuc4c7.ap-south-1.rds.amazonaws.com";

async function getDbConnection() {
    try {
        const secretData = await secretsManager.getSecretValue({
            SecretId: "rds-11" // ✅ Make sure this secret exists
        }).promise();

        const { username, password } = JSON.parse(secretData.SecretString);

        return mysql.createConnection({
            host: RDS_ENDPOINT,
            user: username,
            password: password,
            database: "mydb"
        });
    } catch (err) {
        console.error("❌ Failed to retrieve secrets or connect to DB:", err.message);
        throw err;
    }
}

async function initializeDatabase() {
    try {
        const db = await getDbConnection();

        await db.execute(`
            CREATE TABLE IF NOT EXISTS items (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                description TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);

        console.log("✅ Database table initialized");
        await db.end();
    } catch (err) {
        console.error("❌ Initialization error:", err.message);
        process.exit(1);
    }
}

// API: Get all items
app.get('/api/items', async (req, res) => {
    try {
        const db = await getDbConnection();
        const [rows] = await db.query('SELECT * FROM items');
        await db.end();
        res.json(rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Database error' });
    }
});

// API: Add item
app.post('/api/items', async (req, res) => {
    try {
        const { name, description } = req.body;
        const db = await getDbConnection();
        const [result] = await db.execute(
            'INSERT INTO items (name, description) VALUES (?, ?)',
            [name, description]
        );
        await db.end();
        res.status(201).json({ id: result.insertId });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to create item' });
    }
});

// API: Delete item
app.delete('/api/items/:id', async (req, res) => {
    try {
        const db = await getDbConnection();
        await db.execute('DELETE FROM items WHERE id = ?', [req.params.id]);
        await db.end();
        res.status(204).end();
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to delete item' });
    }
});

// Frontend
app.get('/', (req, res) => {
    res.send(`
    <!DOCTYPE html>
    <html>
    <head>
        <title>Items Manager</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
        <div class="container mt-5">
            <h1>Items Management</h1>
            <div class="card my-4">
                <div class="card-body">
                    <h5 class="card-title">Add New Item</h5>
                    <form id="itemForm">
                        <div class="mb-3">
                            <input type="text" class="form-control" id="itemName" placeholder="Item name" required>
                        </div>
                        <div class="mb-3">
                            <textarea class="form-control" id="itemDesc" placeholder="Description"></textarea>
                        </div>
                        <button type="submit" class="btn btn-primary">Add Item</button>
                    </form>
                </div>
            </div>

            <table class="table">
                <thead>
                    <tr><th>ID</th><th>Name</th><th>Description</th><th>Actions</th></tr>
                </thead>
                <tbody id="itemsTable"></tbody>
            </table>
        </div>

        <script>
            async function loadItems() {
                const response = await fetch('/api/items');
                const items = await response.json();
                const table = document.getElementById('itemsTable');
                table.innerHTML = items.map(item => \`
                    <tr>
                        <td>\${item.id}</td>
                        <td>\${item.name}</td>
                        <td>\${item.description || ''}</td>
                        <td>
                            <button class="btn btn-danger" onclick="deleteItem(\${item.id})">Delete</button>
                        </td>
                    </tr>
                \`).join('');
            }

            document.getElementById('itemForm').addEventListener('submit', async (e) => {
                e.preventDefault();
                const name = document.getElementById('itemName').value;
                const description = document.getElementById('itemDesc').value;

                await fetch('/api/items', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ name, description })
                });

                document.getElementById('itemForm').reset();
                loadItems();
            });

            async function deleteItem(id) {
                if (confirm('Are you sure?')) {
                    await fetch(\`/api/items/\${id}\`, { method: 'DELETE' });
                    loadItems();
                }
            }

            loadItems();
        </script>
    </body>
    </html>
    `);
});

// Unhandled error handler
process.on('unhandledRejection', (reason) => {
    console.error('Unhandled Rejection:', reason);
});

// Start server
const PORT = 3000;
initializeDatabase().then(() => {
    app.listen(PORT, () => {
        console.log(`🚀 Server running on http://localhost:${PORT}`);
    });
});
