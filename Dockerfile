FROM node:24.5.0
WORKDIR /app

COPY . .
RUN npm install

RUN npm run build


EXPOSE 3000

CMD ["npm","run","start"]