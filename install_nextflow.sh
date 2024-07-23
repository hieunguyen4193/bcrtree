export NXF_VER=22.10.0

if [ -f "/usr/local/bin/nextflow" ]; then
    echo "Nextflow is already installed."
else
    wget https://github.com/nextflow-io/nextflow/releases/download/v$NXF_VER/nextflow-$NXF_VER-all
    bash nextflow-$NXF_VER-all
    chmod +x nextflow
    mv nextflow /usr/local/bin
    mv /usr/local/bin/nextflow
    echo "Nextflow v$NXF_VER installed successfully."
fi