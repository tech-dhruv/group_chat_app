const express = require("express");
const { createServer } = require("http");
const { Server } = require("socket.io");

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer);

app.route("/").get((req, res) => {
    res.json("Hey there dhruv1 ");
})

io.on("connection", (socket) => {
    console.log("A user connected:", socket.id);

 // Handle joining a room
 socket.on("join_room", (room) => {
    console.log(room);
    socket.join(room);
   // console.log(`User ${socket.id} joined room ${room}`);
  });

  // Handle sending a message
  socket.on("sendMsg", (data) => {
    const {room, msg, senderName, userId} = data;
    console.log(`Message from ${socket.id} in room ${room}:`, msg);

    // Emit the message to everyone in the room
    io.to(room).emit("sendMsgServer", {
        msg,
        type:"otherMsg",
        senderName,
        userId, });
  });

  socket.on("disconnect", () => {
    console.log("A user disconnected:", socket.id);
  });

});

httpServer.listen(5251);
// const PORT = process.env.PORT || 5251;
// httpServer.listen(PORT, () => {
//   console.log(`Server is running on port ${PORT}`);
// });

// //old code======
// io.on("connection", (socket) => {
//     console.log("A user connected:", socket.id);

//     socket.join("anomynous_group");
//     console.log("backend connected");
//     socket.on("sendMsg", (msg)=>{
//         console.log("here is msg", msg);
//         //socket.emit("sendMsgServer",{...msg, type:"otherMsg"})
//         io.to("anomynous_group").emit("sendMsgServer",{...msg, type:"otherMsg"});
//     })
// })

// httpServer.listen(5251);