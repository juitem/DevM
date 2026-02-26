FROM node:20-alpine

WORKDIR /app

# package.json만 먼저 복사
COPY package.json ./

# Ubuntu 환경 내부에서 npm install 실행 (package-lock.json 자동 생성)
RUN npm install

# 나머지 코드 복사
COPY . .

EXPOSE 3000

CMD ["npm", "start"]
