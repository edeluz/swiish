# Build Stage
FROM node:22-alpine AS build
WORKDIR /app

COPY package*.json ./
COPY tailwind.config.js ./
COPY postcss.config.js ./
COPY scripts/ scripts/
RUN npm ci --legacy-peer-deps

COPY public/ public/
COPY src/ src/

# Build the app (capture-git-info.js falls back to branch:null gracefully without .git)
RUN npm run build

# Production Stage
FROM node:22-alpine
WORKDIR /app

# Copy fonts first, then install them
COPY fonts/ ./fonts

# Install fonts for SVG text rendering in preview images
# Atkinson Hyperlegible font for improved accessibility (used in preview generation)
# Fonts are embedded in the project for reliability
RUN apk add --no-cache fontconfig \
    && mkdir -p /usr/share/fonts/opentype \
    && cp ./fonts/*.otf /usr/share/fonts/opentype/ \
    && fc-cache -f /usr/share/fonts/

COPY --from=build /app/build ./build
COPY --from=build /app/src/active-branch.json ./active-branch.json
COPY package*.json ./
RUN npm install --production
COPY server.js .
COPY database.json .
COPY migrations/ ./migrations/

# Create dirs for volumes
RUN mkdir data
RUN mkdir uploads

EXPOSE 3000
CMD ["node", "server.js"]
