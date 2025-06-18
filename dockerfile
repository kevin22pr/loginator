# ---- Build Stage ----
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN yarn install

COPY . .
RUN ls -la /app
RUN npx prisma generate --schema=src/prisma/schema.prisma
RUN yarn run build

# ---- Production Stage ----
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma   

ENV NODE_ENV=production

CMD sh -c "npx prisma migrate deploy --schema=src/prisma/schema.prisma && node ./dist/main.js"