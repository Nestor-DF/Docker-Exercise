const express = require('express');
const cors = require('cors');
const { MongoClient, ObjectId } = require('mongodb');

const app = express();
const PORT = 4000;

// URL de Mongo: usamos el nombre del contenedor "mongo"
const MONGO_URL = process.env.MONGO_URL || 'mongodb://mongo:27017';
const DB_NAME = 'mi_basedatos';

app.use(cors());
app.use(express.json());

let db;
let itemsCollection;

// Conectar a MongoDB
async function connectMongo() {
    const client = new MongoClient(MONGO_URL);
    await client.connect();
    db = client.db(DB_NAME);
    itemsCollection = db.collection('items');
    console.log('Conectado a MongoDB');
}

// Rutas simples

// Obtener todos los items
app.get('/items', async (req, res) => {
    try {
        const items = await itemsCollection.find().toArray();
        res.json(items);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error obteniendo items' });
    }
});

// Crear un item nuevo
app.post('/items', async (req, res) => {
    try {
        const { texto } = req.body;
        if (!texto) {
            return res.status(400).json({ error: 'El campo "texto" es obligatorio' });
        }

        const result = await itemsCollection.insertOne({ texto });
        res.status(201).json({ _id: result.insertedId, texto });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error creando item' });
    }
});

// Eliminar un item
app.delete('/items/:id', async (req, res) => {
    try {
        const id = req.params.id;
        await itemsCollection.deleteOne({ _id: new ObjectId(id) });
        res.json({ ok: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error eliminando item' });
    }
});

// Arrancar servidor SOLO después de conectarse a Mongo
connectMongo()
    .then(() => {
        app.listen(PORT, () => {
            console.log(`Backend escuchando en http://0.0.0.0:${PORT}`);
        });
    })
    .catch((err) => {
        console.error('Error conectando a MongoDB:', err);
        process.exit(1);
    });
