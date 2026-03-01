from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os

app = FastAPI()

# CORS 설정 (React에서 API 호출 가능)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# API 라우트
@app.get("/api/status")
def get_status():
    return {
        "status": "running",
        "python_version": "3.13",
        "platform": "Ubuntu 24.04"
    }

@app.post("/api/process")
def process_data(data: dict):
    # Python에서 데이터 처리
    return {"result": f"Processed: {data}"}

@app.get("/api/hello")
def hello():
    return {"message": "Hello from Python FastAPI Backend!"}
