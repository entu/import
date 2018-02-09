FROM node:8-slim

ADD ./ /usr/src/entu-import
RUN cd /usr/src/entu-import && npm --silent install

CMD ["node", "/usr/src/entu-import/import.js"]
