ARG BASE=nvidia/cuda:11.8.0-base-ubuntu22.04
FROM ${BASE}

# System dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    gcc g++ make python3 python3-dev python3-pip python3-venv python3-wheel \
    espeak-ng libsndfile1-dev curl && \
    rm -rf /var/lib/apt/lists/*

# Python deps
RUN pip3 install llvmlite --ignore-installed
RUN pip3 install torch torchaudio --extra-index-url https://download.pytorch.org/whl/cu118
RUN rm -rf /root/.cache/pip

# Copy repo contents
WORKDIR /root
COPY . /root

# Install TTS package
RUN make install

# Install server runtime (FastAPI + Uvicorn)
RUN python3 -m pip install --no-cache-dir "uvicorn[standard]==0.30.*" "fastapi>=0.110"

# Expose API port
EXPOSE 5002

# Run TTS HTTP server
CMD ["python3", "-m", "uvicorn", "TTS.server.server:app", "--port", "5002", "--log-level", "info"]

