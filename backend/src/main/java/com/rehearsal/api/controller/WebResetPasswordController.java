package com.rehearsal.api.controller;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class WebResetPasswordController {

    @GetMapping(value = "/reset-password", produces = MediaType.TEXT_HTML_VALUE)
    @ResponseBody
    public String getResetPasswordPage(@RequestParam(value = "token", required = false) String token) {
        String safeToken = token != null ? token.replaceAll("[^a-zA-Z0-9\\-_]", "") : "";

        return """
            <!DOCTYPE html>
            <html lang="en">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <meta name="referrer" content="no-referrer">
              <title>Reset Password — Rehearsal</title>
              <link rel="preconnect" href="https://fonts.googleapis.com">
              <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
              <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
              <style>
                * { box-sizing: border-box; margin: 0; padding: 0; }
                body {
                  font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
                  background-color: #0F172A;
                  color: #F8FAFC;
                  min-height: 100vh;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  padding: 24px 16px;
                }
                .card {
                  background-color: #1E293B;
                  border: 1px solid #334155;
                  border-radius: 20px;
                  width: 100%;
                  max-width: 440px;
                  padding: 36px 28px;
                  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
                }
                .logo-row {
                  display: flex;
                  align-items: center;
                  gap: 12px;
                  margin-bottom: 24px;
                }
                .logo-icon {
                  width: 40px;
                  height: 40px;
                  border-radius: 12px;
                  background-color: rgba(20, 184, 166, 0.15);
                  border: 1px solid rgba(20, 184, 166, 0.3);
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  color: #14B8A6;
                  font-size: 20px;
                  font-weight: 700;
                }
                .logo-title {
                  font-size: 20px;
                  font-weight: 700;
                  color: #F8FAFC;
                  letter-spacing: -0.5px;
                }
                h1 {
                  font-size: 24px;
                  font-weight: 700;
                  color: #F8FAFC;
                  margin-bottom: 8px;
                  letter-spacing: -0.5px;
                }
                p.desc {
                  color: #94A3B8;
                  font-size: 14px;
                  line-height: 1.5;
                  margin-bottom: 28px;
                }
                .app-link-box {
                  background-color: #0F172A;
                  border: 1px solid #334155;
                  border-radius: 12px;
                  padding: 14px 16px;
                  margin-bottom: 24px;
                  display: flex;
                  align-items: center;
                  justify-content: space-between;
                }
                .app-link-text {
                  font-size: 13px;
                  color: #94A3B8;
                }
                .app-link-btn {
                  background-color: rgba(20, 184, 166, 0.15);
                  color: #14B8A6;
                  border: 1px solid rgba(20, 184, 166, 0.4);
                  border-radius: 8px;
                  padding: 6px 12px;
                  font-size: 12px;
                  font-weight: 600;
                  text-decoration: none;
                  white-space: nowrap;
                  transition: all 0.2s;
                }
                .app-link-btn:hover {
                  background-color: #14B8A6;
                  color: #0F172A;
                }
                .form-group {
                  margin-bottom: 18px;
                }
                label {
                  display: block;
                  font-size: 13px;
                  font-weight: 500;
                  color: #94A3B8;
                  margin-bottom: 8px;
                }
                input[type="text"], input[type="password"] {
                  width: 100%;
                  background-color: #0F172A;
                  border: 1px solid #334155;
                  border-radius: 12px;
                  padding: 14px 16px;
                  font-size: 15px;
                  color: #F8FAFC;
                  font-family: inherit;
                  outline: none;
                  transition: border-color 0.2s, box-shadow 0.2s;
                }
                input[type="text"]:focus, input[type="password"]:focus {
                  border-color: #14B8A6;
                  box-shadow: 0 0 0 3px rgba(20, 184, 166, 0.2);
                }
                .btn-submit {
                  width: 100%;
                  background-color: #14B8A6;
                  color: #0F172A;
                  border: none;
                  border-radius: 12px;
                  padding: 15px;
                  font-size: 15px;
                  font-weight: 700;
                  cursor: pointer;
                  margin-top: 10px;
                  transition: background-color 0.2s, transform 0.1s;
                }
                .btn-submit:hover {
                  background-color: #0D9488;
                }
                .btn-submit:disabled {
                  opacity: 0.6;
                  cursor: not-allowed;
                }
                .alert {
                  padding: 12px 14px;
                  border-radius: 10px;
                  font-size: 13px;
                  margin-bottom: 18px;
                  display: none;
                }
                .alert-error {
                  background-color: rgba(244, 63, 94, 0.15);
                  border: 1px solid rgba(244, 63, 94, 0.4);
                  color: #F43F5E;
                }
                .alert-success {
                  background-color: rgba(20, 184, 166, 0.15);
                  border: 1px solid rgba(20, 184, 166, 0.4);
                  color: #14B8A6;
                }
                .badge-note {
                  font-size: 12px;
                  color: #F59E0B;
                  margin-top: 6px;
                }
              </style>
            </head>
            <body>
              <div class="card">
                <div class="logo-row">
                  <div class="logo-icon">&#127917;</div>
                  <div class="logo-title">Rehearsal</div>
                </div>
                
                <h1>Reset Password</h1>
                <p class="desc">Enter a new secure password for your account below.</p>
                
                <div class="app-link-box" id="appLinkBox">
                  <div class="app-link-text">Using the mobile app?</div>
                  <a href="#" id="appDeepLink" class="app-link-btn">Open in App</a>
                </div>

                <div id="errorAlert" class="alert alert-error"></div>
                <div id="successAlert" class="alert alert-success"></div>

                <form id="resetForm">
                  <div class="form-group">
                    <label for="token">Reset Token / Code</label>
                    <input type="text" id="token" name="token" required autocomplete="off">
                  </div>
                  
                  <div class="form-group">
                    <label for="newPassword">New Password</label>
                    <input type="password" id="newPassword" name="newPassword" minlength="8" required placeholder="At least 8 characters">
                    <div class="badge-note">Must be at least 8 characters long</div>
                  </div>

                  <div class="form-group">
                    <label for="confirmPassword">Confirm New Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" minlength="8" required placeholder="Re-enter your password">
                  </div>

                  <button type="submit" id="submitBtn" class="btn-submit">Update Password</button>
                </form>
              </div>

              <script>
                // Extract token and scrub from URL history to prevent exposure/logging
                const urlParams = new URLSearchParams(window.location.search);
                const initialToken = urlParams.get('token') || '__SAFE_TOKEN__';
                
                const tokenInput = document.getElementById('token');
                const appDeepLink = document.getElementById('appDeepLink');

                if (initialToken) {
                  tokenInput.value = initialToken;
                  appDeepLink.href = 'rehearsal://reset-password?token=' + encodeURIComponent(initialToken);
                  // Clean up address bar query param immediately
                  if (window.history.replaceState) {
                    window.history.replaceState({}, document.title, window.location.pathname);
                  }
                } else {
                  appDeepLink.href = 'rehearsal://reset-password';
                }

                const resetForm = document.getElementById('resetForm');
                const submitBtn = document.getElementById('submitBtn');
                const errorAlert = document.getElementById('errorAlert');
                const successAlert = document.getElementById('successAlert');

                resetForm.addEventListener('submit', async (e) => {
                  e.preventDefault();
                  errorAlert.style.display = 'none';
                  successAlert.style.display = 'none';

                  const token = tokenInput.value.trim();
                  const newPassword = document.getElementById('newPassword').value;
                  const confirmPassword = document.getElementById('confirmPassword').value;

                  if (!token) {
                    errorAlert.textContent = 'Please enter your reset token.';
                    errorAlert.style.display = 'block';
                    return;
                  }

                  if (newPassword.length < 8) {
                    errorAlert.textContent = 'Password must be at least 8 characters long.';
                    errorAlert.style.display = 'block';
                    return;
                  }

                  if (newPassword !== confirmPassword) {
                    errorAlert.textContent = 'Passwords do not match.';
                    errorAlert.style.display = 'block';
                    return;
                  }

                  submitBtn.disabled = true;
                  submitBtn.textContent = 'Updating...';

                  try {
                    const response = await fetch('/api/auth/reset-password', {
                      method: 'POST',
                      headers: { 'Content-Type': 'application/json' },
                      body: JSON.stringify({ token, newPassword })
                    });

                    if (response.ok) {
                      resetForm.style.display = 'none';
                      successAlert.innerHTML = '<strong>Password Successfully Reset!</strong><br><br>You can now open the Rehearsal mobile app and sign in with your new password.<br><br><a href="rehearsal://login" class="app-link-btn" style="display:inline-block; margin-top:8px;">Open Rehearsal App</a>';
                      successAlert.style.display = 'block';
                    } else {
                      const msg = await response.text();
                      errorAlert.textContent = msg || 'Failed to reset password. The link or token may be expired.';
                      errorAlert.style.display = 'block';
                      submitBtn.disabled = false;
                      submitBtn.textContent = 'Update Password';
                    }
                  } catch (err) {
                    errorAlert.textContent = 'Network error. Please try again.';
                    errorAlert.style.display = 'block';
                    submitBtn.disabled = false;
                    submitBtn.textContent = 'Update Password';
                  }
                });
              </script>
            </body>
            </html>
            """.replace("__SAFE_TOKEN__", safeToken);
    }
}
