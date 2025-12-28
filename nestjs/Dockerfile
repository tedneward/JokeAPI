FROM node:20-alpine
WORKDIR /usr/src/app
COPY package.json package-lock.json* ./
# Use pure-JS SQL driver at runtime
ENV DB_DRIVER=sqljs
RUN npm ci --only=production || npm install --production
COPY . .
RUN npm run build
# ensure data dir exists for sql.js file saving
RUN mkdir -p /usr/src/app/data
EXPOSE 8000
CMD ["node", "dist/main.js"]
