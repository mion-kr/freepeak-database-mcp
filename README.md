# Mion Multi-Database MCP Server

환경별로 분리된 다중 데이터베이스 MCP(Model Context Protocol) 서버입니다.  
개발(dev)과 운영(live) 환경을 완전히 분리하여 안전한 데이터베이스 작업을 지원합니다.

## 📁 디렉토리 구조

```
mcp-server/
├── dev/                          # 개발 환경
│   ├── config/
│   │   └── mcp-config.json       # dev 환경 데이터베이스 설정
│   └── docker-compose.yml        # dev 환경 Docker 구성
├── live/                         # 운영 환경
│   ├── config/
│   │   └── mcp-config.json       # live 환경 데이터베이스 설정 (템플릿)
│   └── docker-compose.yml        # live 환경 Docker 구성
├── config/                       # 기존 설정 (레거시)
│   └── mcp-config.json
├── docker-compose.yml            # 기존 구성 (레거시)
└── README.md                     # 이 파일
```

## 🚀 환경별 실행 방법

### 🛠️ Dev 환경 실행

1. **설정 파일 준비 (최초 1회)**

   ```bash
   cd dev/config
   cp mcp-config.json.example mcp-config.json
   # mcp-config.json 파일의 플레이스홀더를 실제 DB 정보로 변경
   ```

   ⚠️ **중요**: `.env` 파일의 환경변수는 MCP 서버에 적용되지 않습니다.  
   **반드시 mcp-config.json 파일에 직접 값을 입력해야 합니다.**

2. **개발 환경 실행**

   ```bash
   cd dev
   docker-compose up -d

   # 로그 확인
   docker-compose logs -f
   ```

**포트:** `9092`  
**컨테이너명:** `dev-db-mcp`

### 🔴 Live 환경 실행

⚠️ **주의: 운영 환경 설정이 필요합니다**

1. **환경 설정 파일 준비**

   ```bash
   cd live/config
   cp mcp-config.json.example mcp-config.json
   ```

2. **설정 파일 수정**
   `live/config/mcp-config.json` 파일에서 아래 플레이스홀더를 실제 값으로 직접 변경:

   - `YOUR_LIVE_DB_HOST` → 실제 DB 호스트 주소
   - `YOUR_LIVE_DB_USER` → 실제 DB 사용자명
   - `YOUR_LIVE_DB_PASSWORD` → 실제 DB 비밀번호

   ⚠️ **중요**: `.env` 파일의 환경변수는 MCP 서버에 적용되지 않습니다.  
   **반드시 mcp-config.json 파일에 직접 값을 입력해야 합니다.**

3. **운영 환경 실행**

   ```bash
   cd live
   docker-compose up -d
   ```

**포트:** `9093`  
**컨테이너명:** `live-db-mcp`

## 🔧 Claude Code 연결 설정

### 개발 환경 연결

`.claude.json`에 dev 서버 추가:

```json
{
  "mcpServers": {
    "dev-db-server": {
      "type": "sse",
      "url": "http://localhost:9092"
    }
  }
}
```

### 운영 환경 연결 (신중하게!)

```json
{
  "mcpServers": {
    "live-db-server": {
      "type": "sse",
      "url": "http://localhost:9093"
    }
  }
}
```

## ⚠️ 중요 참고사항

### 🔴 환경변수 설정 관련 주의

**MCP 서버는 `.env` 파일의 환경변수를 읽지 않습니다!**

- ❌ `.env` 파일에 DB 정보 설정 → **작동 안 함**
- ✅ `mcp-config.json` 파일에 직접 입력 → **정상 작동**

각 환경의 `mcp-config.json` 파일에 실제 데이터베이스 접속 정보를 직접 입력해야 합니다.  
보안을 위해 이 파일들은 `.gitignore`에 등록되어 있어 git에 커밋되지 않습니다.

## ⚠️ 안전 수칙

### ✅ DO (권장사항)

- **공통 사항**: readOnly 권한만 있는 Database 계정 생성

  ```sql
  CREATE USER 'mcp_readonly'@'%' IDENTIFIED BY 'YOUR_PASSWORD';
  GRANT SELECT, SHOW VIEW ON YOUR_DATABASE_1.* TO 'mcp_readonly'@'%';
  GRANT SELECT, SHOW VIEW ON YOUR_DATABASE_2.* TO 'mcp_readonly'@'%';
  GRANT SELECT, SHOW VIEW ON YOUR_DATABASE_3.* TO 'mcp_readonly'@'%';
  FLUSH PRIVILEGES;
  ```

- **개발 작업시**: dev 환경만 사용
- **쿼리 실행 전**: 어떤 환경에 연결되어 있는지 반드시 확인
- **운영 환경**: 읽기 전용(SELECT) 쿼리만 실행
- **각 환경**: 별도의 포트와 컨테이너명으로 구분해서 실행

### ❌ DON'T (금지사항)

- dev와 live 환경을 동시에 실행하지 말 것
- 운영 환경에서 INSERT/UPDATE/DELETE 쿼리 실행 금지
- 환경 확인 없이 쿼리 실행 금지

## 🔍 환경 확인 방법

실행 중인 환경 확인:

```bash
# 실행 중인 컨테이너 확인
docker ps | grep db-mcp

# 포트로 구분
# 9092 = dev 환경
# 9093 = live 환경
```

## 🛠️ 관리 명령어

### 환경 중지

```bash
# dev 환경 중지
cd dev && docker-compose down

# live 환경 중지
cd live && docker-compose down
```

### 로그 확인

```bash
# dev 환경 로그
cd dev && docker-compose logs -f

# live 환경 로그
cd live && docker-compose logs -f
```

### 컨테이너 재시작

```bash
# dev 환경 재시작
cd dev && docker-compose restart

# live 환경 재시작
cd live && docker-compose restart
```

## 📋 체크리스트

### Dev 환경 사용시

- [ ] dev 디렉토리에서 실행했는가?
- [ ] 포트 9092가 사용되고 있는가?
- [ ] 컨테이너명이 `dev-db-mcp`인가?
- [ ] Claude Code에서 `database-dev` 서버를 사용하고 있는가?

### Live 환경 사용시

- [ ] live 환경 설정이 완료되었는가?
- [ ] 실제 운영 DB 접속 정보가 설정되었는가?
- [ ] 포트 9093이 사용되고 있는가?
- [ ] 컨테이너명이 `live-db-mcp`인가?
- [ ] 읽기 전용 쿼리만 실행할 것인가?
