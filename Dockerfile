ARG BASE=nvidia/cuda:11.8.0-base-ubuntu22.04
FROM ${BASE}

# System dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      gcc g++ make python3 python3-dev python3-pip python3-venv python3-wheel \
      espeak-ng libsndfile1-dev curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Python deps: install at build time
RUN pip3 install --no-cache-dir llvmlite --ignore-installed
RUN pip3 install --no-cache-dir torch torchaudio --extra-index-url https://download.pytorch.org/whl/cu118

# Copy repo contents
WORKDIR /root
COPY . /root

# Install the TTS package (editable mode is helpful during dev)
# If your repository provides make install and that works, you can keep it; pip -e is more predictable.
RUN pip3 install --no-cache-dir -e .

# Install server runtime (FastAPI + uvicorn)
RUN pip3 install --no-cache-dir "uvicorn[standard]==0.30.*" "fastapi>=0.110"

# Ensure python can find your repo if not installed
ENV PYTHONPATH=/root

# Expose API port
EXPOSE 5002

# Ensure no leftover shell entrypoint interferes
ENTRYPOINT []

# Run uvicorn executable directly (array-form CMD avoids shell parsing)
CMD ["uvicorn", "TTS.server.server:app", "--host", "0.0.0.0", "--port", "5002", "--log-level", "info"]




