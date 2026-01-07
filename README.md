# Multi-Database MCP Server

환경별로 분리된 다중 데이터베이스 MCP(Model Context Protocol) 서버입니다.  
개발(dev), 사무실(office), 운영(live) 환경을 분리하여 안전한 데이터베이스 작업을 지원합니다.

## 📁 디렉토리 구조

```
mcp-server/
├── dev/                          # 개발 환경
│   ├── config/
│   │   ├── mcp-config.template.json  # dev 환경 템플릿 (환경 변수 기반)
│   │   └── mcp-config.json           # dev 환경 데이터베이스 설정 (렌더링 결과, 컨테이너가 생성)
│   ├── scripts/
│   │   └── render-config-entrypoint.sh # 컨테이너 엔트리포인트용 스크립트
│   ├── Dockerfile                # dev 환경용 커스텀 이미지
│   └── docker-compose.yml        # dev 환경 Docker 구성
├── office/                       # 사무실 환경
│   ├── config/
│   │   ├── mcp-config.template.json  # office 환경 템플릿 (환경 변수 기반)
│   │   └── mcp-config.json           # office 환경 데이터베이스 설정 (렌더링 결과, 컨테이너가 생성)
│   ├── scripts/
│   │   └── render-config-entrypoint.sh # 컨테이너 엔트리포인트용 스크립트
│   ├── Dockerfile                # office 환경용 커스텀 이미지
│   └── docker-compose.yml        # office 환경 Docker 구성
├── live/                         # 운영 환경
│   ├── config/
│   │   ├── mcp-config.template.json  # live 환경 템플릿
│   │   └── mcp-config.json           # live 환경 설정 (컨테이너가 생성)
│   ├── scripts/
│   │   └── render-config-entrypoint.sh # 컨테이너 엔트리포인트 스크립트
│   ├── Dockerfile                # live 환경용 커스텀 이미지
│   └── docker-compose.yml        # live 환경 Docker 구성
└── README.md                     # 이 파일
```

## 🚀 환경별 실행 방법

### 🛠️ Dev 환경 실행

1. **환경 변수 준비 (최초 1회)**

   ```bash
   cd dev
   cp .env.example .env
   # .env 파일의 값을 실제 DB 정보로 채워 주세요.
	   ```

### 🏢 Office 환경 실행

1. **환경 변수 준비 (최초 1회)**

   ```bash
   cd office
   cp .env.example .env
   # .env 파일의 값을 실제 DB 정보로 채워 주세요.
   ```

2. **Office 환경 실행**

   ```bash
   cd office
   docker-compose up --build -d
   ```

**포트:** `9094`  
**컨테이너명:** `office-db-mcp`

### 🔴 Live 환경 실행

⚠️ **주의: 운영 환경 설정이 필요합니다**

1. **환경 변수 준비**

   ```bash
   cd live
   cp .env.example .env
   # .env 파일은 안전한 비밀 저장소/배포 파이프라인에서 실제 값으로 채워 주세요.
   ```

2. **운영 환경 실행**

   ```bash
   cd live
   docker-compose up --build -d
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

### 사무실 환경 연결

```json
{
  "mcpServers": {
    "office-db-server": {
      "type": "sse",
      "url": "http://localhost:9094"
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

**운영 환경**은 `.env` 파일을 읽지 않습니다.

- ✅ **개발 환경(dev)**: `dev/.env` → 컨테이너 엔트리포인트(자동 렌더링) → `/app/config.json`
- ✅ **사무실 환경(office)**: `office/.env` → 컨테이너 엔트리포인트(자동 렌더링) → `/app/config.json`
- ✅ **운영 환경(live)**: `live/.env` → 컨테이너 엔트리포인트(자동 렌더링) → `/app/config.json`

생성된 `mcp-config.json` 파일들은 `.gitignore`에 포함되어 git에 커밋되지 않습니다.

## ⚠️ 안전 수칙

### ✅ DO (권장사항)

- **공통 사항**: readOnly 권한만 있는 Database 계정 생성하여 사용합니다. 이미 존재하는 계정이 있다면 해당 계정을 사용해도 무방합니다.

  ```sql
  CREATE USER 'mcp_readonly'@'%' IDENTIFIED BY 'YOUR_PASSWORD';
  GRANT SELECT, SHOW VIEW ON YOUR_DATABASE_1.* TO 'mcp_readonly'@'%';
  GRANT SELECT, SHOW VIEW ON YOUR_DATABASE_2.* TO 'mcp_readonly'@'%';
  GRANT SELECT, SHOW VIEW ON YOUR_DATABASE_3.* TO 'mcp_readonly'@'%';
  FLUSH PRIVILEGES;
  ```

- **개발 작업시**: office 환경만 사용
- **쿼리 실행 전**: 어떤 환경에 연결되어 있는지 반드시 확인
- **운영 환경**: 읽기 전용(SELECT) 쿼리만 실행
- **각 환경**: 별도의 포트와 컨테이너명으로 구분해서 실행

## 🔍 환경 확인 방법

실행 중인 환경 확인:

```bash
# 실행 중인 컨테이너 확인
docker ps | grep db-mcp

# 포트로 구분
# 9092 = dev 환경
# 9094 = office 환경
# 9093 = live 환경
```

## 🛠️ 관리 명령어

### 환경 중지

```bash
# dev 환경 중지
cd dev && docker-compose down

# office 환경 중지
cd office && docker-compose down

# live 환경 중지
cd live && docker-compose down
```

### 로그 확인

```bash
# dev 환경 로그
cd dev && docker-compose logs -f

# office 환경 로그
cd office && docker-compose logs -f

# live 환경 로그
cd live && docker-compose logs -f
```

### 컨테이너 재시작

```bash
# dev 환경 재시작
cd dev && docker-compose restart

# office 환경 재시작
cd office && docker-compose restart

# live 환경 재시작
cd live && docker-compose restart
```
