from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.get("/api/health")
def health():
    return jsonify({"status": "ok", "service": "teachereye_api"})

@app.post("/api/auth/login")
def login():
    data = request.get_json(silent=True) or {}
    email = (data.get("email") or "").strip()
    password = data.get("password") or ""

    if not email or not password:
        return jsonify({"ok": False, "message": "Email and password required"}), 400

    if email == "admin@teachereye.ai" and password == "admin123":
        return jsonify({
            "ok": True,
            "user": {"id": 1, "name": "Admin", "email": email},
            "token": "demo-token"
        })

    return jsonify({"ok": False, "message": "Invalid credentials"}), 401

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=True)
