#!/bin/bash
echo "Starting App"
export DB_HOST=mongodb://11.1.2.69/posts
cd /home/ubuntu/app
npm install 
pm2 start app.js