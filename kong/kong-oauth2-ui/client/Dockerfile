
# This container is not starting because app.js expects to have env set up beofore hand

FROM node:carbon

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install

# Fore reloading node DEV only
RUN npm install -g nodemon

# Bundle app source
COPY app.js ./
COPY views ./views/

CMD [ "npm", "start" ]
