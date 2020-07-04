FROM node:12-slim
WORKDIR /usr/src/app
COPY package.json ./

# Install production dependencies.
RUN yarn install --only=production

# Copy local code to the container image.
COPY . ./

#rename envrionment file
COPY ./.env.example.production ./.env

# Run the web service on container startup.
CMD [ "yarn", "start" ]
