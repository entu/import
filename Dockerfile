FROM node:18-alpine
WORKDIR /usr/src/entu-import
COPY ./package*.json ./
RUN npm ci --silent
COPY ./ ./
CMD npm run import:entities
