const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs');
const axios = require('axios');

const app = express();
const PORT = 5000;
const SECRET_KEY = 'oussema_key_benslimene_key';

app.use(cors());
app.use(bodyParser.json());

const jsonServerUrl = 'http://localhost:3000'

// Read and Write users data
const getData = () => {
  const data = fs.readFileSync('users.json');
  return JSON.parse(data);
};

const writeData = (data) => {
  fs.writeFileSync('users.json', JSON.stringify(data, null, 2));
};

// Register route
app.post('/register', (req, res) => {
  const { username, password } = req.body;

  const data = getData();
  const existingUser = data.users.find(user => user.username === username);

  if (existingUser) {
    return res.status(400).json({ message: 'User already exists' });
  }

  const hashedPassword = bcrypt.hashSync(password, 10);
  const newUser = { id: Date.now(), username, password: hashedPassword };

  data.users.push(newUser);
  writeData(data);

  const token = jwt.sign({ id: newUser.id }, SECRET_KEY, { expiresIn: '1h' });
  res.status(201).json({ message: 'User registered successfully', token });
});

// Login route
app.post('/login', (req, res) => {
  const { username, password } = req.body;

  const data = getData();
  const user = data.users.find(user => user.username === username);

  if (!user) {
    return res.status(400).json({ message: 'User not found' });
  }

  const isMatch = bcrypt.compareSync(password, user.password);

  if (!isMatch) {
    return res.status(400).json({ message: 'Invalid credentials' });
  }

  const token = jwt.sign({ id: user.id }, SECRET_KEY, { expiresIn: '1h' });
  res.status(200).json({ message: 'Login successful', token });
});

// Middleware to check JWT token
const verifyToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];

  // Check if the Authorization header exists and starts with "Bearer "
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(403).json({ message: 'Token is required' });
  }

  // Extract the token from the header
  const token = authHeader.split(' ')[1];

  jwt.verify(token, SECRET_KEY, (err, decoded) => {
    if (err) {
      return res.status(403).json({ message: 'Invalid or expired token' });
    }
    req.user = decoded;
    next();
  });
};

app.get('/classes', verifyToken, async (req, res) => {
    try {
      const response = await axios.get(`${jsonServerUrl}/classes`);
      res.json(response.data);
    } catch (error) {
      console.log(error)
      res.status(500).send('Error fetching classes');
    }
  });
  
  app.post('/classes', verifyToken, async (req, res) => {
    try {
      const response = await axios.post(`${jsonServerUrl}/classes`, req.body);
      res.status(201).json(response.data);
    } catch (error) {
      res.status(500).send('Error creating class');
    }
  });
  
  app.put('/classes/:id', verifyToken, async (req, res) => {
    try {
      const response = await axios.put(
        `${jsonServerUrl}/classes/${req.params.id}`,
        req.body
      );
      res.json(response.data);
    } catch (error) {
      res.status(500).send('Error updating class');
      
    }
  });
  
  app.delete('/classes/:id', verifyToken, async (req, res) => {
    try {
      await axios.delete(`${jsonServerUrl}/classes/${req.params.id}`);
     
      res.status(204).send();
    } catch (error) {
      res.status(500).send('Error deleting class');
    }
  });

  // Sessions CRUD
app.get('/sessions', verifyToken, async (req, res) => {
  try {
    const response = await axios.get(`${jsonServerUrl}/sessions`);
    res.json(response.data);
  } catch (error) {
    res.status(500).send('Error fetching sessions');
  }
});

app.post('/sessions', verifyToken, async (req, res) => {
  try {
    const response = await axios.post(`${jsonServerUrl}/sessions`, req.body);
    res.status(201).json(response.data);
  } catch (error) {
    res.status(500).send('Error creating session');
  }
});

app.put('/sessions/:id', verifyToken, async (req, res) => {
  try {
    const response = await axios.put(`${jsonServerUrl}/sessions/${req.params.id}`, req.body);
    res.json(response.data);
  } catch (error) {
    res.status(500).send('Error updating session');
  }
});

app.delete('/sessions/:id', verifyToken, async (req, res) => {
  try {
    await axios.delete(`${jsonServerUrl}/sessions/${req.params.id}`);
    res.status(204).send();
  } catch (error) {
    res.status(500).send('Error deleting session');
  }
});

// Teachers CRUD
app.get('/teachers', verifyToken, async (req, res) => {
  try {
    const response = await axios.get(`${jsonServerUrl}/teachers`);
    res.json(response.data);
  } catch (error) {
    res.status(500).send('Error fetching teachers');
  }
});

app.post('/teachers', verifyToken, async (req, res) => {
  try {
    const response = await axios.post(`${jsonServerUrl}/teachers`, req.body);
    res.status(201).json(response.data);
  } catch (error) {
    res.status(500).send('Error creating teacher');
  }
});

app.put('/teachers/:id', verifyToken, async (req, res) => {
  try {
    const response = await axios.put(`${jsonServerUrl}/teachers/${req.params.id}`, req.body);
    res.json(response.data);
  } catch (error) {
    res.status(500).send('Error updating teacher');
  }
});

app.delete('/teachers/:id', verifyToken, async (req, res) => {
  try {
    await axios.delete(`${jsonServerUrl}/teachers/${req.params.id}`);
    res.status(204).send();
  } catch (error) {
    res.status(500).send('Error deleting teacher');
  }
});

// Rooms CRUD
app.get('/rooms', verifyToken, async (req, res) => {
  try {
    const response = await axios.get(`${jsonServerUrl}/rooms`);
    res.json(response.data);
  } catch (error) {
    res.status(500).send('Error fetching rooms');
  }
});

app.post('/rooms', verifyToken, async (req, res) => {
  try {
    const response = await axios.post(`${jsonServerUrl}/rooms`, req.body);
    res.status(201).json(response.data);
  } catch (error) {
    res.status(500).send('Error creating room');
  }
});

app.put('/rooms/:id', verifyToken, async (req, res) => {
  try {
    const response = await axios.put(`${jsonServerUrl}/rooms/${req.params.id}`, req.body);
    res.json(response.data);
  } catch (error) {
    res.status(500).send('Error updating room');
  }
});

app.delete('/rooms/:id', verifyToken, async (req, res) => {
  try {
    await axios.delete(`${jsonServerUrl}/rooms/${req.params.id}`);
    res.status(204).send();
  } catch (error) {
    res.status(500).send('Error deleting room');
  }
});

// Subjects CRUD
app.get('/subjects', verifyToken, async (req, res) => {
  try {
    const response = await axios.get(`${jsonServerUrl}/subjects`);
    res.json(response.data);
  } catch (error) {
    res.status(500).send('Error fetching subjects');
  }
});

app.post('/subjects', verifyToken, async (req, res) => {
  try {
    const response = await axios.post(`${jsonServerUrl}/subjects`, req.body);
    res.status(201).json(response.data);
  } catch (error) {
    res.status(500).send('Error creating subject');
  }
});

app.put('/subjects/:id', verifyToken, async (req, res) => {
  try {
    const response = await axios.put(`${jsonServerUrl}/subjects/${req.params.id}`, req.body);
    res.json(response.data);
  } catch (error) {
    res.status(500).send('Error updating subject');
  }
});

app.delete('/subjects/:id', verifyToken, async (req, res) => {
  try {
    await axios.delete(`${jsonServerUrl}/subjects/${req.params.id}`);
    res.status(204).send();
  } catch (error) {
    res.status(500).send('Error deleting subject');
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
