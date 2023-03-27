const app = require('express')();
const PORT = process.env.PORT || 12000;

const server = app.listen(PORT, () => {
    console.log('Server is running on', PORT);
});

// Socket Logic
const io = require('socket.io')(server);

const connectedUser = new Set();

io.on('connection', (socket) => {
    console.log("Connected Successfully", socket.id);
    connectedUser.add(socket.id);
    io.emit('connected-user', connectedUser.size);

    socket.on('disconnect', () => {
        console.log("Disconnect Successfully", socket.id);
        connectedUser.delete(socket.id);
        io.emit('connected-user', connectedUser.size);
    });
    socket.on('message', (msg) => {
        socket.broadcast.emit('message-receive', msg);
    });
});