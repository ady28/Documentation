//For dev environment use this module to restart node when the file changes: npm install --save-dev nodemon
//After installing the module go to the package.json file and replace node with nodemon in the start script section
//Use npm start to run the application

//Test by sending a request: Invoke-RestMethod -Uri 'http://localhost:3000'
//Test a POST Invoke-RestMethod -Uri 'http://localhost:3000/todos' -Body '{"id":4,"Text":"ToDo 4"}' -Method Post
//Test a GET Invoke-RestMethod -Uri 'http://localhost:3000/todos'
//Test a wrong POST Invoke-RestMethod -Uri 'http://localhost:3000/todos' -Body '{"id":4}' -Method Post

const todos = [
    {id: 1, Text: 'ToDo 1'},
    {id: 2, Text: 'ToDo 2'},
    {id: 3, Text: 'ToDo 3'}
];

const http = require('http');

const server = http.createServer((req, res) => {

    const {method, url} = req;

    let body = [];

    req.on('data', chunk => {
        body.push(chunk);
    }).on('end', () => {
        body = Buffer.concat(body).toString();

        let status = 404;
        const response = {
            success: false,
            data: null,
            error: null
        };

        if (method === 'GET' && url === '/todos') {
            status = 200;
            response.success = true
            response.data = todos
        } else if (method === 'POST' && url === '/todos') {
            const {id, Text} = JSON.parse(body);

            if(!id || !Text) {
                status = 400
                response.error = 'Please check the given data'
            } else {
                todos.push({id, Text});
                status = 201
                response.success = true
                response.data = todos
            }
        }

        res.writeHead(status, {
            'Content-Type': 'text/json'
        });
        res.end(JSON.stringify(response));
    })
});

const PORT = 3000;

server.listen(PORT, () => console.log(`Server running on ${PORT}`));