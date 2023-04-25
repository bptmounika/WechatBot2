# `python-base` sets up all our shared environment variables
FROM python:3.11-slim as python-base

    # python
ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    \
    # poetry
    # https://python-poetry.org/docs/configuration/#using-environment-variables
    POETRY_VERSION=1.3.0 \
    # make poetry install to this location
    POETRY_HOME="/opt/poetry" \
    # make poetry create the virtual environment in the project's root
    # it gets named `.venv`
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    # do not ask any interactive question
    POETRY_NO_INTERACTION=1 \
    \
    # paths
    # this is where our requirements + virtual environment will live
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"


# prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# `builder-base` stage is used to build deps + create our virtual environment
FROM python-base as builder-base
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        # deps for installing poetry
        curl \
        # deps for building python deps
        build-essential

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 - --version 1.3.0

# copy project requirement files here to ensure they will be cached.
WORKDIR $PYSETUP_PATH
COPY ./pyproject.toml ./poetry.lock* ./

RUN bash -c "poetry install"


FROM python-base as production
ENV FASTAPI_ENV=production
ENV PYTHONPATH="$PYTHONPATH:/service"
COPY --from=builder-base $PYSETUP_PATH $PYSETUP_PATH
WORKDIR /service
COPY . .
RUN ls
EXPOSE 8001
RUN chmod 777 prestart.sh
ENTRYPOINT [ "/bin/bash" ]
CMD [ "./prestart.sh" ]
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
