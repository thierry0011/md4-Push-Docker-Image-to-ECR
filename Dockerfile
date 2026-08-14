# 1. Base image
FROM python:3.12-slim

# 2. Set working directory inside the container
WORKDIR /app

# 3. Create a non-root user
RUN useradd --create-home --shell /bin/bash appuser

# 4. Copy dependency file first (before app code)
COPY requirements.txt .

# 5. Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# 6. Copy the rest of the application code
COPY . .

# 7. Switch to non-root user
USER appuser

# 8. Expose the port the app listens on
EXPOSE 5000

# 9. Run the app with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]