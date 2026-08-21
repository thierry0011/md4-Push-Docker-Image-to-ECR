# 1. Base image (minimal, actively patched; musl-based Alpine avoids the
#    perl/glibc/sqlite3 CVEs that come bundled in Debian-based slim images)
FROM python:3.12-alpine

# 2. Runtime hygiene
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# 3. Set working directory inside the container
WORKDIR /app

# 4. Create a non-root user
RUN adduser -D -h /home/appuser -s /bin/sh appuser

# 5. Copy dependency file first (before app code, for build cache efficiency)
COPY requirements.txt .

# 6. Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# 7. Copy the rest of the application code and hand ownership to the non-root user
COPY --chown=appuser:appuser . .

# 8. Switch to non-root user
USER appuser

# 9. Expose the port the app listens on
EXPOSE 5000

# 10. Container-level health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:5000/health', timeout=2).status == 200 else 1)"

# 11. Run the app with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]