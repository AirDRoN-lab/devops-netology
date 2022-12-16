FROM node:lts-buster as builder

RUN mkdir /app

WORKDIR /app

ADD package.json /app/package.json
ADD package-lock.json /app/package-lock.json

RUN npm i

ADD . /app

ENV NODE_OPTIONS=--openssl-legacy-provider
RUN npx browserslist@latest --update-db 
RUN npm install --package-lock-only && npm run build && rm -rf /app/node_modules

FROM nginx:latest

RUN mkdir /app
WORKDIR /app
COPY --from=builder /app/ /app

RUN mv /app/markup/* /app && rm -rf /app/markup

ADD demo.conf /etc/nginx/conf.d/default.conf
