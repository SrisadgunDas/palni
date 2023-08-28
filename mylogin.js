const mysql = require('mysql2');

const connection = mysql.createConnection({
  host: '54.205.230.217',
  user: 'root',
  password: 'simplepassword',
  database: 'testdatabase'
});

connection.connect(err => {
  if (err) {
    console.error('Error connecting to MySQL:', err);
    return;
  }

  console.log('Connected to MySQL');

  // Perform your SQL query here
  const query = 'SELECT * FROM sadgun';
  connection.query(query, (error, results) => {
    if (error) {
      console.error('Error executing query:', error);
      connection.end();
      return;
    }

    console.log('Query results:', results);

    connection.end();
  });
});
