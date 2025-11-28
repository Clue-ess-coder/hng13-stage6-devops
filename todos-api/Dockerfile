FROM node:8 as deps

WORKDIR /app

COPY package*.json ./

RUN npm install

FROM node:8-slim as prod

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

EXPOSE 8082

CMD ["npm", "start"]
