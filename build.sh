
APP_NAME=circleci-web
echo "Starting build: ${APP_NAME}"
echo "------------------------"

echo "1. Remove cache local"
rm -r ./.next/cache

echo "2. Build service docker"
docker build -t ${APP_NAME} -f ./Dockerfile .

echo "3. Done"
echo "------------------------"
