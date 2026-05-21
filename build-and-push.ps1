# build-and-push.ps1
param(
    [string]$SERVICE,
    [string]$VERSION = "latest"
)

$USERNAME = "goncfsoares"
$IMAGE_NAME = "$USERNAME/$SERVICE"
$GIT_COMMIT = git rev-parse --short HEAD

Write-Host "Building ${IMAGE_NAME}:${VERSION} ..."
docker build -t "${IMAGE_NAME}:${VERSION}" .

Write-Host "Building ${IMAGE_NAME}:${GIT_COMMIT} ..."
docker build -t "${IMAGE_NAME}:${GIT_COMMIT}" .

Write-Host "Pushing ${IMAGE_NAME}:${VERSION} ..."
docker push "${IMAGE_NAME}:${VERSION}"

Write-Host "Pushing ${IMAGE_NAME}:${GIT_COMMIT} ..."
docker push "${IMAGE_NAME}:${GIT_COMMIT}"

Write-Host "Done!"