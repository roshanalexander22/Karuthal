#!/usr/bin/env python3
"""
scripts/verify_all.py
---------------------
Complete system-wide verification harness for Sahaayi.
Runs pytest suites, live API health/auth/profile/autofill probes, and Flutter test suites.
"""

import subprocess
import sys
import os
import urllib.request
import json

def run_step(name, cmd, cwd=None):
    print(f"\n[TEST STEP] {name}...")
    try:
        env = os.environ.copy()
        if "DATABASE_URL_OVERRIDE" not in env:
            env["DATABASE_URL_OVERRIDE"] = "sqlite+aiosqlite:///sahaayi_dev.db"
        res = subprocess.run(cmd, cwd=cwd, shell=True, capture_output=True, text=True, env=env)
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
        req_headers = dict(headers or {})
        body = None
        if data is not None:
            body = json.dumps(data).encode("utf-8")
            req_headers["Content-Type"] = "application/json; charset=utf-8"
            req_headers["Content-Length"] = str(len(body))

        req = urllib.request.Request(url, data=body, headers=req_headers, method=method)
        res = urllib.request.urlopen(req, timeout=15)
        status = res.getcode()
        resp_data = json.loads(res.read().decode("utf-8"))
        print(f"  ✓ {name} SUCCESS ({status})")
        return True, resp_data
    except Exception as e:
        print(f"  ✗ {name} FAILED: {e}")
        return False, str(e)

def main():
    print("=" * 65)
    print("🚀 SAHAAYI: SYSTEM-WIDE VERIFICATION & AUDIT HARNESS")
    print("=" * 65)

    results = {}

    py_bin = sys.executable
    # 1. Backend Pytest
    ok, out = run_step("Backend Pytest", f'"{py_bin}" -m pytest -v', cwd="backend")
    results["Backend Unit Tests"] = ok

    # 2. AI Engine Pytest
    ok, out = run_step("AI Engine Pytest", f'"{py_bin}" -m pytest -v', cwd="ai-engine")
    results["AI Engine Unit Tests"] = ok

    # 3. Live Backend Health
    ok, data = test_http("Backend /health", "http://127.0.0.1:8000/health")
    results["Backend Live Health"] = ok

    # 4. Live Backend API v1 Health
    ok, data = test_http("Backend /api/v1/health", "http://127.0.0.1:8000/api/v1/health")
    results["Backend v1 Live Health"] = ok

    # 5. Live AI Engine Health
    ok, data = test_http("AI Engine /health", "http://127.0.0.1:8001/health")
    results["AI Engine Live Health"] = ok

    # 6. Live Auth Registration Test
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

    # 7. Live Auth Login Test
    login_payload = {
        "email": test_user_email,
        "password": "SecurePassword123!"
    }
    ok, login_data = test_http("Auth Login", "http://127.0.0.1:8000/api/v1/auth/login", method="POST", data=login_payload)
    results["Live User Authentication"] = ok

    token = login_data.get("access_token") if (ok and isinstance(login_data, dict)) else None

    # 8. Live Protected Endpoint Test (/api/v1/auth/me)
    if token:
        ok_me, me_data = test_http(
            "Auth /me (Protected)",
            "http://127.0.0.1:8000/api/v1/auth/me",
            headers={"Authorization": f"Bearer {token}"}
        )
        results["Live Protected /me Endpoint"] = ok_me

        # 9. Live Personal Memory Update
        ok_mem_patch, patch_data = test_http(
            "Personal Memory Patch",
            "http://127.0.0.1:8000/api/v1/profile",
            method="PATCH",
            data={"field_name": "full_name", "field_value": "Kalyani Amma", "is_verified": True},
            headers={"Authorization": f"Bearer {token}"}
        )
        results["Live Memory Bank Upsert"] = ok_mem_patch

        # 10. Live Personal Memory Retrieve
        ok_mem_get, get_data = test_http(
            "Personal Memory Get",
            "http://127.0.0.1:8000/api/v1/profile",
            method="GET",
            headers={"Authorization": f"Bearer {token}"}
        )
        results["Live Memory Bank Retrieval"] = ok_mem_get

        # 11. Live Smart Autofill Semantic Match
        match_payload = {
            "fields": [
                {"node_id": "txt_01", "label": "Full Name", "input_type": "text", "is_password_or_sensitive": False},
                {"node_id": "txt_pwd", "label": "Password", "input_type": "password", "is_password_or_sensitive": True}
            ]
        }
        ok_match, match_data = test_http(
            "Smart Autofill Match",
            "http://127.0.0.1:8000/api/v1/autofill/match",
            method="POST",
            data=match_payload,
            headers={"Authorization": f"Bearer {token}"}
        )
        has_match = ok_match and len(match_data.get("matches", [])) == 1
        results["Smart Autofill Semantic Match"] = has_match

        # 12. Live Smart Autofill Confirm & Audit Log
        if has_match:
            confirm_payload = {"confirmed_matches": match_data["matches"]}
            ok_conf, conf_data = test_http(
                "Smart Autofill Confirm",
                "http://127.0.0.1:8000/api/v1/autofill/confirm",
                method="POST",
                data=confirm_payload,
                headers={"Authorization": f"Bearer {token}"}
            )
            results["Smart Autofill Audit Log"] = ok_conf
        else:
            results["Smart Autofill Audit Log"] = False

    # 13. Flutter Analyze
    ok, out = run_step("Flutter Analyze", "flutter analyze", cwd="frontend/mobile")
    results["Flutter Static Analysis"] = ok

    # 14. Flutter Test
    ok, out = run_step("Flutter Widget Tests", "flutter test", cwd="frontend/mobile")
    results["Flutter Tests"] = ok

    print("\n" + "=" * 65)
    print("📊 COMPLETE VERIFICATION RESULTS MATRIX")
    print("=" * 65)
    all_passed = True
    for test_name, passed in results.items():
        status = "PASSED ✓" if passed else "FAILED ✗"
        print(f"  {test_name.ljust(35)}: {status}")
        if not passed:
            all_passed = False

    print("=" * 65)
    if all_passed:
        print("🎉 ALL VERIFICATION CHECKS PASSED PERFECTLY!")
    else:
        print("⚠️ Some checks failed. Review output above.")
    print("=" * 65)

    if not all_passed:
        sys.exit(1)

if __name__ == "__main__":
    main()
