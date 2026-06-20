# استخدام نسخة لينكس مستقرة وخفيفة
FROM ubuntu:22.04

# منع ظهور أسئلة التثبيت التفاعلية
ENV DEBIAN_FRONTEND=noninteractive

# تثبيت الأدوات الأساسية والـ python3 لتشغيل السيرفر
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    python3 \
    tar \
    && rm -rf /var/lib/apt/lists/*

# تحميل النسخة المحمولة الجاهزة من تيلسكيل وفك ضغطها مباشرة لتخطي جدار الحماية
RUN curl -fsSL https://pkgs.tailscale.com/stable/tailscale_1.66.4_amd64.tgz -o tailscale.tgz && \
    tar -xzvf tailscale.tgz && \
    mv tailscale_1.66.4_amd64/tailscale /usr/local/bin/ && \
    mv tailscale_1.66.4_amd64/tailscaled /usr/local/bin/ && \
    rm -rf tailscale.tgz tailscale_1.66.4_amd64


# المنفذ الافتراضي الذي تطلبه منصة Railway لتأكيد عمل السيرفر
EXPOSE 8080

# تشغيل خادم ويب وهمي متوافق مع بورت Railway وتفعيل اتصال Tailscale
CMD python3 -m http.server 8080 & \
    tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 & \
    sleep 5 && \
    tailscale up --authkey=${TAILSCALE_AUTH_KEY} --hostname=railway-runner && \
    echo "=== السيرفر متصل الآن بـ Tailscale بنجاح ===" && \
    while true; do sleep 300; done
