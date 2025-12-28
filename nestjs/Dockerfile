FROM node:20-alpine
WORKDIR /usr/src/app
COPY package.json package-lock.json* ./
RUN npm ci --only=production || npm install --production
COPY . .
RUN npm run build
EXPOSE 8000
CMD ["node", "dist/main.js"]
