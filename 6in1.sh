#!/bin/bash

# تثبيت الحزم الأساسية
apt-get install -y jq curl

# روابط السكربتات
declare -A scripts=(
  [web_sayfa_hmnd.sh]="https://github.com/CabirH40/script.sh/raw/main/web_sayfa_hmnd.sh"
  [whatsbotPythonayarlar.sh]="https://github.com/CabirH40/script.sh/raw/main/whatsbotPythonayarlar.sh"
  [net_check.sh]="https://github.com/CabirH40/script.sh/raw/main/net_check.sh"
  [check_process-humanode2.sh]="https://github.com/CabirH40/script.sh/raw/main/check_process-humanode2.sh"
  [script.sh]="https://github.com/CabirH40/script.sh/raw/main/script2.sh"
  [get_auth_url.sh]="https://github.com/CabirH40/script.sh/raw/main/get_auth_url.sh"
)

# تحميل وتفعيل السكربتات
for name in "${!scripts[@]}"; do
  echo "⬇️ تحميل $name"
  wget -q -O "/root/$name" "${scripts[$name]}" && chmod +x "/root/$name"
done

# 📆 إعادة تعيين crontab بالكامل وإضافة المهام الجديدة فقط
echo "🔁 إعادة تعيين crontab وتحديث المهام..."
cat <<EOF | crontab -
* * * * * /root/get_auth_url.sh
*/10 * * * * /root/script.sh
EOF

# تشغيل script.sh أول مرة يدويًا
echo "🚀 تشغيل /root/script.sh لأول مرة..."
/root/script.sh

echo "✅ تم تحميل جميع السكربتات وتحديث المهام المجدولة بنجاح."
