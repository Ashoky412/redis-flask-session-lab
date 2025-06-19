## 🧠 Redis + Flask Session Store: Hands-On Cheat Sheet (Amazon Linux 2023)

---

### ✅ Goal:
- Build a Flask app with Redis-backed session storage
- Host on a single EC2 (Amazon Linux 2023)
- Enable Redis persistence (RDB + AOF)
- Verify behavior during restarts/crashes
- Prep for SRE interviews (TTL, failover, recovery)

---

### 📦 Project Structure (All in EC2)
```
~/app.py               # Flask app
~/setup_redis.sh       # Redis install + build (source)
~/redis-7.2.4/         # Redis source + binaries
```

---

### ⚙️ Commands Summary

#### ✅ Install Redis (from source)
```bash
cd /opt
curl -O https://download.redis.io/releases/redis-7.2.4.tar.gz
tar xzvf redis-7.2.4.tar.gz
cd redis-7.2.4
make MALLOC=libc
```

#### ✅ Create Symlinks
```bash
sudo ln -s /opt/redis-7.2.4/src/redis-server /usr/local/bin/redis-server
sudo ln -s /opt/redis-7.2.4/src/redis-cli /usr/local/bin/redis-cli
```

#### ✅ Start Redis
```bash
redis-server --daemonize yes
```

#### ✅ Start Flask App
```bash
nohup python3 ~/app.py > ~/flask.log 2>&1 &
```

#### ✅ Flask App (session stored in Redis)
```python
from flask import Flask, session
from flask_session import Session
import redis

app = Flask(__name__)
app.secret_key = 'super-secret-key'
app.config['SESSION_TYPE'] = 'redis'
app.config['SESSION_REDIS'] = redis.Redis(host='localhost', port=6379)
Session(app)

@app.route('/')
def index():
    session['visits'] = session.get('visits', 0) + 1
    return f"Visit #: {session['visits']} (Session stored in Redis)"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

---

### 🔍 Redis CLI Essentials
```bash
redis-cli
keys *
ttl <key>
get <key>
config get dir
config get save
config get appendonly
monitor
```

---

### 🔐 Fix Redis Save Permission Error
```bash
sudo chown -R ec2-user:ec2-user /opt/redis-7.2.4
```

---

### 💾 Force Save + Confirm RDB
```bash
redis-cli
save
exit
ls -lh /opt/redis-7.2.4 | grep dump.rdb
```

---

### 🔁 Test: Redis Crash & Recovery
```bash
pkill -9 redis-server
redis-server --daemonize yes
```
Then refresh browser — session should persist

---

### 🧠 Improve Persistence (Enable AOF)
```bash
redis-cli config set appendonly yes
redis-cli config rewrite
ls -lh /opt/redis-7.2.4 | grep appendonly.aof
```

---

### ✅ What to Expect
| Scenario               | Expected Output         |
|------------------------|-------------------------|
| Save + restart         | Session resumes         |
| No save + crash        | Session lost            |
| AOF enabled            | Session always resumes  |
| AOF + RDB enabled      | Maximum durability      |

---

### 🧪 Testing Tips
- Use two terminals: one for Flask, one for Redis
- Watch `monitor` to see live commands
- Use `flushall` or `expire` to simulate session expiration

---

### ✅ Next Ideas
- Migrate Redis to ElastiCache
- Add login/user auth to Flask
- Use Redis Sentinel for HA
- Dockerize the setup
- Add NGINX reverse proxy on port 80/443
- Simulate TTL expiry, eviction, failover (SRE scenarios)

---

### 👨‍💻 Author: Ashok Pindiboyina
- Region: Tirupati, Andhra Pradesh
- Stack: AWS | Redis | Python | SRE

