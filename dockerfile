# ---- Build Stage ----
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN yarn install

COPY . .

RUN npx prisma generate
RUN yarn run build

# ---- Production Stage ----
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN yarn install --only=production

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY .env .env     

ENV NODE_ENV=production

CMD sh -c "npx prisma migrate deploy && node ./dist/main.js"