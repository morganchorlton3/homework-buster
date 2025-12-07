FROM public.ecr.aws/lambda/python:3.13

# Install poetry
RUN pip install poetry
RUN poetry self add poetry-plugin-export
RUN poetry config virtualenvs.create false

# Copy dependency files
COPY poetry.lock ./poetry.lock
COPY pyproject.toml ./pyproject.toml

# Copy application code
COPY api/ "${LAMBDA_TASK_ROOT}"/api

# Install dependencies
RUN poetry install --only api

# Set the CMD to your handler
CMD ["api.lambda_handler.handler"]