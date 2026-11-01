const http = require('http');

const PORT = 3000;
const BASE_URL = `http://localhost:${PORT}`;

function makeRequest(method, path, body = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: method,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          resolve({ status: res.statusCode, headers: res.headers, data: parsed });
        } catch {
          resolve({ status: res.statusCode, headers: res.headers, data });
        }
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

async function runTests() {
  console.log('=== Starting CRUD Endpoint Tests ===\n');

  // Wait 1.5 seconds for server to initialize
  await new Promise((r) => setTimeout(r, 1500));

  try {
    // 0. GET /
    console.log('1. Testing GET / (Root API Overview)...');
    const rootRes = await makeRequest('GET', '/');
    console.log(`Status: ${rootRes.status}`);
    console.log('Response:', JSON.stringify(rootRes.data, null, 2));

    // 1. GET /books/
    console.log('\n2. Testing GET /books/ (All Books)...');
    const allBooksRes = await makeRequest('GET', '/books/');
    console.log(`Status: ${allBooksRes.status}`);
    console.log(`Retrieved ${allBooksRes.data.length} books.`);
    console.log('Sample book:', allBooksRes.data[0]);

    // 2. GET /books/:bookId/
    console.log('\n3. Testing GET /books/3/ (Single Book - 1984)...');
    const singleBookRes = await makeRequest('GET', '/books/3/');
    console.log(`Status: ${singleBookRes.status}`);
    console.log('Book:', singleBookRes.data);

    // 3. POST /books/
    console.log('\n4. Testing POST /books/ (Add New Book)...');
    const newBook = {
      title: 'Designing Data-Intensive Applications',
      author: 'Martin Kleppmann',
      price: 1299,
      pages: 616
    };
    const postRes = await makeRequest('POST', '/books/', newBook);
    console.log(`Status: ${postRes.status}`);
    console.log('Response:', postRes.data);
    const addedBookId = postRes.data.bookId;

    // Verify added book via GET
    console.log(`\nVerifying created book (ID ${addedBookId})...`);
    const verifyAddRes = await makeRequest('GET', `/books/${addedBookId}/`);
    console.log(`Status: ${verifyAddRes.status}`);
    console.log('Book retrieved:', verifyAddRes.data);

    // 4. PUT /books/:bookId/
    console.log(`\n5. Testing PUT /books/${addedBookId}/ (Update Book)...`);
    const updatePayload = {
      title: 'Designing Data-Intensive Applications (Updated 2nd Edition)',
      author: 'Martin Kleppmann',
      price: 1450,
      pages: 650
    };
    const putRes = await makeRequest('PUT', `/books/${addedBookId}/`, updatePayload);
    console.log(`Status: ${putRes.status}`);
    console.log('Response:', putRes.data);

    // Verify update
    console.log(`\nVerifying updated book (ID ${addedBookId})...`);
    const verifyPutRes = await makeRequest('GET', `/books/${addedBookId}/`);
    console.log(`Status: ${verifyPutRes.status}`);
    console.log('Updated Book retrieved:', verifyPutRes.data);

    // 5. DELETE /books/:bookId/
    console.log(`\n6. Testing DELETE /books/${addedBookId}/ (Remove Book)...`);
    const deleteRes = await makeRequest('DELETE', `/books/${addedBookId}/`);
    console.log(`Status: ${deleteRes.status}`);
    console.log('Response:', deleteRes.data);

    // Verify deletion returns 404
    console.log(`\nVerifying deleted book is gone (ID ${addedBookId})...`);
    const verifyDeleteRes = await makeRequest('GET', `/books/${addedBookId}/`);
    console.log(`Status: ${verifyDeleteRes.status} (Expected 404)`);
    console.log('Response:', verifyDeleteRes.data);

    console.log('\n=== All Endpoint Tests Completed Successfully! ===');
    process.exit(0);
  } catch (err) {
    console.error('Test failed with error:', err);
    process.exit(1);
  }
}

runTests();
