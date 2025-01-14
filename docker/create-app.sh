# ibmcloud target -r eu-es
# ibmcloud target -g france-vla
# ibmcloud ce project select -n safeitem

ibmcloud ce app delete --name si3 --force
sleep 5
ibmcloud ce app create \
  --name si3 \
  --build-source git@github.com:vannlam/ibmcloud.git \
  --build-git-repo-secret mcbook \
  --build-strategy dockerfile \
  --build-dockerfile Dockerfile \
  --build-commit master \
  --build-context-dir docker \
  --build-size medium \
  --image docker.io/vannlam3/wan:latest \
  --registry-secret vannlam3 \
  --mount-secret /aws/s3-access=s3-access
