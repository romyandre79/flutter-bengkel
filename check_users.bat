@echo off
sqlite3 "%USERPROFILE%\Documents\kreatif_otopart.db" "SELECT id, username, role, password_hash, is_active FROM users;"
