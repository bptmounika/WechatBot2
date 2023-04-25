FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
WORKDIR /app

# Copy everything
COPY . ./
# Restore as distinct layers
RUN dotnet restore
# Build and publish a release
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "app-dotnet.dll"]

# FROM python:3
# WORKDIR /app
# ARG POETRY_VERSION=1.2.2
# RUN apt-get update && \
#     curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
#     apt-get install -y nodejs && \
#     rm -rf /var/cache/apk/* && \
#     pip3 install --no-cache-dir poetry && \
#     rm -rf ~/.cache/
# COPY package*.json ./
# COPY pyproject.toml ./
# COPY poetry.lock ./
# # Install dependencies
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
# RUN poetry install && npm install && rm -rf ~/.npm/
# COPY . .
# CMD ["npm", "run", "dev"]
