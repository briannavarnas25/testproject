# Use official lightweight Python image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Install dependencies
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ .

# Run as non-root user for security
RUN useradd -m appuser
USER appuser

# Expose port
EXPOSE 8080

# Start the app with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "main:app"]
