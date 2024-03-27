import sentry_sdk

sentry_sdk.init(
    dsn="https://b9dfc117a5e9dd988e2272e17f5ee8b6@o4506983039303680.ingest.us.sentry.io/4506983098286080",
    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    traces_sample_rate=1.0,
    # Set profiles_sample_rate to 1.0 to profile 100%
    # of sampled transactions.
    # We recommend adjusting this value in production.
    profiles_sample_rate=1.0,
)
