# ---- Build Stage ----
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN yarn install

COPY . .

RUN yarn run build

# ---- Production Stage ----
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN yarn install --only=production

COPY --from=builder /app/dist ./dist
COPY prisma ./prisma  
COPY .env .env       

ENV NODE_ENV=production

CMD ["node", "dist/main"]