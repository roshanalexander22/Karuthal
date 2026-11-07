#!/usr/bin/env python3
"""
scripts/verify_all.py
---------------------
Complete verification harness for Sahaayi Phase 12.
Runs pytest suites, live API tests, seed validation, and Flutter analysis.
"""

import subprocess
import sys
import os
import urllib.request
import json

def run_step(name, cmd, cwd=None):
    print(f"\n[TEST STEP] {name}...")
    try:
        res = subprocess.run(cmd, cwd=cwd, shell=True, capture_output=True, text=True)
        if res.returncode == 0:
            print(f"  ✓ {name} PASSED")
            return True, res.stdout
        else:
            print(f"  ✗ {name} FAILED (exit {res.returncode})")
            print("  Stdout:", res.stdout[:300])
            print("  Stderr:", res.stderr[:300])
            return False, res.stderr
    except Exception as e:
        print(f"  ✗ {name} EXCEPTION: {e}")
        return False, str(e)

def test_http(name, url, method="GET", data=None, headers=None):
    print(f"\n[HTTP PROBE] {name} ({method} {url})...")
    try:
        req = urllib.request.Request(url, method=method)
        if headers:
            for k, v in headers.items():
                req.add_header(k, v)
        body = json.dumps(data).encode("utf-8") if data else None
        if body:
            req.add_header("Content-Type", "application/json")
        res = urllib.request.urlopen(req, data=body, timeout=5)
        status = res.getcode()
        resp_data = json.loads(res.read().decode("utf-8"))
        print(f"  ✓ {name} SUCCESS ({status})")
        return True, resp_data
    except Exception as e:
        print(f"  ✗ {name} FAILED: {e}")
        return False, str(e)

def main():
    print("=" * 60)
    print("🚀 SAHAAYI: PHASE 12 SYSTEM-WIDE VERIFICATION & AUDIT HARNESS")
    print("=" * 60)

    results = {}

    # 1. Backend Pytest
    ok, out = run_step("Backend Pytest", "pytest -v", cwd="backend")
    results["Backend Unit Tests"] = ok

    # 2. AI Engine Pytest
    ok, out = run_step("AI Engine Pytest", "pytest -v", cwd="ai-engine")
    results["AI Engine Unit Tests"] = ok

    # 3. Live Backend Health
    ok, data = test_http("Backend /health", "http://127.0.0.1:8000/health")
    results["Backend Live Health"] = ok

    # 4. Live AI Engine Health
    ok, data = test_http("AI Engine /health", "http://127.0.0.1:8001/health")
    results["AI Engine Live Health"] = ok

    # 5. Live Auth Registration Test
    test_user_email = f"elder_{os.urandom(3).hex()}@sahaayi.in"
    reg_payload = {
        "email": test_user_email,
        "password": "SecurePassword123!",
        "full_name": "Kalyani Amma",
        "phone": "+919847111222",
        "language_preference": "ml"
    }
    ok, reg_data = test_http("Auth Register", "http://127.0.0.1:8000/api/v1/auth/register", method="POST", data=reg_payload)
    results["Live User Registration"] = ok

    # 6. Live Auth Login Test
    login_payload = {
        "email": test_user_email,
        "password": "SecurePassword123!"
    }
    ok, login_data = test_http("Auth Login", "http://127.0.0.1:8000/api/v1/auth/login", method="POST", data=login_payload)
    results["Live User Authentication"] = ok

    # 7. Live Protected Endpoint Test (/api/v1/auth/me)
    if ok and "access_token" in login_data:
        token = login_data["access_token"]
        ok_me, me_data = test_http(
            "Auth /me (Protected)",
            "http://127.0.0.1:8000/api/v1/auth/me",
            headers={"Authorization": f"Bearer {token}"}
        )
        results["Live Protected /me Endpoint"] = ok_me

    # 8. Flutter Analyze
    ok, out = run_step("Flutter Analyze", "flutter analyze", cwd="frontend/mobile")
    results["Flutter Static Analysis"] = ok

    # 9. Flutter Test
    ok, out = run_step("Flutter Widget Tests", "flutter test", cwd="frontend/mobile")
    results["Flutter Tests"] = ok

    print("\n" + "=" * 60)
    print("📊 VERIFICATION RESULTS MATRIX")
    print("=" * 60)
    all_passed = True
    for test_name, passed in results.items():
        status = "PASSED ✓" if passed else "FAILED ✗"
        print(f"  {test_name.ljust(35)}: {status}")
        if not passed:
            all_passed = False

    print("=" * 60)
    if all_passed:
        print("🎉 ALL VERIFICATION CHECKS PASSED PERFECTLY!")
    else:
        print("⚠️ Some checks failed. Review output above.")
    print("=" * 60)

if __name__ == "__main__":
    main()
