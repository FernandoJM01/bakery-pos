FROM node:20-alpine

WORKDIR /usr/src/app

# Install build dependencies if needed (e.g., for bcrypt native compilation)
RUN apk add --no-cache python3 make g++

COPY package.json ./

RUN npm install

COPY . .

RUN npm run build

EXPOSE 3001

CMD ["npm", "run", "start:prod"]
