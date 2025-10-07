# app/main.py
from fastapi import FastAPI, HTTPException

app = FastAPI(title="Arithmetic API")

def to_float(x):
    try:
        return float(x)
    except:
        raise HTTPException(status_code=400, detail="Invalid numeric input")

@app.get("/add")
def add(a: str, b: str):
    return {"result": to_float(a) + to_float(b)}

@app.get("/subtract")
def subtract(a: str, b: str):
    return {"result": to_float(a) - to_float(b)}

@app.get("/multiply")
def multiply(a: str, b: str):
    return {"result": to_float(a) * to_float(b)}

@app.get("/divide")
def divide(a: str, b: str):
    denom = to_float(b)
    if denom == 0:
        raise HTTPException(status_code=400, detail="Division by zero")
    return {"result": to_float(a) / denom}

